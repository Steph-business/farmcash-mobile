import 'package:flutter/material.dart';

import '../../../../models/membre_coop.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import 'ligne_membre.dart';

/// Carte regroupant la liste des membres avec séparateurs.
class CarteListeMembres extends StatelessWidget {
  const CarteListeMembres({
    super.key,
    required this.members,
    required this.onTap,
  });

  /// Membres à afficher dans la carte.
  final List<MembreCoop> members;

  /// Action exécutée au tap sur un membre.
  final ValueChanged<MembreCoop> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          for (var i = 0; i < members.length; i++) ...[
            LigneMembre(
              membre: members[i],
              onTap: () => onTap(members[i]),
            ),
            if (i < members.length - 1)
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
