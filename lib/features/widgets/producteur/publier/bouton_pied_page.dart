import 'package:flutter/material.dart';

import '../../../../theme/app_dimens.dart';
import '../../communs/bouton_principal.dart';

/// Bouton principal collé en bas d'écran avec son padding standard
/// pour les étapes du wizard de publication d'annonce.
///
/// Réutilise [BoutonPrincipal] en ajoutant le padding horizontal et
/// vertical attendu en pied de page du wizard.
class BoutonPiedPage extends StatelessWidget {
  const BoutonPiedPage({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.isLoading = false,
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
