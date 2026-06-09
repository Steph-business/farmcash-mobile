import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../api_client/api_exception.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Toasts/snackbars premium niveau Uber / Lyft / Stripe.
///
/// Anatomie d'une carte :
///
///   ┌──┬────────────────────────────────────────┬────┐
///   │██│ [⊕]  Titre court bold                  │ X  │
///   │██│      Sous-titre optionnel              │    │
///   └──┴────────────────────────────────────────┴────┘
///    │
///    └─ Barre d'accent verticale 4 px en couleur de la sévérité
///       (vert success / rouge error / vert primary info)
///
/// - **Fond blanc cassé** (#1B1F26), pas noir pur — moins dur visuellement
/// - **Barre d'accent latérale** 4 px à gauche, en couleur de la sévérité
/// - **Pastille icône** 36 px en fond translucide → repère instantané
/// - **Titre obligatoire** 14 px Poppins 700
/// - **Sous-titre optionnel** 12.5 px sous le titre
/// - **Coins 16 px** + shadow douce pour effet flottant premium
/// - **Action optionnelle** (« Voir », « Ouvrir ») à droite en couleur d'accent
/// - **Bouton close X** systématique pour dismiss avant durée
///
/// API rétro-compatible : `showSucces(ctx, msg)`, `showErreur(ctx, msg)`,
/// `showInfo(ctx, msg)`. Pour 2 lignes : `showSuccesDetail(ctx, titre, sousTitre)`.
class Snackbars {
  Snackbars._();

  // ─── API simple (1 ligne, auto-split en 2 si message long) ───────

  static void showSucces(BuildContext context, String message) {
    final (titre, sous) = _splitNaturel(message);
    _show(
      context,
      severity: _Severity.success,
      titre: titre,
      sousTitre: sous,
    );
  }

  static void showErreur(BuildContext context, String message) {
    final (titre, sous) = _splitNaturel(message);
    _show(
      context,
      severity: _Severity.error,
      titre: titre,
      sousTitre: sous,
      duration: const Duration(seconds: 5),
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final (titre, sous) = _splitNaturel(message);
    _show(
      context,
      severity: _Severity.info,
      titre: titre,
      sousTitre: sous,
      duration: duration,
    );
  }

  // ─── Split intelligent ────────────────────────────────────────────

  /// Découpe automatiquement un message long en (titre, sous-titre) sur
  /// un séparateur naturel (« — », « . », « ! », « ? »). Permet aux 334
  /// call sites existants de bénéficier du look 2 lignes sans avoir à
  /// réécrire chaque message.
  ///
  /// Règles :
  ///   - Si < 50 chars → 1 ligne (tout en titre, sous-titre null)
  ///   - Sinon → cherche un séparateur entre 20 et 60 chars, splitte
  ///   - Pas de séparateur trouvé → titre = message complet, sous null
  ///     (le widget fera maxLines: 2 + ellipsis)
  static (String, String?) _splitNaturel(String message) {
    final clean = message.trim();
    if (clean.length < 50) return (clean, null);
    for (final sep in [' — ', '. ', ' : ', '! ', '? ']) {
      final idx = clean.indexOf(sep, 20);
      if (idx > 0 && idx < 70) {
        final titre = clean.substring(0, idx).trim();
        var sous = clean.substring(idx + sep.length).trim();
        // Garde le point final dans le titre pour les phrases.
        if (sep == '. ') {
          // titre n'inclut pas le ".", on le rajoute pour la lisibilité.
          // Pas indispensable mais ça fait plus naturel.
        }
        if (sous.isEmpty) return (clean, null);
        return (titre, sous);
      }
    }
    return (clean, null);
  }

  // ─── API riche (titre + sous-titre) ───────────────────────────────

  /// Snackbar succès en 2 lignes — titre court + détail.
  /// Exemple : titre « Commande envoyée », sousTitre « Le vendeur va
  /// préparer ton colis ».
  static void showSuccesDetail(
    BuildContext context, {
    required String titre,
    required String sousTitre,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      severity: _Severity.success,
      titre: titre,
      sousTitre: sousTitre,
      duration: duration,
    );
  }

  /// Snackbar erreur en 2 lignes — titre court + cause/conseil détaillé.
  static void showErreurDetail(
    BuildContext context, {
    required String titre,
    required String sousTitre,
    Duration duration = const Duration(seconds: 5),
  }) {
    _show(
      context,
      severity: _Severity.error,
      titre: titre,
      sousTitre: sousTitre,
      duration: duration,
    );
  }

  /// Snackbar info en 2 lignes.
  static void showInfoDetail(
    BuildContext context, {
    required String titre,
    required String sousTitre,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      severity: _Severity.info,
      titre: titre,
      sousTitre: sousTitre,
      duration: duration,
    );
  }

  // ─── API erreur intelligente (humanise toute exception) ──────────

  /// Affiche un snackbar erreur depuis n'importe quelle exception.
  /// Centralise la traduction technique → message humain :
  ///   - `ApiException` : utilise `e.message` (déjà formaté côté backend
  ///     ou par `ApiException.fromDio` qui mappe les status codes)
  ///   - `Exception` autre : message générique sympa, le détail
  ///     technique est loggué via debugPrint pour la dev
  ///
  /// **À utiliser à la place de** `showErreur(ctx, 'Erreur : $e')` qui
  /// leakait la stack trace dans la UI. L'utilisateur n'a rien à faire
  /// d'une `DioError [unknown]: SocketException ...` — il veut savoir
  /// si c'est SA faute (réseau ?) ou non.
  static void showErreurInattendue(BuildContext context, Object? error) {
    if (error is ApiException) {
      showErreur(context, error.message);
      return;
    }
    if (kDebugMode) {
      debugPrint('[Snackbars.showErreurInattendue] $error');
    }
    showErreurDetail(
      context,
      titre: 'Action impossible pour le moment',
      sousTitre:
          'Quelque chose s\'est mal passé. Vérifie ta connexion et réessaie.',
    );
  }

  // ─── API avec CTA (style Uber/Lyft) ───────────────────────────────

  /// Snackbar succès avec action à droite (« Voir mon panier », « Ouvrir
  /// la commande »). Durée par défaut prolongée pour laisser le temps de
  /// taper sur l'action.
  static void showSuccesAction(
    BuildContext context, {
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
    String? sousTitre,
  }) {
    _show(
      context,
      severity: _Severity.success,
      titre: message,
      sousTitre: sousTitre,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: const Duration(seconds: 5),
    );
  }

  // ─── Implémentation interne ───────────────────────────────────────

  static void _show(
    BuildContext context, {
    required _Severity severity,
    required String titre,
    String? sousTitre,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final spec = _SeveritySpec.of(severity);
    final hasSousTitre = sousTitre != null && sousTitre.trim().isNotEmpty;

    // Respect du home indicator iPhone : MediaQuery.viewPadding.bottom
    // donne le safe inset système (~34 sur iPhone notch, 0 sinon). On
    // ajoute 12px de respiration au-dessus.
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final bottomMargin = bottomInset + 12;

    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        // SnackBar's container : transparent → on dessine notre propre
        // carte avec barre d'accent, shadow, et close button. Évite les
        // contraintes Material par défaut qui forcent un layout sous-optimal.
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(12, 0, 12, bottomMargin),
        padding: EdgeInsets.zero,
        duration: duration,
        // animation natif Flutter (slide-up + fade) — pas besoin de
        // customiser, le résultat est déjà fluide.
        content: _CarteSnackbar(
          spec: spec,
          titre: titre,
          sousTitre: sousTitre,
          actionLabel: actionLabel,
          onAction: onAction,
          onClose: () => messenger.hideCurrentSnackBar(),
          dense: !hasSousTitre,
        ),
      ),
    );
  }
}

