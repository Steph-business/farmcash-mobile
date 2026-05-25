import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/membre_coop.dart';
import '../../../../models/portefeuille.dart';
import '../../../../models/wallet_with_transactions.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/cooperative/avances/bloc_montant_avance.dart';
import '../../../widgets/cooperative/avances/bouton_choisir_membre.dart';
import '../../../widgets/cooperative/avances/bouton_sticky_verser.dart';
import '../../../widgets/cooperative/avances/carte_membre_selectionne.dart';
import '../../../widgets/cooperative/avances/carte_solde_coop.dart';
import '../../../widgets/cooperative/avances/champ_motif_avance.dart';
import '../../../widgets/cooperative/avances/entete_verser_avance.dart';
import '../../../widgets/cooperative/avances/etiquette_champ_avance.dart';
import '../../../widgets/cooperative/avances/feuille_choix_membre.dart';

/// Bundle initial : membres + solde du wallet coop.
class _AvanceBundle {
  const _AvanceBundle({required this.membres, this.wallet});
  final List<MembreCoop> membres;
  final Portefeuille? wallet;
}

final _avanceBundleProvider =
    FutureProvider.autoDispose<_AvanceBundle>((ref) async {
  final coop = ref.read(cooperativesServiceProvider);
  final finance = ref.read(financeServiceProvider);
  final results = await Future.wait<dynamic>([
    coop.listMembers().then<Object?>((v) => v),
    finance
        .getWallet(limit: 1)
        .then<Object?>((v) => v)
        .catchError((_) => null),
  ]);
  final membresPage = results[0] as dynamic;
  final list = (membresPage.data as List<MembreCoop>);
  final walletBundle = results[1] as WalletWithTransactions?;
  return _AvanceBundle(membres: list, wallet: walletBundle?.wallet);
});

/// Verser une avance à un membre. Appelle réellement `payAdvance`
/// — qui crée la ligne `coop_advance_payments` côté back, débite le wallet
/// coop et crédite le farmer (transaction atomique).
class VerserAvancePage extends ConsumerStatefulWidget {
  const VerserAvancePage({super.key, this.membreIdInitial});

  final String? membreIdInitial;

  @override
  ConsumerState<VerserAvancePage> createState() => _VerserAvancePageState();
}

class _VerserAvancePageState extends ConsumerState<VerserAvancePage> {
  final _montantCtrl = TextEditingController();
  final _motifCtrl = TextEditingController();
  MembreCoop? _membre;
  bool _busy = false;
  bool _hydrated = false;

  @override
  void dispose() {
    _montantCtrl.dispose();
    _motifCtrl.dispose();
    super.dispose();
  }

  /// Pré-sélectionne le membre si `membreIdInitial` est passé.
  void _hydrateOnce(_AvanceBundle bundle) {
    if (_hydrated) return;
    _hydrated = true;
    if (widget.membreIdInitial != null && bundle.membres.isNotEmpty) {
      for (final m in bundle.membres) {
        if (m.userId == widget.membreIdInitial || m.id == widget.membreIdInitial) {
          _membre = m;
          break;
        }
      }
    }
  }

  int get _montantValeur {
    final raw = _montantCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(raw) ?? 0;
  }

  Future<void> _choisirMembre(List<MembreCoop> membres) async {
    if (_busy) return;
    final selected = await showModalBottomSheet<MembreCoop>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => FeuilleChoixMembre(
        membres: membres,
        selectedId: _membre?.id,
      ),
    );
    if (selected != null && mounted) {
      setState(() => _membre = selected);
    }
  }

  Future<void> _verser(double soldeCoop) async {
    if (_busy) return;
    if (_membre == null) {
      Snackbars.showErreur(context, 'Choisis d\'abord un membre.');
      return;
    }
    final montant = _montantValeur;
    if (montant <= 0) {
      Snackbars.showErreur(context, 'Saisis un montant valide.');
      return;
    }
    if (montant > soldeCoop) {
      Snackbars.showErreur(
        context,
        'Solde insuffisant. Solde coop : ${_fmtFcfa(soldeCoop)} F.',
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(cooperativesServiceProvider).payAdvance(
            farmerId: _membre!.userId,
            amount: montant.toDouble(),
            motif: _motifCtrl.text.trim().isEmpty
                ? null
                : _motifCtrl.text.trim(),
          );
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        'Avance de ${_fmtFcfa(montant.toDouble())} F versée à ${_membre!.fullName ?? 'le membre'}.',
      );
      // Force le refresh du wallet/avances dans le reste de l'app.
      ref.invalidate(_avanceBundleProvider);
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go(RouteNames.accueilCooperativePath);
      }
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_avanceBundleProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              EnteteVerserAvance(),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const EnteteVerserAvance(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger les membres. $e',
                    onRetry: () => ref.invalidate(_avanceBundleProvider),
                  ),
                ),
              ),
            ],
          ),
          data: (bundle) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _hydrateOnce(bundle);
            });
            return _build(bundle);
          },
        ),
      ),
    );
  }

  Widget _build(_AvanceBundle bundle) {
    final soldeCoop = bundle.wallet?.balance ?? 0;
    return Column(
      children: [
        const EnteteVerserAvance(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.pagePaddingH,
              0,
              AppDimens.pagePaddingH,
              AppDimens.space16,
            ),
            children: [
              const EtiquetteChampAvance('Membre'),
              AppDimens.vGap8,
              if (_membre == null)
                BoutonChoisirMembre(
                  onTap: () => _choisirMembre(bundle.membres),
                )
              else
                CarteMembreSelectionne(
                  membre: _membre!,
                  onChange: () => _choisirMembre(bundle.membres),
                ),
              if (bundle.membres.isEmpty) ...[
                AppDimens.vGap8,
                Text(
                  'Aucun membre dans ta coopérative.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
              AppDimens.vGap16,
              CarteSoldeCoop(solde: soldeCoop),
              AppDimens.vGap24,
              BlocMontantAvance(controller: _montantCtrl),
              AppDimens.vGap24,
              const EtiquetteChampAvance('Motif (optionnel)'),
              AppDimens.vGap8,
              ChampMotifAvance(controller: _motifCtrl, enabled: !_busy),
            ],
          ),
        ),
        BoutonStickyVerser(
          montant: _montantValeur,
          busy: _busy,
          enabled: _membre != null && _montantValeur > 0,
          onTap: () => _verser(soldeCoop),
        ),
      ],
    );
  }
}

final _nf = NumberFormat('#,##0', 'fr_FR');

String _fmtFcfa(double v) => _nf.format(v.round());
