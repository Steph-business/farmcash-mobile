import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Gros bouton GPS dominant en haut de l'étape 1 du wizard parcelle.
///
/// Affiche un état "Je suis sur ma parcelle" (vert plein) ou
/// "Position enregistrée" (vert pâle avec coche) selon [captured].
/// Pendant [isLoading], affiche un spinner et désactive le tap.
class BoutonGpsLarge extends StatelessWidget {
  const BoutonGpsLarge({
    required this.captured,
    required this.isLoading,
    required this.onTap,
    super.key,
  });

  final bool captured;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: captured ? const Color(0xFFE8F5E9) : AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary,
              width: captured ? 1 : 0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    color: captured ? AppColors.primary : AppColors.onPrimary,
                  ),
                )
              else
                Icon(
                  captured ? Icons.check_circle : Icons.my_location,
                  size: 26,
                  color: captured ? AppColors.primary : AppColors.onPrimary,
                ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  captured
                      ? 'Position de la parcelle enregistrée'
                      : 'Je suis sur ma parcelle',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: captured ? AppColors.primary : AppColors.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
