import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Logo « FarmCash » premium : pastille carrée verte avec halo doux
/// (effet « app icon ») + wordmark Poppins ExtraBold.
///
/// Variantes :
///   • `compact: false` (défaut) — pastille 38, texte 22, utilisé en
///     tête des écrans d'auth.
///   • `compact: true` — pastille 30, texte 18, pour les barres de nav
///     ou les écrans plus denses (inscription).
class LogoFarmcash extends StatelessWidget {
  const LogoFarmcash({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final pastilleSize = compact ? 30.0 : 38.0;
    final iconSize = compact ? 18.0 : 22.0;
    final textSize = compact ? 18.0 : 22.0;
    final radius = compact ? 9.0 : 11.0;
    final gap = compact ? 10.0 : 12.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: pastilleSize,
          height: pastilleSize,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: compact ? 10 : 14,
                offset: Offset(0, compact ? 4 : 5),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(Icons.eco, size: iconSize, color: Colors.white),
        ),
        SizedBox(width: gap),
        Text(
          'FarmCash',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            fontSize: textSize,
          ),
        ),
      ],
    );
  }
}
