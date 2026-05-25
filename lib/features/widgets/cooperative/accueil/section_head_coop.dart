import 'package:flutter/material.dart';

import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// En-tête de section de l'accueil coopérative : titre + lien optionnel
/// "Voir tout" + widget trailing optionnel (ex: avatars empilés) + petit
/// point coloré optionnel (suggérant la nature de la section).
class SectionHeadCoop extends StatelessWidget {
  const SectionHeadCoop({
    super.key,
    required this.titre,
    this.lienTexte,
    this.onLien,
    this.trailing,
    this.accentDot,
  });

  final String titre;
  final String? lienTexte;
  final VoidCallback? onLien;

  /// Widget optionnel inséré entre le titre et le lien (ex: avatars empilés).
  final Widget? trailing;

  /// Si fourni, un petit point coloré (8×8) est affiché avant le titre,
  /// pour suggérer la nature de la section (opportunité, action…).
  final Color? accentDot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space12),
      child: Row(
        children: [
          if (accentDot != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: accentDot,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              titre,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: 8),
          ],
          if (lienTexte != null)
            InkWell(
              onTap: onLien,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
                child: Text(
                  lienTexte!,
                  style: AppTextStyles.link.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
