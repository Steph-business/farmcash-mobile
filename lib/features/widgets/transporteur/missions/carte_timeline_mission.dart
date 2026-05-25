import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/enums.dart';
import '../../../../models/livraison.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));

/// Une étape de la timeline (libellé + état coché ou non).
class _EtapeMission {
  const _EtapeMission({required this.label, required this.done});
  final String label;
  final bool done;
}

/// Carte « Suivi » du détail mission : 4 étapes principales (acceptation,
/// enlèvement, transit, livraison) puis jusqu'à 5 derniers événements GPS
/// remontés par le backend (`TrackingEvent`).
class CarteTimelineMission extends StatelessWidget {
  const CarteTimelineMission({
    required this.status,
    required this.tracking,
    super.key,
  });
  final ShipmentStatus status;
  final List<TrackingEvent> tracking;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMM HH:mm', 'fr_FR');
    final steps = <_EtapeMission>[
      _EtapeMission(
        label: 'Mission acceptée',
        done: _atLeast(ShipmentStatus.accepted),
      ),
      _EtapeMission(
        label: 'Enlèvement (scan QR)',
        done: _atLeast(ShipmentStatus.loading),
      ),
      _EtapeMission(label: 'En route', done: _atLeast(ShipmentStatus.inTransit)),
      _EtapeMission(label: 'Livraison effectuée', done: _atLeast(ShipmentStatus.delivered)),
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

  Widget _stepLine(_EtapeMission s, {required bool isLast}) {
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
