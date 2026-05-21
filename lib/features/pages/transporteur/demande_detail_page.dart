import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/livraison.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/communs/vue_erreur.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));

/// Charge la mission depuis la liste disponible (le back n'expose pas de
/// GET unitaire shipment côté transporteur — on filtre la liste).
final _demandeProvider = FutureProvider.autoDispose
    .family<Livraison?, String>((ref, id) async {
  final list = await ref.read(logisticsServiceProvider).getAvailableMissions();
  for (final m in list) {
    if (m.id == id) return m;
  }
  return null;
});

/// Détail d'une demande de transport entrante — vue avant acceptation.
/// Le CTA "Accepter" appelle `acceptShipment` (first-arrived first-served).
class DemandeDetailPage extends ConsumerStatefulWidget {
  const DemandeDetailPage({required this.demandeId, super.key});

  final String demandeId;

  @override
  ConsumerState<DemandeDetailPage> createState() => _DemandeDetailPageState();
}

class _DemandeDetailPageState extends ConsumerState<DemandeDetailPage> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_demandeProvider(widget.demandeId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              _Header(),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const _Header(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la demande. $e',
                    onRetry: () =>
                        ref.invalidate(_demandeProvider(widget.demandeId)),
                  ),
                ),
              ),
            ],
          ),
          data: (m) {
            if (m == null) {
              return Column(
                children: [
                  const _Header(),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                        child: Text(
                          'Cette demande n\'est plus disponible.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: [
                const _Header(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                    children: [
                      _EmetteurCard(mission: m),
                      AppDimens.vGap16,
                      const _SectionTitle('Marchandise'),
                      AppDimens.vGap8,
                      _MarchandiseCard(mission: m),
                      AppDimens.vGap16,
                      const _SectionTitle('Trajet'),
                      AppDimens.vGap8,
                      _TrajetCard(mission: m),
                      AppDimens.vGap16,
                      const _SectionTitle('Montant'),
                      AppDimens.vGap8,
                      _MontantCard(mission: m),
                      if (m.notes != null && m.notes!.trim().isNotEmpty) ...[
                        AppDimens.vGap16,
                        const _SectionTitle('Notes'),
                        AppDimens.vGap8,
                        _NotesCard(notes: m.notes!),
                      ],
                    ],
                  ),
                ),
                _StickyActions(
                  busy: _busy,
                  onRefuser: () => Navigator.of(context).maybePop(),
                  onAccepter: () => _accepter(m),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _accepter(Livraison mission) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(logisticsServiceProvider).acceptShipment(mission.id);
      if (!mounted) return;
      Snackbars.showSucces(context, 'Mission acceptée');
      // Recharge la liste pour que la mission disparaisse des disponibles.
      ref.invalidate(_demandeProvider(widget.demandeId));
      context.go(RouteNames.transporteurMissionDetailPathFor(mission.id));
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

// ─── Header ───────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Détail de la demande',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section title ───────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: AppColors.text,
        ),
      ),
    );
  }
}

// ─── Émetteur ────────────────────────────────────────────────────────

class _EmetteurCard extends StatelessWidget {
  const _EmetteurCard({required this.mission});
  final Livraison mission;

  @override
  Widget build(BuildContext context) {
    final reference = mission.reference ??
        mission.commandeId.substring(0, 8).toUpperCase();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.assignment_outlined,
              size: 22,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Commande #$reference',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Demande de transport publique',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Marchandise ─────────────────────────────────────────────────────

class _MarchandiseCard extends StatelessWidget {
  const _MarchandiseCard({required this.mission});
  final Livraison mission;

  @override
  Widget build(BuildContext context) {
    final qte = mission.quantiteKg != null
        ? '${_nf.format(mission.quantiteKg!.round())} kg'
        : 'Quantité non précisée';
    final vehicleType = mission.vehicleType;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(Icons.scale_outlined, qte),
          if (vehicleType != null && vehicleType.isNotEmpty) ...[
            const SizedBox(height: 8),
            _row(Icons.local_shipping_outlined, 'Véhicule : $vehicleType'),
          ],
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSubtle),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Trajet ──────────────────────────────────────────────────────────

class _TrajetCard extends StatelessWidget {
  const _TrajetCard({required this.mission});
  final Livraison mission;

  @override
  Widget build(BuildContext context) {
    final origine = mission.origineZone ?? '—';
    final dest = mission.destinationZone ?? '—';
    final pickup = mission.pickupAddress;
    final delivery = mission.deliveryAddress;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _line(
            icon: Icons.trip_origin,
            color: AppColors.primary,
            titre: origine,
            sous: pickup,
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 7),
            child: SizedBox(
              width: 2,
              height: 18,
              child: ColoredBox(color: AppColors.border),
            ),
          ),
          const SizedBox(height: 10),
          _line(
            icon: Icons.place,
            color: AppColors.error,
            titre: dest,
            sous: delivery,
          ),
        ],
      ),
    );
  }

  Widget _line({
    required IconData icon,
    required Color color,
    required String titre,
    String? sous,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                titre,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (sous != null && sous.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  sous,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Montant ─────────────────────────────────────────────────────────

class _MontantCard extends StatelessWidget {
  const _MontantCard({required this.mission});
  final Livraison mission;

  @override
  Widget build(BuildContext context) {
    final prix = mission.prixDevis ?? mission.prixFinal;
    final prixLabel =
        prix != null ? '+${_nf.format(prix.round())} F' : 'À négocier';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.payments_outlined,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Rémunération transporteur',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            prixLabel,
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Notes ──────────────────────────────────────────────────────────

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes});
  final String notes;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Text(
        notes,
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 12,
          color: AppColors.text,
          height: 1.5,
        ),
      ),
    );
  }
}

// ─── Sticky actions ────────────────────────────────────────────────

class _StickyActions extends StatelessWidget {
  const _StickyActions({
    required this.busy,
    required this.onRefuser,
    required this.onAccepter,
  });
  final bool busy;
  final VoidCallback onRefuser;
  final VoidCallback onAccepter;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: busy ? null : onRefuser,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.borderStrong,
                    width: AppDimens.borderThin,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Refuser',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: busy ? null : onAccepter,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Accepter',
                        style: AppTextStyles.button.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onPrimary,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final _nf = NumberFormat('#,##0', 'fr_FR');
