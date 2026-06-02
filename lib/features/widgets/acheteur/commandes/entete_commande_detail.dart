import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Header de la page de détail commande côté acheteur. Affiche un titre
/// simple « Commande » au centre et un bouton retour à gauche.
///
/// La référence longue (ex: `#ORD-1779742258490-77b4`) n'est PLUS affichée
/// ici — elle reste disponible dans le résumé déplié et dans la sticky
/// info en pied. Le titre garde la page lisible et propre.
///
/// Fallback important côté navigation : si l'utilisateur arrive ici via
/// `context.go(...)` depuis la page succès (qui remplace la stack),
/// `context.canPop()` renvoie `false`. On route alors vers la liste
/// « Mes commandes » pour toujours offrir une issue claire — pas de
/// bouton retour inactif.
class EnteteCommandeDetail extends StatelessWidget {
  const EnteteCommandeDetail({
    this.reference = '',
    super.key,
  });

  /// Conservé pour compat API mais non affiché — la longue ref encombrait
  /// le header.
  final String reference;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RouteNames.acheteurCommandesPath);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Commande',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
