import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../state/auth_state.dart';
import '../../../widgets/communs/barre_sticky_action.dart';
import '../../../widgets/communs/profil_settings/entete_profil_settings.dart';
import '../../../widgets/communs/snackbars.dart';

/// Mot magique à taper pour confirmer la suppression. Case-sensitive.
const String _confirmationKeyword = 'SUPPRIMER';

/// Page « Supprimer mon compte » — partagée par les 4 rôles.
///
/// Premium et dissuasive sans être agressive : conséquences listées,
/// confirmation par mot magique, dialog post-suppression + logout forcé.
/// Si une demande est déjà en cours, on affiche le bandeau d'annulation
/// avec la date de purge effective.
class SupprimerComptePage extends ConsumerStatefulWidget {
  /// Crée la page.
  const SupprimerComptePage({required this.fallbackPath, super.key});

  /// Chemin de repli pour le bouton retour si la pile est vide.
  final String fallbackPath;

  @override
  ConsumerState<SupprimerComptePage> createState() =>
      _SupprimerComptePageState();
}

class _SupprimerComptePageState extends ConsumerState<SupprimerComptePage> {
  final TextEditingController _confirmationController =
      TextEditingController();
  bool _submitting = false;
  Future<_DeletionStatus>? _statusFuture;

  @override
  void initState() {
    super.initState();
    _confirmationController.addListener(_onConfirmationChanged);
    _statusFuture = _fetchStatus();
  }

  @override
  void dispose() {
    _confirmationController.removeListener(_onConfirmationChanged);
    _confirmationController.dispose();
    super.dispose();
  }

  void _onConfirmationChanged() {
    // Trigger rebuild pour activer/désactiver le bouton.
    setState(() {});
  }

  // ─── Fetch initial : sait-on déjà que la suppression est en cours ? ──

  Future<_DeletionStatus> _fetchStatus() async {
    // L'export contient typiquement les flags `deletion_requested_at` et
    // `deletion_effective_at` ; on tape plutôt le getConsentStatus qui
    // sert également de probe légère côté backend. À défaut, on se
    // rabat sur un état "non demandé" et l'erreur sera gérée à l'envoi.
    //
    // NB : si le backend expose un dédié /auth/account/status on
    // pourrait pivoter sans toucher l'UI. En attendant on lit la
    // demande via l'export rapide (limité) ou on suppose absent.
    try {
      final legal = ref.read(legalServiceProvider);
      final consent = await legal.getConsentStatus();
      final reqAt = consent['deletion_requested_at'];
      final effAt = consent['deletion_effective_at'];
      if (reqAt is String && reqAt.isNotEmpty) {
        return _DeletionStatus(
          requestedAt: DateTime.tryParse(reqAt),
          effectiveAt: effAt is String ? DateTime.tryParse(effAt) : null,
        );
      }
    } catch (_) {
      // Fail silencieux — la page assume "non demandée".
    }
    return const _DeletionStatus();
  }

  // ─── Action : déclencher la demande de suppression ───────────────────

