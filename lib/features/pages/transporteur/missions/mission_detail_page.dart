import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/enums.dart';
import '../../../../models/livraison.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));

/// Bundle mission + tracking events pour la timeline.
class _MissionBundle {
  const _MissionBundle({required this.mission, required this.tracking});
  final Livraison mission;
  final List<TrackingEvent> tracking;
}

/// Le backend n'expose pas de `GET /shipments/:id` direct (V1). On parcourt
/// les missions du transporteur (acceptées) PUIS les disponibles, et on
/// attaque le tracking pour la timeline.
final _missionBundleProvider = FutureProvider.autoDispose
    .family<_MissionBundle?, String>((ref, id) async {
  final svc = ref.read(logisticsServiceProvider);
  // 1. tracking (toujours dispo dès qu'on a l'id).
  final tracking = await svc.getTracking(id).catchError(
        (_) => const <TrackingEvent>[],
      );
  // 2. on cherche dans les missions acceptées du transporteur d'abord
  //    (cas le plus fréquent quand on rentre dans le détail), puis dans
  //    les missions disponibles si elle n'a pas encore été acceptée.
  Livraison? mission;
  try {
    final mine = await svc.getMyMissions();
    for (final m in mine) {
      if (m.id == id) {
        mission = m;
        break;
      }
    }
  } catch (_) {}
  if (mission == null) {
    try {
      final list = await svc.getAvailableMissions();
      for (final m in list) {
        if (m.id == id) {
          mission = m;
          break;
        }
      }
    } catch (_) {}
  }
  mission ??= Livraison(id: id, commandeId: id);
  return _MissionBundle(mission: mission, tracking: tracking);
});

/// Détail d'une mission transporteur — afficher l'état courant + actions
/// (Démarrer chargement, Marquer en route, Marquer livrée, Annuler).
class MissionDetailPage extends ConsumerStatefulWidget {
  const MissionDetailPage({required this.missionId, super.key});

  final String missionId;

  @override
  ConsumerState<MissionDetailPage> createState() => _MissionDetailPageState();
}

class _MissionDetailPageState extends ConsumerState<MissionDetailPage> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_missionBundleProvider(widget.missionId));
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
                    message: 'Impossible de charger la mission. $e',
                    onRetry: () =>
                        ref.invalidate(_missionBundleProvider(widget.missionId)),
                  ),
                ),
              ),
            ],
          ),
          data: (bundle) {
            if (bundle == null) {
              return const Column(
                children: [
                  _Header(),
                  Expanded(
                    child: Center(
                      child: Text('Mission introuvable'),
                    ),
                  ),
                ],
              );
            }
            return _build(bundle);
          },
        ),
      ),
    );
  }

  Widget _build(_MissionBundle bundle) {
    final m = bundle.mission;
    return Column(
      children: [
        const _Header(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            children: [
              _StatutCard(status: m.status),
              AppDimens.vGap16,
              const _SectionTitle('Trajet'),
              AppDimens.vGap8,
              _TrajetCard(mission: m),
              AppDimens.vGap16,
              const _SectionTitle('Marchandise'),
              AppDimens.vGap8,
              _MarchandiseCard(mission: m),
              AppDimens.vGap16,
              const _SectionTitle('Montant'),
              AppDimens.vGap8,
              _MontantCard(mission: m),
              AppDimens.vGap16,
              const _SectionTitle('Suivi'),
              AppDimens.vGap8,
              _TimelineCard(
                status: m.status,
                tracking: bundle.tracking,
              ),
            ],
          ),
        ),
        _StickyAction(
          mission: m,
          busy: _busy,
          onAction: (next) => _transitionner(m, next),
        ),
      ],
    );
  }

  Future<void> _transitionner(
    Livraison mission,
    ShipmentStatus next,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final svc = ref.read(logisticsServiceProvider);
      switch (next) {
        case ShipmentStatus.accepted:
          await svc.acceptShipment(mission.id);
          break;
        case ShipmentStatus.loading:
          // Capture la position GPS au démarrage du chargement (audit
          // pickup côté coop). Optionnel côté backend : on envoie en
          // best-effort, l'absence ne bloque pas la transition.
          final pos = await _getCurrentPosition();
          await svc.startLoading(
            id: mission.id,
            lat: pos?.latitude,
            lng: pos?.longitude,
          );
          break;
        case ShipmentStatus.inTransit:
          // GPS obligatoire côté backend pour `trackPosition` : refuse la
          // transition si on n'arrive pas à le capturer (anti-fraude).
          final pos = await _getCurrentPosition();
          if (pos == null) {
            if (mounted) {
              Snackbars.showErreur(
                context,
                'Position GPS indisponible — active la géoloc pour démarrer le transit.',
              );
            }
            return;
          }
          await svc.trackPosition(
            id: mission.id,
            lat: pos.latitude,
            lng: pos.longitude,
            status: ShipmentStatus.inTransit,
          );
          break;
        case ShipmentStatus.delivered:
          context.push(
            RouteNames.transporteurLivraisonConfirmePathFor(mission.id),
          );
          if (mounted) setState(() => _busy = false);
          return;
        case ShipmentStatus.cancelled:
          await svc.cancelShipment(mission.id);
          break;
        case ShipmentStatus.requested:
        case ShipmentStatus.unknown:
          break;
      }
      ref.invalidate(_missionBundleProvider(widget.missionId));
      if (!mounted) return;
      Snackbars.showSucces(context, 'Mission mise à jour');
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Récupère la position GPS du device en demandant la permission si
  /// besoin. Retourne `null` si géoloc désactivée ou permission refusée
  /// — l'appelant décide si c'est bloquant.
  Future<Position?> _getCurrentPosition() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      return null;
    }
  }
}

