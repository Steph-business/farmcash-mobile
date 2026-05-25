import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/annonce_vente.dart';
import '../../../models/enums.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/communs/vue_erreur.dart';
import '../../widgets/cooperative/membres/boite_poids_pesee.dart';
import '../../widgets/cooperative/membres/boutons_sticky_pesee.dart';
import '../../widgets/cooperative/membres/carte_hero_pesee.dart';
import '../../widgets/cooperative/membres/champ_note_pesee.dart';
import '../../widgets/cooperative/membres/chip_qualite_pesee.dart';
import '../../widgets/cooperative/membres/entete_pesee.dart';
import '../../widgets/cooperative/membres/etiquette_pesee.dart';
import '../../widgets/cooperative/membres/libelle_qualite_produit.dart';

const Color _kWarn = Color(0xFFB45309);

/// Provider qui récupère l'annonce de vente attachée à la coopérative
/// (paramètre `livraisonId` == `annonce_vente_id`). Côté backend, la coop
/// peut valider/rejeter une annonce qui lui a été assignée.
final _peseeAnnonceProvider = FutureProvider.autoDispose
    .family<AnnonceVente, String>((ref, id) async {
  return ref.read(marketplaceServiceProvider).getAnnonceVente(id);
});

/// Pesée d'une livraison farmer arrivée à la coopérative.
/// `validateAnnonceVente` → propage la quantité/qualité validées à
/// l'annonce, change son statut côté back et notifie le farmer.
class PeseePage extends ConsumerStatefulWidget {
  const PeseePage({super.key, required this.livraisonId});

  final String livraisonId;

  @override
  ConsumerState<PeseePage> createState() => _PeseePageState();
}

class _PeseePageState extends ConsumerState<PeseePage> {
  final _poidsCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  ProductQuality _qualite = ProductQuality.standard;
  bool _hydrated = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _poidsCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _poidsCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _hydrateOnce(AnnonceVente a) {
    if (_hydrated) return;
    _hydrated = true;
    _poidsCtrl.text = a.quantiteKg.round().toString();
    _qualite = a.qualite == ProductQuality.unknown
        ? ProductQuality.standard
        : a.qualite;
  }

  double? get _poidsMesure {
    final raw = _poidsCtrl.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  double _ecartContre(double annonce) {
    final p = _poidsMesure ?? 0;
    return p - annonce;
  }

  String _ecartLabel(double annonce) {
    final e = _ecartContre(annonce);
    final signe = e >= 0 ? '+' : '−';
    return 'Écart annoncé / mesuré : $signe${e.abs().toStringAsFixed(0)} kg';
  }

  Color _ecartColor(double annonce) {
    return _ecartContre(annonce) > -10 ? AppColors.primary : _kWarn;
  }

  Future<void> _valider(AnnonceVente a) async {
    if (_busy) return;
    final poids = _poidsMesure;
    if (poids == null || poids <= 0) {
      Snackbars.showErreur(context, 'Saisis un poids mesuré valide.');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(cooperativesServiceProvider).validateAnnonceVente(
            id: a.id,
            quantiteKgReelle: poids,
            qualiteReelle: _qualite,
            notesPesee: _noteCtrl.text.trim().isEmpty
                ? null
                : _noteCtrl.text.trim(),
          );
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        'Pesée validée. Le producteur est notifié.',
      );
      ref.invalidate(_peseeAnnonceProvider(widget.livraisonId));
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go(RouteNames.cooperativeCollectePath);
      }
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _rejeter(AnnonceVente a) async {
    if (_busy) return;
    final motif = await _demanderMotif();
    if (motif == null || motif.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref.read(cooperativesServiceProvider).rejectAnnonceVente(
            id: a.id,
            rejectionReason: motif.trim(),
          );
      if (!mounted) return;
      Snackbars.showInfo(context, 'Livraison rejetée. Producteur notifié.');
      ref.invalidate(_peseeAnnonceProvider(widget.livraisonId));
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go(RouteNames.cooperativeCollectePath);
      }
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _demanderMotif() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Motif de rejet'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Ex : marchandise dégradée, poids très en-dessous…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_peseeAnnonceProvider(widget.livraisonId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              EntetePesee(),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const EntetePesee(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la livraison. $e',
                    onRetry: () => ref
                        .invalidate(_peseeAnnonceProvider(widget.livraisonId)),
                  ),
                ),
              ),
            ],
          ),
          data: (a) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _hydrateOnce(a);
            });
            return _build(a);
          },
        ),
      ),
    );
  }

  Widget _build(AnnonceVente a) {
    final annonceQte = a.quantiteKg;
    return Column(
      children: [
        const EntetePesee(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.pagePaddingH,
              0,
              AppDimens.pagePaddingH,
              AppDimens.space16,
            ),
            children: [
              CarteHeroPesee(annonce: a),
              const SizedBox(height: 20),
              const EtiquettePesee('Poids réel mesuré'),
              const SizedBox(height: 10),
              BoitePoidsPesee(
                controller: _poidsCtrl,
                ecartLabel: _ecartLabel(annonceQte),
                ecartColor: _ecartColor(annonceQte),
              ),
              const SizedBox(height: 22),
              const EtiquettePesee('Qualité observée'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final q in const [
                    ProductQuality.standard,
                    ProductQuality.premium,
                    ProductQuality.bio,
                    ProductQuality.equitable,
                  ])
                    ChipQualitePesee(
                      label: libelleQualiteProduit(q),
                      active: _qualite == q,
                      onTap: () => setState(() => _qualite = q),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              const EtiquettePesee('Note interne (optionnel)'),
              const SizedBox(height: 10),
              ChampNotePesee(controller: _noteCtrl, enabled: !_busy),
            ],
          ),
        ),
        BoutonsStickyPesee(
          busy: _busy,
          onRejeter: () => _rejeter(a),
          onValider: () => _valider(a),
        ),
      ],
    );
  }
}
