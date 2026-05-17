import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

/// Champ téléphone avec préfixe Côte d'Ivoire (+225).
///
/// Conforme à la maquette login : drapeau 🇨🇮 + indicatif + séparateur fin
/// + saisie locale. Le formattage E.164 est géré par [composeE164].
class ChampTelephone extends StatefulWidget {
  const ChampTelephone({
    required this.controller,
    this.label = 'Numéro de téléphone',
    this.hint = '07 12 34 56 78',
    this.enabled = true,
    this.autofocus = false,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool enabled;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;

  /// Convertit un numéro local (ex: `0709883051`) en E.164 (ex: `+2250709883051`).
  ///
  /// Note CI : le plan de numérotation moderne (depuis 2021) impose 10
  /// chiffres GARDANT le 0 initial. Le format E.164 canonique pour la CI
  /// est donc `+225` + les 10 chiffres locaux complets, **sans stripper
  /// le 0**. C'est aussi ce que produit `libphonenumber-js` côté backend.
  static String composeE164(String localDigits, {String dialCode = '+225'}) {
    final digits = localDigits.replaceAll(RegExp(r'\D'), '');
    return '$dialCode$digits';
  }

  /// Valide rapidement : 10 chiffres (plan CI moderne).
  /// Tolère 8 chiffres pour les anciens numéros pré-2021.
  static String? validate(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'Numéro requis';
    if (digits.length < 8 || digits.length > 10) return 'Numéro invalide';
    return null;
  }

  @override
  State<ChampTelephone> createState() => _ChampTelephoneState();
}

class _ChampTelephoneState extends State<ChampTelephone> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    final borderColor =
        isFocused ? AppColors.primary : AppColors.borderStrong;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.labelMedium),
        AppDimens.vGap8,
        Container(
          height: AppDimens.inputHeight,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: AppDimens.brInput,
            border: Border.all(color: borderColor, width: AppDimens.borderThin),
          ),
          child: Row(
            children: [
              // Préfixe pays : drapeau + indicatif, séparé par un filet fin.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🇨🇮', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      '+225',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: AppColors.border,
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  autofocus: widget.autofocus,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  onSubmitted: widget.onSubmitted,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d ]')),
                    LengthLimitingTextInputFormatter(13),
                  ],
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: AppTextStyles.hint,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