// ─── Header ──────────────────────────────────────────────────────────

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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
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
              'Mission',
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

// ─── Section title ──────────────────────────────────────────────────

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

// ─── Statut card ─────────────────────────────────────────────────────

class _StatutCard extends StatelessWidget {
  const _StatutCard({required this.status});
  final ShipmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, sub) = _spec();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: _kBrCard,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.local_shipping_outlined,
              size: 20,
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
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (String, String) _spec() {
    switch (status) {
      case ShipmentStatus.requested:
        return ('Demande en attente', 'Accepte-la pour démarrer la mission');
      case ShipmentStatus.accepted:
        return ('Acceptée', 'Va sur place pour scanner le QR producteur');
      case ShipmentStatus.loading:
        return ('Enlèvement en cours', 'Chargement chez le vendeur');
      case ShipmentStatus.inTransit:
        return ('En route', 'Bonne route vers le destinataire');
      case ShipmentStatus.delivered:
        return ('Livrée', 'En attente de confirmation acheteur');
      case ShipmentStatus.cancelled:
        return ('Annulée', '—');
      case ShipmentStatus.unknown:
        return ('Mission', '—');
    }
  }
}

// ─── Trajet ─────────────────────────────────────────────────────────

class _TrajetCard extends StatelessWidget {
  const _TrajetCard({required this.mission});
  final Livraison mission;
  @override
  Widget build(BuildContext context) {
    final origine = mission.origineZone ?? '—';
    final dest = mission.destinationZone ?? '—';
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
          _row(Icons.trip_origin, AppColors.primary, origine,
              mission.pickupAddress),
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
          _row(Icons.place, AppColors.error, dest, mission.deliveryAddress),
        ],
      ),
    );
  }

  Widget _row(IconData icon, Color color, String titre, String? sous) {
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

// ─── Marchandise ────────────────────────────────────────────────────

class _MarchandiseCard extends StatelessWidget {
  const _MarchandiseCard({required this.mission});
  final Livraison mission;

  @override
  Widget build(BuildContext context) {
    final qte = mission.quantiteKg != null
        ? '${_nf.format(mission.quantiteKg!.round())} kg'
        : 'Quantité non précisée';
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
          const Icon(Icons.scale_outlined, size: 16, color: AppColors.textSubtle),
          const SizedBox(width: 8),
          Text(
            qte,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const Spacer(),
          if (mission.vehicleType != null)
            Text(
              mission.vehicleType!,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Montant ───────────────────────────────────────────────────────

class _MontantCard extends StatelessWidget {
  const _MontantCard({required this.mission});
  final Livraison mission;

  @override
  Widget build(BuildContext context) {
    final prix = mission.prixDevis ?? mission.prixFinal;
    final prixLabel =
        prix != null ? '${_nf.format(prix.round())} F' : 'À fixer';
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
          Expanded(
            child: Text(
              'Rémunération mission',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.text,
              ),
            ),
          ),
          Text(
            prixLabel,
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Timeline ─────────────────────────────────────────────────────

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.status, required this.tracking});
  final ShipmentStatus status;
  final List<TrackingEvent> tracking;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMM HH:mm', 'fr_FR');
    final steps = <_Step>[
      _Step(
        label: 'Mission acceptée',
        done: _atLeast(ShipmentStatus.accepted),
      ),
      _Step(
        label: 'Enlèvement (scan QR)',
        done: _atLeast(ShipmentStatus.loading),
      ),
      _Step(label: 'En route', done: _atLeast(ShipmentStatus.inTransit)),
      _Step(label: 'Livraison effectuée', done: _atLeast(ShipmentStatus.delivered)),
    ];
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
        children: [
          for (var i = 0; i < steps.length; i++)
            _stepLine(steps[i], isLast: i == steps.length - 1),
          if (tracking.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            const SizedBox(height: 8),
            for (final e in tracking.take(5))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.fiber_manual_record,
                      size: 8,
                      color: AppColors.textSubtle,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.note ?? e.status ?? 'Point GPS',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    if (e.createdAt != null)
                      Text(
                        df.format(e.createdAt!),
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 10,
                          color: AppColors.textSubtle,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  bool _atLeast(ShipmentStatus target) {
    const order = [
      ShipmentStatus.requested,
      ShipmentStatus.accepted,
      ShipmentStatus.loading,
      ShipmentStatus.inTransit,
      ShipmentStatus.delivered,
    ];
    final currentIdx = order.indexOf(status);
    final targetIdx = order.indexOf(target);
    if (currentIdx < 0 || targetIdx < 0) return false;
    return currentIdx >= targetIdx;
  }

  Widget _stepLine(_Step s, {required bool isLast}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: s.done ? AppColors.primary : AppColors.surfaceSoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: s.done ? AppColors.primary : AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            alignment: Alignment.center,
            child: s.done
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              s.label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                fontWeight: s.done ? FontWeight.w600 : FontWeight.w400,
                color: s.done ? AppColors.text : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Step {
  const _Step({required this.label, required this.done});
  final String label;
  final bool done;
}

// ─── Sticky action ──────────────────────────────────────────────────

class _StickyAction extends StatelessWidget {
  const _StickyAction({
    required this.mission,
    required this.busy,
    required this.onAction,
  });
  final Livraison mission;
  final bool busy;
  final void Function(ShipmentStatus next) onAction;

  @override
  Widget build(BuildContext context) {
    final (label, next, secondary) = _ctaFor(mission.status);
    if (next == null) {
      return const SizedBox.shrink();
    }
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        children: [
          // Action principale
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: busy ? null : () => onAction(next),
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
                        label,
                        style: AppTextStyles.button.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onPrimary,
                        ),
                      ),
              ),
            ),
          ),
          // Action secondaire (scanner ou annulation selon le statut)
          if (secondary != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: InkWell(
                onTap: busy ? null : secondary.onTap,
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
                    secondary.label,
                    style: AppTextStyles.button.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: secondary.danger
                          ? AppColors.error
                          : AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  (String, ShipmentStatus?, _SecondaryCta?) _ctaFor(ShipmentStatus s) {
    switch (s) {
      case ShipmentStatus.requested:
        return ('Accepter la mission', ShipmentStatus.accepted, null);
      case ShipmentStatus.accepted:
        // Action principale : scanner le QR producteur.
        return (
          'Scanner le QR producteur',
          ShipmentStatus.loading,
          _SecondaryCta(
            label: 'Annuler la mission',
            danger: true,
            onTap: () {},
          ),
        );
      case ShipmentStatus.loading:
        return ('Marquer en route', ShipmentStatus.inTransit, null);
      case ShipmentStatus.inTransit:
        return ('Marquer livrée', ShipmentStatus.delivered, null);
      case ShipmentStatus.delivered:
      case ShipmentStatus.cancelled:
      case ShipmentStatus.unknown:
        return ('', null, null);
    }
  }
}

class _SecondaryCta {
  const _SecondaryCta({
    required this.label,
    required this.danger,
    required this.onTap,
  });
  final String label;
  final bool danger;
  final VoidCallback onTap;
}

final _nf = NumberFormat('#,##0', 'fr_FR');
