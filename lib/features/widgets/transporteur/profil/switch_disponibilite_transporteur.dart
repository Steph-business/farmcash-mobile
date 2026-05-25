import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Interrupteur "Disponible pour livrer" du profil transporteur — état
/// local uniquement (V1 : pas d'endpoint pour persister la valeur).
///
/// Notifie [onTap] à chaque changement (pour afficher un SnackBar
/// "à venir"). La valeur initiale est `true`.
class SwitchDisponibiliteTransporteur extends StatefulWidget {
  /// Construit l'interrupteur.
  const SwitchDisponibiliteTransporteur({super.key, required this.onTap});

  /// Notifie un tap utilisateur après changement local.
  final VoidCallback onTap;

  @override
  State<SwitchDisponibiliteTransporteur> createState() =>
      _SwitchDisponibiliteTransporteurState();
}

class _SwitchDisponibiliteTransporteurState
    extends State<SwitchDisponibiliteTransporteur> {
  bool _value = true;

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: _value,
      activeThumbColor: AppColors.primary,
      onChanged: (v) {
        setState(() => _value = v);
        widget.onTap();
      },
    );
  }
}
