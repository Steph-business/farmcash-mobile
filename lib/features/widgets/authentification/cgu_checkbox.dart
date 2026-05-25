import 'package:flutter/material.dart';

import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

/// Checkbox d'acceptation des conditions d'utilisation pour le
/// formulaire d'inscription. Toute la ligne est cliquable et la
/// checkbox suit l'état [value] piloté par le parent.
class CguCheckbox extends StatelessWidget {
  const CguCheckbox({
    required this.value,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => onChanged(!value) : null,
      borderRadius: BorderRadius.circular(AppDimens.radiusS),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: value,
                onChanged: enabled ? (v) => onChanged(v ?? false) : null,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            AppDimens.hGap12,
            Expanded(
              child: Text(
                'J\'accepte les Conditions d\'utilisation.',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
