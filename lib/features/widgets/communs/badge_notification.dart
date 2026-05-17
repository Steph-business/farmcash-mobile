import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// Badge rouge avec compteur, posé en haut à droite d'un widget enfant
/// (typiquement une icône). Caché si [count] == 0.
///
/// Conforme DESIGN.md : rouge unique d'alerte, pas d'ombre, pas d'animation.
class BadgeNotification extends StatelessWidget {
  const BadgeNotification({
    required this.child,
    required this.count,
    this.max = 99,
    super.key,
  });

  final Widget child;
  final int count;

  /// Au-delà de [max], affiche `99+`.
  final int max;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;

    final label = count > max ? '$max+' : '$count';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -4,
          top: -2,
          child: Container(
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.background, width: 1.5),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.onError,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
