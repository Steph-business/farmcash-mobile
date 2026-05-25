import 'package:flutter/material.dart';

import '../../../../models/enums.dart';
import '../../../../models/livraison.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Action secondaire optionnelle sous le bouton principal (ex : annuler
/// la mission), affichée avec un style outline + couleur danger éventuelle.
class ActionSecondaireMission {
  const ActionSecondaireMission({
    required this.label,
    required this.danger,
    required this.onTap,
  });
  final String label;
  final bool danger;
  final VoidCallback onTap;
}

/// Barre d'actions figée en bas de la page détail mission. Affiche le CTA
/// principal selon le statut courant (`Accepter`, `Scanner QR`, `Marquer
/// livrée`, …) et éventuellement une action secondaire (annulation).
class ActionsStickyMission extends StatelessWidget {
  const ActionsStickyMission({
    required this.mission,
    required this.busy,
    required this.onAction,
    super.key,
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

  (String, ShipmentStatus?, ActionSecondaireMission?) _ctaFor(
    ShipmentStatus s,
  ) {
    switch (s) {
      case ShipmentStatus.requested:
        return ('Accepter la mission', ShipmentStatus.accepted, null);
      case ShipmentStatus.accepted:
        return (
          'Scanner le QR producteur',
          ShipmentStatus.loading,
          ActionSecondaireMission(
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
