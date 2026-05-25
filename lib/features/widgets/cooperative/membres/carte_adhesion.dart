import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'avatar_adhesion.dart';
import 'bouton_action_adhesion.dart';

const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(14));

/// Carte d'une demande d'adhesion : avatar + nom + meta (ville/tel) +
/// message + boutons Refuser / Accepter.
class CarteAdhesion extends StatelessWidget {
  const CarteAdhesion({
    required this.nom,
    required this.avatarUrl,
    required this.ville,
    required this.tel,
    required this.time,
    required this.onAccepter,
    required this.onRefuser,
    super.key,
  });

  /// Nom du demandeur (affichage FULL pour la coop).
  final String nom;

  /// URL de l'avatar (peut etre `null`).
  final String? avatarUrl;

  /// Ville du demandeur (peut etre `null`).
  final String? ville;

  /// Telephone du demandeur (peut etre `null`).
  final String? tel;

  /// Texte horodate ou message accompagnant la demande (peut etre `null`).
  final String? time;

  /// Callback bouton Accepter.
  final VoidCallback onAccepter;

  /// Callback bouton Refuser.
  final VoidCallback onRefuser;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AvatarAdhesion(url: avatarUrl, nom: nom),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_meta().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        _meta(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (time != null && time!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        time!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSubtle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: BoutonOutlineAdhesion(
                  label: 'Refuser',
                  textColor: AppColors.error,
                  onTap: onRefuser,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BoutonFilledAdhesion(
                  label: 'Accepter',
                  onTap: onAccepter,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _meta() {
    final parts = <String>[];
    if (ville != null && ville!.isNotEmpty) parts.add(ville!);
    if (tel != null && tel!.isNotEmpty) parts.add(tel!);
    return parts.join(' · ');
  }
}
