import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Toasts/snackbars personnalisés style apps pro (Uber, Jumia, Amazon).
///
/// Chaque snackbar a :
///   - une **icône colorée** à gauche (✓ succès, ✕ erreur, ℹ info)
///   - un **fond sombre** avec bord arrondi élégant
///   - une **action optionnelle** à droite (ex: « Voir mon panier »)
///   - position **flottante en bas**, marges horizontales pour ne pas
///     toucher les bords
///
/// API stable rétro-compatible : les anciennes méthodes
/// `showSucces`, `showErreur`, `showInfo` continuent de marcher.
class Snackbars {
  Snackbars._();

  // ─── API existante (rétro-compatible) ────────────────────────────

  static void showSucces(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle,
      accent: AppColors.success,
    );
  }

  static void showErreur(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.error_outline,
      accent: AppColors.error,
    );
  }

  /// Snackbar info — accent bleu primaire. Le paramètre `duration` reste
  /// optionnel : la valeur par défaut (3 s) couvre tous les cas standards
  /// (« à venir », info brève). Pour un loader (ex : upload en cours),
  /// passer une durée plus longue (5-10 s) et appeler
  /// `ScaffoldMessenger.of(context).hideCurrentSnackBar()` à la fin.
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      icon: Icons.info_outline,
      accent: AppColors.primary,
      duration: duration,
    );
  }

  // ─── Variantes avec CTA (style Uber/Jumia) ────────────────────────

  /// Snackbar de succès avec une **action** (ex: « Voir mon panier »).
  /// Reste affiché plus longtemps (5s) pour laisser le temps de taper
  /// sur l'action avant qu'il disparaisse.
  static void showSuccesAction(
    BuildContext context, {
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle,
      accent: AppColors.success,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: const Duration(seconds: 5),
    );
  }

  // ─── Implémentation interne ───────────────────────────────────────

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color accent,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        elevation: 6,
        // Fond sombre élégant — comme les apps pro.
        backgroundColor: const Color(0xFF1F2937),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: duration,
        content: Row(
          children: [
            // Pastille icône en couleur d'accent (vert succès, rouge
            // erreur, bleu info) → repère visuel instantané.
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: accent, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13.5,
                  color: Colors.white,
                  height: 1.35,
                ),
              ),
            ),
            // Action optionnelle (ex: « Voir mon panier »).
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  messenger.hideCurrentSnackBar();
                  onAction();
                },
                style: TextButton.styleFrom(
                  foregroundColor: accent,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  actionLabel.toUpperCase(),
                  style: AppTextStyles.button.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
