import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/membre_coop.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import 'badge_gere.dart';
import 'initiales_membre.dart';
import 'pastille_role_membre.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Ligne représentant un membre dans la liste de la coopérative.
class LigneMembre extends StatelessWidget {
  const LigneMembre({super.key, required this.membre, required this.onTap});

  /// Membre à afficher.
  final MembreCoop membre;

  /// Action déclenchée au tap sur la ligne.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final nom = membre.fullName ?? 'Membre';
    final phone = membre.phone ?? '';
    final df = DateFormat('MMM y', 'fr_FR');
    final joined =
        membre.joinedAt != null ? 'rejoint en ${df.format(membre.joinedAt!)}' : '';
    // Pour les farmers gérés, on remplace l'absence de téléphone par une
    // mention claire dans le sous-titre.
    final sousTitre = membre.estGere
        ? ['Sans téléphone', if (joined.isNotEmpty) joined].join(' · ')
        : [if (phone.isNotEmpty) phone, if (joined.isNotEmpty) joined].join(' · ');
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _kPrimarySoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initialesMembre(nom),
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          nom,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (membre.estGere) ...[
                        const SizedBox(width: 6),
                        const BadgeGere(),
                      ],
                    ],
                  ),
                  if (sousTitre.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      sousTitre,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            PastilleRoleMembre(role: membre.role.apiValue),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}
