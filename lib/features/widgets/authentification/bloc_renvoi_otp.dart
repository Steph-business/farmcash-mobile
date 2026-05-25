import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../communs/bouton_secondaire.dart';

/// Bloc « renvoyer le code OTP » — affiche soit un compte à rebours
/// (`secondsLeft > 0`) soit le bouton de renvoi (sinon).
class BlocRenvoiOtp extends StatelessWidget {
  const BlocRenvoiOtp({
    required this.secondsLeft,
    required this.resending,
    required this.onRenvoyer,
    super.key,
  });

  final int secondsLeft;
  final bool resending;
  final VoidCallback onRenvoyer;

  /// `secondsLeft` formaté en `m:ss`.
  String _formatCountdown(int seconds) {
    final m = (seconds ~/ 60).toString();
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: secondsLeft > 0
          ? Text(
              'Renvoyer le code dans ${_formatCountdown(secondsLeft)}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : BoutonSecondaire(
              label: resending ? 'Envoi en cours…' : 'Renvoyer le code',
              onPressed: resending ? null : onRenvoyer,
            ),
    );
  }
}
