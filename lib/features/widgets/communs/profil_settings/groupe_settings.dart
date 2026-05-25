import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';

/// Rayon de bordure des cartes des groupes (style iOS Settings, 12px).
const BorderRadius kRayonGroupeSettings =
    BorderRadius.all(Radius.circular(12));

/// Carte englobante qui regroupe plusieurs tuiles (rows) du pattern
/// "Profil & paramètres".
///
/// Trace un fond + bordure + arrondi 12px (iOS Settings), insère un
/// [Divider] 1px entre chaque ligne, et clippe le contenu pour que les
/// `InkWell` respectent l'arrondi.
class GroupeSettings extends StatelessWidget {
  /// Construit le groupe avec la liste de ses lignes.
  const GroupeSettings({super.key, required this.rows});

  /// Lignes du groupe (typiquement des [TuileSettings]).
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: kRayonGroupeSettings,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.border,
              ),
          ],
        ],
      ),
    );
  }
}
