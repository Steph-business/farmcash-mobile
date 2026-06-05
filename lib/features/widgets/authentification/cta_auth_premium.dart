import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Bouton CTA premium pour les écrans d'authentification.
///
/// Hauteur 58, fond vert primary, **shadow vert diffuse** sous le bouton
/// (effet « flottant »), label centré, **puce flèche** à droite — pattern
/// Revolut/Apple. Supporte les états disabled (gris) et loading (spinner
/// à la place du label, flèche masquée).
class CtaAuthPremium extends StatelessWidget {
  const CtaAuthPremium({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final disabled = !enabled || loading || onTap == null;
    final bg = disabled ? AppColors.borderStrong : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: disabled
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.30),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 58,
            child: Row(
              children: [
                // Espaceur gauche (symétrie face à la puce flèche).
                const SizedBox(width: 56),
                Expanded(
                  child: loading
                      ? const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          label,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.button.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: disabled
                                ? AppColors.textSubtle
                                : Colors.white,
                            letterSpacing: 0.1,
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: loading ? 0 : 1,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
