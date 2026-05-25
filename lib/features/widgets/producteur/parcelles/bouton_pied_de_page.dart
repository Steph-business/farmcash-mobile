import 'package:flutter/material.dart';

import '../../../../theme/app_dimens.dart';
import '../../communs/bouton_principal.dart';

/// Bouton principal d'action en pied de page du wizard de création de
/// parcelle (étapes "Suivant" / "Enregistrer ma parcelle").
///
/// Wrap [BoutonPrincipal] avec le padding horizontal/vertical standard
/// utilisé sur toutes les étapes du wizard.
class BoutonPiedDePage extends StatelessWidget {
  const BoutonPiedDePage({
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space12,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      child: BoutonPrincipal(
        label: label,
        isLoading: isLoading,
        enabled: enabled,
        onPressed: enabled ? onTap : null,
      ),
    );
  }
}
