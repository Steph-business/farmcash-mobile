import 'package:flutter/material.dart';

import '../../../models/enums.dart';
import '../../../theme/app_dimens.dart';
import '../communs/barre_recherche_commune.dart';

/// Barre de recherche pour la page Messages.
///
/// Délègue le rendu à [BarreRechercheCommune] pour rester strictement
/// identique aux autres barres de l'app (Marché, Accueil, etc.). Ce
/// wrapper ne porte que le padding latéral (variant acheteur 20 vs.
/// standard `pagePaddingH`) — le reste du style est unifié.
class BarreRechercheMessages extends StatelessWidget {
  const BarreRechercheMessages({
    required this.controller,
    required this.onChanged,
    required this.role,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final UserRole? role;

  @override
  Widget build(BuildContext context) {
    final isAcheteur = role == UserRole.buyer;
    final hPad = isAcheteur ? 20.0 : AppDimens.pagePaddingH;
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 4, hPad, AppDimens.space12),
      child: BarreRechercheCommune(
        placeholder: 'Rechercher une conversation…',
        controller: controller,
        onChanged: onChanged,
      ),
    );
  }
}
