import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/membre_coop.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/communs/snackbars.dart';

/// Bundle invitations reçues + demandes envoyées (1 seul fetch parallèle).
class _InvitsBundle {
  const _InvitsBundle({required this.invitations, required this.demandes});
  final List<CoopInvitation> invitations;
  final List<CoopJoinRequest> demandes;
}

final _invitsBundleProvider = FutureProvider.autoDispose<_InvitsBundle>((
  ref,
) async {
  final svc = ref.read(cooperativesServiceProvider);
  final results = await Future.wait([
    svc.listMyInvitations(),
    svc.listJoinRequests(),
  ]);
  return _InvitsBundle(
    invitations: results[0] as List<CoopInvitation>,
    demandes: results[1] as List<CoopJoinRequest>,
  );
});

/// Page producteur : invitations reçues (par téléphone) + mes demandes
/// d'adhésion envoyées. Symétrique du côté coop qui voit l'autre face.
///
/// 2 sections :
///   1. Invitations reçues — boutons Accepter / Refuser
///   2. Mes demandes envoyées — statut (PENDING / ACCEPTED / REJECTED)
class InvitationsCoopPage extends ConsumerStatefulWidget {
  const InvitationsCoopPage({super.key});

  @override
  ConsumerState<InvitationsCoopPage> createState() =>
      _InvitationsCoopPageState();
}

class _InvitationsCoopPageState extends ConsumerState<InvitationsCoopPage> {
  bool _busyId = false;

  Future<void> _accepterInvitation(CoopInvitation inv, bool accept) async {
    if (_busyId) return;
    setState(() => _busyId = true);
    try {
      await ref
          .read(cooperativesServiceProvider)
          .handleInvitation(id: inv.id, accept: accept);
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        accept
            ? 'Invitation acceptée — tu es membre de la coop 🎉'
            : 'Invitation refusée.',
      );
      ref.invalidate(_invitsBundleProvider);
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _busyId = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_invitsBundleProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageStandard(titre: 'Adhésions'),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Impossible de charger les invitations.\n$e',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                data: (b) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(_invitsBundleProvider);
                    await ref.read(_invitsBundleProvider.future);
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.pagePaddingH,
                      AppDimens.space12,
                      AppDimens.pagePaddingH,
                      AppDimens.space24,
                    ),
                    children: [
                      _Section(
                        titre: 'Invitations reçues',
                        sousTitre: b.invitations.isEmpty
                            ? 'Tu n\'as reçu aucune invitation pour l\'instant.'
                            : '${b.invitations.where((i) => i.status == 'PENDING').length} en attente',
                      ),
                      if (b.invitations.isEmpty)
                        const _EtatVideSection(
                          message: 'Aucune invitation reçue.',
                        )
                      else
                        for (final inv in b.invitations) ...[
                          _CarteInvitation(
                            inv: inv,
                            busy: _busyId,
                            onAccepter: () => _accepterInvitation(inv, true),
                            onRefuser: () => _accepterInvitation(inv, false),
                          ),
                          AppDimens.vGap12,
                        ],
                      AppDimens.vGap24,
                      _Section(
                        titre: 'Mes demandes envoyées',
                        sousTitre: b.demandes.isEmpty
                            ? 'Tu n\'as envoyé aucune demande.'
                            : '${b.demandes.where((d) => d.status == 'PENDING').length} en attente de réponse',
                      ),
                      if (b.demandes.isEmpty)
                        const _EtatVideSection(
                          message: 'Aucune demande envoyée.',
                        )
                      else
                        for (final d in b.demandes) ...[
                          _CarteDemande(demande: d),
                          AppDimens.vGap12,
                        ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section ──────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.titre, required this.sousTitre});
  final String titre;
  final String sousTitre;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titre,
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sousTitre,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Carte invitation reçue ───────────────────────────────────────

class _CarteInvitation extends StatelessWidget {
  const _CarteInvitation({
    required this.inv,
    required this.busy,
    required this.onAccepter,
    required this.onRefuser,
  });
  final CoopInvitation inv;
  final bool busy;
  final VoidCallback onAccepter;
  final VoidCallback onRefuser;

  @override
  Widget build(BuildContext context) {
    final isPending = inv.status == 'PENDING';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.mail_outline_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Invitation à rejoindre une coopérative',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ),
              _BadgeStatut(status: inv.status),
            ],
          ),
          if (inv.message != null && inv.message!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '« ${inv.message!.trim()} »',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
          if (inv.createdAt != null) ...[
            const SizedBox(height: 6),
            Text(
              'Reçue le ${_fmtDate(inv.createdAt!)}',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11,
                color: AppColors.textSubtle,
              ),
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: busy ? null : onRefuser,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppDimens.brButton,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      'Refuser',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: busy ? null : onAccepter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppDimens.brButton,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      'Accepter',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Carte demande envoyée ────────────────────────────────────────

class _CarteDemande extends StatelessWidget {
  const _CarteDemande({required this.demande});
  final CoopJoinRequest demande;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.send_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Demande envoyée à une coopérative',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ),
              _BadgeStatut(status: demande.status),
            ],
          ),
          if (demande.message != null &&
              demande.message!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '« ${demande.message!.trim()} »',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
          if (demande.createdAt != null) ...[
            const SizedBox(height: 6),
            Text(
              'Envoyée le ${_fmtDate(demande.createdAt!)}',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11,
                color: AppColors.textSubtle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BadgeStatut extends StatelessWidget {
  const _BadgeStatut({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case 'ACCEPTED':
        bg = AppColors.primary.withValues(alpha: 0.12);
        fg = AppColors.primary;
        label = 'Acceptée';
        break;
      case 'REJECTED':
        bg = AppColors.error.withValues(alpha: 0.10);
        fg = AppColors.error;
        label = 'Refusée';
        break;
      case 'CANCELLED':
        bg = const Color(0xFFE5E7EB);
        fg = const Color(0xFF6B7280);
        label = 'Annulée';
        break;
      case 'PENDING':
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        label = 'En attente';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _EtatVideSection extends StatelessWidget {
  const _EtatVideSection({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.textSubtle),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _fmtDate(DateTime d) => DateFormat('d MMM y', 'fr_FR').format(d);
