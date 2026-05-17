import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

/// Champ PIN masqué (4 à 6 chiffres).
///
/// Visuel aligné maquette login : bordure verte au focus (sans halo),
/// suffix œil pour révéler temporairement.
class PavePin extends StatefulWidget {
  const PavePin({
    required this.controller,
    this.label = 'Code PIN',
    this.hint = '••••',
    this.maxLength = 6,
    this.minLength = 4,
    this.enabled = true,
    this.autofocus = false,
    this.onCompleted,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLength;
  final int minLength;
  final bool enabled;
  final bool autofocus;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onSubmitted;

  static String? validate(String value, {int min = 4, int max = 6}) {
    if (value.isEmpty) return 'Code PIN requis';
    if (value.length < min) return 'Le PIN doit faire $min à $max chiffres';
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'Chiffres uniquement';
    return null;
  }

  @override
  State<PavePin> createState() => _PavePinState();
}

class _PavePinState extends State<PavePin> {
  final FocusNode _focusNode = FocusNode();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
    widget.controller.addListener(_onChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onChange() {
    if (widget.controller.text.length == widget.maxLength) {
      widget.onCompleted?.call(widget.controller.text);
    }
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
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  autofocus: widget.autofocus,
                  obscureText: _obscure,
                  obscuringCharacter: '•',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onSubmitted: widget.onSubmitted,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(widget.maxLength),
                  ],
                  style: AppTextStyles.titleMedium.copyWith(
                    letterSpacing: 6,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: AppTextStyles.hint.copyWith(letterSpacing: 6),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: AppDimens.iconM,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