  Future<void> _onDemanderSuppression() async {
    final raw = _confirmationController.text;
    if (raw != _confirmationKeyword) {
      Snackbars.showErreur(
        context,
        'Tape exactement « SUPPRIMER » en majuscules pour confirmer.',
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final legal = ref.read(legalServiceProvider);
      final res = await legal.requestAccountDeletion();
      if (!mounted) return;
      final effectiveAt = _parseEffectiveDate(res);
      await _afficherDialogSucces(effectiveAt);
      if (!mounted) return;
      await ref.read(authStateProvider.notifier).logout();
      if (!mounted) return;
      context.go(RouteNames.bienvenuePath);
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (!mounted) return;
      Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  DateTime? _parseEffectiveDate(Map<String, dynamic> res) {
    final raw = res['deletion_effective_at'] ?? res['effective_at'];
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    // Fallback : 30 jours à partir de maintenant.
    return DateTime.now().add(const Duration(days: 30));
  }

  Future<void> _afficherDialogSucces(DateTime? effectiveAt) async {
    final formatter = DateFormat('d MMMM yyyy', 'fr_FR');
    final dateStr = effectiveAt != null
        ? formatter.format(effectiveAt)
        : 'dans 30 jours';
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimens.brCard,
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 22,
              ),
            ),
            AppDimens.hGap12,
            const Expanded(
              child: Text('Demande enregistrée'),
            ),
          ],
        ),
        content: Text(
          'Ton compte sera supprimé le $dateStr. Tu peux annuler à tout '
          'moment en te reconnectant pendant cette période.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  // ─── Action : annuler une demande en cours ───────────────────────────

  Future<void> _onAnnulerSuppression() async {
    setState(() => _submitting = true);
    try {
      final legal = ref.read(legalServiceProvider);
      await legal.cancelAccountDeletion();
      if (!mounted) return;
      Snackbars.showSuccesDetail(
        context,
        titre: 'Suppression annulée',
        sousTitre: 'Ton compte est réactivé.',
      );
      setState(() {
        _statusFuture = Future.value(const _DeletionStatus());
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (!mounted) return;
      Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final ready = _confirmationController.text == _confirmationKeyword;

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            EnteteProfilSettings(
              fallbackPath: widget.fallbackPath,
              titre: 'Supprimer mon compte',
            ),
            Expanded(
              child: FutureBuilder<_DeletionStatus>(
                future: _statusFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                  final status = snap.data ?? const _DeletionStatus();
                  if (status.isRequested) {
                    return _VueDemandeEnCours(
                      status: status,
                      onAnnuler: _onAnnulerSuppression,
                      busy: _submitting,
                    );
                  }
                  return _VueFormulaire(
                    confirmationController: _confirmationController,
                  );
                },
              ),
            ),
            FutureBuilder<_DeletionStatus>(
              future: _statusFuture,
              builder: (context, snap) {
                final status = snap.data ?? const _DeletionStatus();
                if (status.isRequested) {
                  // Le sticky bottom est déjà géré dans la vue en cours.
                  return const SizedBox.shrink();
                }
                return BarreStickyAction(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BoutonStickyPrincipal(
                        label: 'Demander la suppression',
                        icone: Icons.delete_outline,
                        couleur: AppColors.error,
                        busy: _submitting,
                        onTap: ready ? _onDemanderSuppression : null,
                      ),
                      AppDimens.vGap8,
                      TextButton(
                        onPressed: _submitting
                            ? null
                            : () => context.canPop()
                                ? context.pop()
                                : context.go(widget.fallbackPath),
                        child: Text(
                          'Annuler',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Vue formulaire (cas standard, aucune demande en cours) ─────────────

class _VueFormulaire extends StatelessWidget {
  const _VueFormulaire({required this.confirmationController});

  final TextEditingController confirmationController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space16,
        AppDimens.pagePaddingH,
        AppDimens.space24,
      ),
      children: [
        const _IconeWarning(),
        AppDimens.vGap16,
        Text(
          'Supprimer mon compte FarmCash',
          textAlign: TextAlign.center,
          style: AppTextStyles.titleMedium.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        AppDimens.vGap8,
        Text(
          'Cette action est irréversible après la fenêtre de 30 jours. '
          'Prends le temps de lire les conséquences ci-dessous.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        AppDimens.vGap24,
        const _BlocConsequences(),
        AppDimens.vGap24,
        Text(
          'Confirmation',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppDimens.vGap8,
        Text(
          'Tape SUPPRIMER (en majuscules) pour activer le bouton.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSubtle,
          ),
        ),
        AppDimens.vGap8,
        TextField(
          controller: confirmationController,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            // Le keyword est case-sensitive côté logique métier ; on
            // pré-filtre les espaces pour éviter les frappes ambiguës.
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
          ],
          decoration: InputDecoration(
            hintText: _confirmationKeyword,
            hintStyle: AppTextStyles.hint,
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: AppDimens.brInput,
              borderSide: const BorderSide(
                color: AppColors.borderStrong,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppDimens.brInput,
              borderSide: const BorderSide(
                color: AppColors.borderStrong,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppDimens.brInput,
              borderSide: const BorderSide(
                color: AppColors.error,
                width: AppDimens.borderMedium,
              ),
            ),
          ),
          style: AppTextStyles.bodyLarge.copyWith(
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─── Vue bandeau « demande déjà en cours » ──────────────────────────────

class _VueDemandeEnCours extends StatelessWidget {
  const _VueDemandeEnCours({
    required this.status,
    required this.onAnnuler,
    required this.busy,
  });

  final _DeletionStatus status;
  final VoidCallback onAnnuler;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMMM yyyy', 'fr_FR');
    final dateLabel = status.effectiveAt != null
        ? fmt.format(status.effectiveAt!)
        : 'dans 30 jours';

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space16,
        AppDimens.pagePaddingH,
        AppDimens.space24,
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimens.space16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1E0),
            borderRadius: AppDimens.brCard,
            border: Border.all(
              color: const Color(0xFFE89B4B),
              width: AppDimens.borderThin,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.hourglass_top_rounded,
                color: Color(0xFF9A5B12),
                size: 22,
              ),
              AppDimens.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suppression demandée',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: const Color(0xFF6B3F0E),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppDimens.vGap4,
                    Text(
                      'Ton compte sera purgé le $dateLabel. Tu peux '
                      'annuler la demande pendant cette période.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF6B3F0E),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        AppDimens.vGap24,
        BarreStickyAction(
          padding: EdgeInsets.zero,
          child: BoutonStickyPrincipal(
            label: 'Annuler la suppression',
            icone: Icons.undo_rounded,
            busy: busy,
            onTap: onAnnuler,
          ),
        ),
      ],
    );
  }
}

// ─── Mini composants visuels ───────────────────────────────────────────

class _IconeWarning extends StatelessWidget {
  const _IconeWarning();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.warning_amber_rounded,
          color: AppColors.error,
          size: 36,
        ),
      ),
    );
  }
}

class _BlocConsequences extends StatelessWidget {
  const _BlocConsequences();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _LigneConsequence(
            icone: Icons.delete_sweep_outlined,
            titre: 'Toutes tes données seront supprimées sous 30 jours',
            sousTitre:
                'Profil, annonces, KYC, messages — purge définitive après '
                'la période de soft-delete.',
          ),
          AppDimens.vGap12,
          _LigneConsequence(
            icone: Icons.account_balance_wallet_outlined,
            titre: 'Ton wallet sera vidé',
            sousTitre:
                'Transfère tes fonds vers ton mobile money avant de '
                'supprimer ton compte.',
          ),
          AppDimens.vGap12,
          _LigneConsequence(
            icone: Icons.local_shipping_outlined,
            titre: 'Tes commandes en cours doivent être finalisées',
            sousTitre:
                'Tu ne peux pas supprimer ton compte tant qu\'une commande '
                'est en cours de livraison.',
          ),
          AppDimens.vGap12,
          _LigneConsequence(
            icone: Icons.replay_circle_filled_outlined,
            titre: 'Tu peux changer d\'avis pendant 30 jours',
            sousTitre:
                'Reconnecte-toi avant la date de purge pour annuler la '
                'demande et tout récupérer.',
          ),
        ],
      ),
    );
  }
}

class _LigneConsequence extends StatelessWidget {
  const _LigneConsequence({
    required this.icone,
    required this.titre,
    required this.sousTitre,
  });

  final IconData icone;
  final String titre;
  final String sousTitre;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icone, color: AppColors.error, size: 16),
        ),
        AppDimens.hGap12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titre,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppDimens.vGap4,
              Text(
                sousTitre,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Modèle de statut local ─────────────────────────────────────────────

class _DeletionStatus {
  const _DeletionStatus({this.requestedAt, this.effectiveAt});

  final DateTime? requestedAt;
  final DateTime? effectiveAt;

  bool get isRequested => requestedAt != null;
}
