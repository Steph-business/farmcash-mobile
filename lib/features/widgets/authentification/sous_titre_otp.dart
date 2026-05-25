import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Sous-titre de la page OTP : « Entre le code à 6 chiffres envoyé au
/// +225 07 12 34 56 78. » — formate automatiquement le numéro E.164.
class SousTitreOtp extends StatelessWidget {
  const SousTitreOtp({required this.phone, super.key});

  /// Numéro E.164, ex: `+22507123456`.
  final String phone;

  /// E.164 → "+225 07 12 34 56 78" (groupes de 2 après l'indicatif).
  String _formatPhoneDisplay(String e164) {
    final match = RegExp(r'^(\+\d{1,4})(\d+)$').firstMatch(e164);
    if (match == null) return e164;
    final dial = match.group(1)!;
    final rest = match.group(2)!;
    final buf = StringBuffer(dial);
    for (int i = 0; i < rest.length; i += 2) {
      final end = (i + 2).clamp(0, rest.length);
      buf
        ..write(' ')
        ..write(rest.substring(i, end));
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Entre le code à 6 chiffres envoyé au '
      '${_formatPhoneDisplay(phone)}.',
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }
}