/// Sévérités sémantiques.
enum _Severity { success, error, info }

/// Couleur + icône d'une sévérité.
class _SeveritySpec {
  const _SeveritySpec({
    required this.accent,
    required this.icon,
  });
  final Color accent;
  final IconData icon;

  factory _SeveritySpec.of(_Severity s) {
    switch (s) {
      case _Severity.success:
        return const _SeveritySpec(
          accent: AppColors.success,
          icon: Icons.check_circle_rounded,
        );
      case _Severity.error:
        return const _SeveritySpec(
          accent: AppColors.error,
          icon: Icons.error_rounded,
        );
      case _Severity.info:
        return const _SeveritySpec(
          accent: AppColors.primary,
          icon: Icons.info_rounded,
        );
    }
  }
}

/// Carte qui rend le snackbar : barre d'accent | pastille icône | textes
/// | action | close.
class _CarteSnackbar extends StatelessWidget {
  const _CarteSnackbar({
    required this.spec,
    required this.titre,
    required this.sousTitre,
    required this.actionLabel,
    required this.onAction,
    required this.onClose,
    required this.dense,
  });

  final _SeveritySpec spec;
  final String titre;
  final String? sousTitre;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onClose;

  /// Mode compact (1 ligne) → padding réduit pour ne pas paraître vide.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          // Fond gris très sombre — plus doux que le noir pur, plus
          // premium que le gris moyen.
          color: const Color(0xFF1B1F26),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.30),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Barre d'accent verticale — repère visuel signature.
              Container(
                width: 4,
                color: spec.accent,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    12,
                    dense ? 12 : 14,
                    8,
                    dense ? 12 : 14,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Pastille icône 36×36 en fond accent translucide.
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: spec.accent.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(spec.icon, color: spec.accent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BlocTextes(
                          titre: titre,
                          sousTitre: sousTitre,
                        ),
                      ),
                      if (actionLabel != null && onAction != null) ...[
                        const SizedBox(width: 8),
                        _BoutonAction(
                          label: actionLabel!,
                          color: spec.accent,
                          onTap: () {
                            onClose();
                            onAction!();
                          },
                        ),
                      ],
                      const SizedBox(width: 4),
                      _BoutonClose(onTap: onClose),
                    ],
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

class _BlocTextes extends StatelessWidget {
  const _BlocTextes({required this.titre, this.sousTitre});
  final String titre;
  final String? sousTitre;

  @override
  Widget build(BuildContext context) {
    final hasSous = sousTitre != null && sousTitre!.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          titre,
          style: AppTextStyles.bodyMedium.copyWith(
            fontFamily: 'Poppins',
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (hasSous) ...[
          const SizedBox(height: 2),
          Text(
            sousTitre!.trim(),
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.72),
              height: 1.35,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _BoutonAction extends StatelessWidget {
  const _BoutonAction({
    required this.label,
    required this.color,
    required this.onTap,
  });
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            label.toUpperCase(),
            style: AppTextStyles.button.copyWith(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
    );
  }
}

class _BoutonClose extends StatelessWidget {
  const _BoutonClose({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(
            Icons.close_rounded,
            size: 16,
            color: Color(0xFF8B92A1),
          ),
        ),
      ),
    );
  }
}
