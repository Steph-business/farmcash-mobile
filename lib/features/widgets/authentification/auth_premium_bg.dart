import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// Fond mesh-gradient premium pour les écrans d'authentification.
///
/// Trois blobs radiaux superposés (vert primary + warm tint) qui se
/// fondent dans le fond blanc. Imite un mesh gradient sans dépendre
/// d'un asset image — léger pour les terrains à faible bande passante.
///
/// À placer en premier dans un `Stack` (`Positioned.fill` y est déjà
/// fait dans le widget), puis le contenu de la page par-dessus.
class AuthPremiumBg extends StatelessWidget {
  const AuthPremiumBg({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            // Base blanche.
            const ColoredBox(color: AppColors.background),

            // Blob 1 — vert primary saturé en haut-droite : signal
            // brand fort dès le 1er coup d'œil.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(1.05, -0.75),
                    radius: 1.1,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.22),
                      AppColors.primary.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.35, 1.0],
                  ),
                ),
              ),
            ),

            // Blob 2 — vert très doux en bas-gauche : équilibre la
            // composition, donne de la matière à la zone CTA.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-1.0, 1.0),
                    radius: 1.0,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.10),
                      AppColors.primary.withValues(alpha: 0.02),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),

            // Blob 3 — touche orange chaud très diluée au centre :
            // rappelle le drapeau CI sans crier, casse la monochromie.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.4, 0.3),
                    radius: 1.4,
                    colors: [
                      const Color(0xFFF77F00).withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6],
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
