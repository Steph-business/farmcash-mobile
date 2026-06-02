import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Mini-carte décorative montrant un trajet origine→destination.
///
/// Pour V1 c'est un placeholder visuel (CustomPaint d'une route stylisée
/// + deux marqueurs) car le backend ne renvoie pas encore les positions
/// GPS jointes au commande. Le but est purement indicatif : "il y a un
/// tracking disponible, tape pour voir le détail".
///
/// Quand le backend exposera `GET /shipments/by-commande/:id` avec les
/// derniers events GPS, on remplacera ce widget par un vrai `FlutterMap`
/// embarqué.
class MiniCarteTrajet extends StatelessWidget {
  /// Construit la mini-carte.
  const MiniCarteTrajet({super.key, this.hauteur = 130});

  /// Hauteur de la carte (par défaut 130px — suffisamment haut pour être
  /// lisible, sans empiéter sur le reste).
  final double hauteur;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(14),
      ),
      child: Container(
        height: hauteur,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surfaceSoft,
              const Color(0xFFE8F5E9),
              AppColors.surfaceSoft,
            ],
          ),
        ),
        child: CustomPaint(
          painter: _TrajetPainter(),
          child: Stack(
            children: const [
              Positioned(
                left: 32,
                bottom: 28,
                child: _Pin(couleur: AppColors.primary),
              ),
              Positioned(
                right: 32,
                top: 18,
                child: _Pin(couleur: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({required this.couleur});
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: couleur,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: couleur.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.place,
        size: 14,
        color: Colors.white,
      ),
    );
  }
}

/// Trace une route stylisée (Bezier) entre les deux pins. Évoque la
/// notion de trajet sans avoir besoin de vraies coordonnées GPS.
class _TrajetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Léger fond beige représentant des routes parallèles secondaires.
    final paintSecondaire = Paint()
      ..color = AppColors.borderStrong.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Quelques traits décoratifs pour évoquer un fond de carte.
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.4),
      paintSecondaire,
    );
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.4, size.height),
      paintSecondaire,
    );

    // Tracé principal (Bezier) — du pin gauche au pin droit.
    final path = Path()
      ..moveTo(44, size.height - 28)
      ..cubicTo(
        size.width * 0.5,
        size.height * 0.95,
        size.width * 0.35,
        size.height * 0.15,
        size.width - 44,
        30,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrajetPainter oldDelegate) => false;
}
