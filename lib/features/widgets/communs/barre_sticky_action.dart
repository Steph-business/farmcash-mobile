import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';

/// Wrapper sticky bottom standardisé pour tous les CTAs flottants du
/// système (paiement, candidature, créer prévision, marquer expédié,
/// QR enlèvement, etc.).
///
/// Avant ce widget, chaque page redéfinissait son propre Container
/// + border-top + padding, avec des incohérences :
///   - SafeArea bottom souvent oubliée → le bouton touchait le home
///     indicator iPhone (mauvaise zone de tap, look brut)
///   - Shadow inexistante → impression de "trait de séparation" pauvre
///   - Padding variant entre 8 et 16 selon les pages
///
/// Ce wrapper centralise :
///   - **Border-top** subtile + **shadow soft** au-dessus (effet plateau
///     flottant premium, type Stripe / Apple Maps)
///   - **SafeArea bottom** obligatoire (iPhone notch + home indicator)
///   - **Padding horizontal 16** + **vertical 14/12** + minimum 8 bottom
///   - **Background** AppColors.background pour ne pas chevaucher
///
/// Usage :
/// ```dart
/// BarreStickyAction(
///   child: ElevatedButton(...),  // ou n'importe quel CTA
/// )
/// ```
///
/// Pour les barres avec plusieurs lignes (CTA + lien secondaire), passer
/// un Column comme child — il gère le mainAxisSize.min tout seul.
class BarreStickyAction extends StatelessWidget {
  const BarreStickyAction({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 12),
  });

  final Widget child;

  /// Padding interne avant la SafeArea. Override si tu veux serrer
  /// (ex: les pages avec un Column dense).
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        // Shadow soft top → effet plateau flottant qui décolle le sticky
        // du contenu scrollable au-dessus. Subtil pour ne pas alourdir.
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        // Minimum bottom 8 pour respiration même quand pas de home
        // indicator (Android, iPad). Sur iPhone notch + indicator, le
        // padding réel sera ~34 (system insets).
        minimum: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// CTA primaire plein largeur à utiliser dans une `BarreStickyAction`.
/// Style cohérent partout : vert primary, radius 14, hauteur 56, ripple
/// Material visible au tap, icône + texte centrés.
///
/// Pour un bouton secondaire (annuler, retour…) utiliser un `TextButton`
/// natif, pas ce widget.
class BoutonStickyPrincipal extends StatelessWidget {
  const BoutonStickyPrincipal({
    super.key,
    required this.label,
    required this.onTap,
    this.icone,
    this.busy = false,
    this.couleur,
  });

  final String label;
  final IconData? icone;
  final VoidCallback? onTap;
  final bool busy;

  /// Override de la couleur de fond. Par défaut : AppColors.primary.
  /// Utile pour les actions destructives (rouge) ou warning (ambre).
  final Color? couleur;

  @override
  Widget build(BuildContext context) {
    final bg = couleur ?? AppColors.primary;
    final enabled = onTap != null && !busy;
    return SizedBox(
      width: double.infinity,
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 56,
              child: Center(
                child: busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icone != null) ...[
                            Icon(icone, size: 20, color: Colors.white),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            label,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
