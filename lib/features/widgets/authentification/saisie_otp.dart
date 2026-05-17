import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

/// Saisie OTP — N cases distinctes (6 par défaut).
///
/// Visuel sobre, aligné DESIGN.md :
///  - Carré 44×54, radius 10
///  - Bordure 1px [AppColors.borderStrong] au repos
///  - Bordure verte [AppColors.primary] au focus (PAS de halo)
///  - Texte Inter 18px / w600 centré
///  - PAS de fond coloré, PAS d'ombre
///
/// Comportement :
///  - Auto-focus suivant au remplissage
///  - Backspace → revient au champ précédent et le vide
///  - `onCompleted` appelé quand toutes les cases sont remplies
///  - `onChanged` appelé à chaque mutation (valeur concaténée)
class SaisieOtp extends StatefulWidget {
  const SaisieOtp({
    this.length = 6,
    this.enabled = true,
    this.autofocus = true,
    this.onCompleted,
    this.onChanged,
    super.key,
  });

  final int length;
  final bool enabled;
  final bool autofocus;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;

  @override
  State<SaisieOtp> createState() => SaisieOtpState();
}

class SaisieOtpState extends State<SaisieOtp> {
  late final List<TextEditingController> _ctrls;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
    for (final node in _nodes) {
      node.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  /// Valeur complète concaténée.
  String getValue() => _ctrls.map((c) => c.text).join();

  /// Vide toutes les cases et redonne le focus à la première.
  void reset() {
    for (final c in _ctrls) {
      c.clear();
    }
    if (mounted) {
      FocusScope.of(context).requestFocus(_nodes.first);
      setState(() {});
      widget.onChanged?.call('');
    }
  }

  void _handleChange(int index, String value) {
    if (value.length > 1) {
      // Coller plusieurs chiffres d'un coup : on répartit.
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < widget.length; i++) {
        final di = index + i;
        if (di >= widget.length) break;
        if (i < digits.length) {
          _ctrls[di].text = digits[i];
        }
      }
      final nextIndex = (index + digits.length).clamp(0, widget.length - 1);
      _nodes[nextIndex].requestFocus();
    } else if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        _nodes[index + 1].requestFocus();
      } else {
        _nodes[index].unfocus();
      }
    }

    final full = getValue();
    widget.onChanged?.call(full);
    if (full.length == widget.length) {
      widget.onCompleted?.call(full);
    }
    setState(() {});
  }

  void _handleKey(int index, KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_ctrls[index].text.isEmpty && index > 0) {
        _ctrls[index - 1].clear();
        _nodes[index - 1].requestFocus();
        widget.onChanged?.call(getValue());
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (i) => _buildBox(i)),
    );
  }

  Widget _buildBox(int index) {
    final isFocused = _nodes[index].hasFocus;
    final borderColor =
        isFocused ? AppColors.primary : AppColors.borderStrong;

    return SizedBox(
      width: 44,
      height: 54,
      child: KeyboardListener(
        focusNode: FocusNode(skipTraversal: true, canRequestFocus: false),
        onKeyEvent: (event) => _handleKey(index, event),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: AppDimens.brInput,
            border: Border.all(
              color: borderColor,
              width: AppDimens.borderThin,
            ),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: _ctrls[index],
            focusNode: _nodes[index],
            enabled: widget.enabled,
            autofocus: widget.autofocus && index == 0,
            keyboardType: TextInputType.number,
            textInputAction: index == widget.length - 1
                ? TextInputAction.done
                : TextInputAction.next,
            textAlign: TextAlign.center,
            maxLength: 1,
            showCursor: true,
            cursorColor: AppColors.primary,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            onChanged: (value) => _handleChange(index, value),
          ),
        ),
      ),
    );
  }
}
