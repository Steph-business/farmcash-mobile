import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/snackbars.dart';

const Color _kBg = Color(0xFF1A1A1A);
const String _kDemoMissionId = 'M-2026-0089';

/// Scanner QR placeholder (caméra non câblée).
/// Tap sur le cadre central → navigue vers la page de confirmation
/// d'enlèvement pour la mission de démo.
class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Stack(
          children: [
            // ─── Header : croix de fermeture ────────────────────────
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),

            // ─── Cadre central ──────────────────────────────────────
            Center(
              child: GestureDetector(
                onTap: () => context.push(
                  RouteNames.transporteurEnlevementConfirmePathFor(
                      _kDemoMissionId),
                ),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    children: [
                      // 4 coins verts
                      _Corner(top: 0, left: 0, top1: true, left1: true),
                      _Corner(top: 0, right: 0, top1: true, right1: true),
                      _Corner(bottom: 0, left: 0, bottom1: true, left1: true),
                      _Corner(
                          bottom: 0, right: 0, bottom1: true, right1: true),
                      // Ligne horizontale verte au milieu
                      const Positioned(
                        left: 0,
                        right: 0,
                        top: 119,
                        child: SizedBox(
                          height: 2,
                          child: ColoredBox(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Texte sous le cadre ────────────────────────────────
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 320),
                child: Text(
                  'Pointe la caméra vers le QR du producteur',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // ─── Boutons Flash + Galerie ───────────────────────────
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CircleBtn(
                      icon: Icons.flash_on,
                      onTap: () =>
                          Snackbars.showInfo(context, 'Flash — à venir'),
                    ),
                    const SizedBox(width: 28),
                    _CircleBtn(
                      icon: Icons.image_outlined,
                      onTap: () =>
                          Snackbars.showInfo(context, 'Galerie — à venir'),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Lien saisie manuelle ───────────────────────────────
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: TextButton(
                  onPressed: () => Snackbars.showInfo(
                      context, 'Saisie manuelle — à venir'),
                  child: Text(
                    'Saisir le code manuellement',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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

// ─── Coin du cadre (L) ───────────────────────────────────────────────────

class _Corner extends StatelessWidget {
  const _Corner({
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.top1 = false,
    this.bottom1 = false,
    this.left1 = false,
    this.right1 = false,
  });

  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final bool top1;
  final bool bottom1;
  final bool left1;
  final bool right1;

  @override
  Widget build(BuildContext context) {
    const side = BorderSide(color: AppColors.primary, width: 3);
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border(
            top: top1 ? side : BorderSide.none,
            bottom: bottom1 ? side : BorderSide.none,
            left: left1 ? side : BorderSide.none,
            right: right1 ? side : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ─── Bouton circulaire (Flash / Galerie) ────────────────────────────────

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 22, color: Colors.white),
      ),
    );
  }
}
