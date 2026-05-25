import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'bouton_action_membre.dart';
import 'etiquette_info_membre.dart';
import 'initiales_membre.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const BorderRadius _kBrHero = BorderRadius.all(Radius.circular(14));

/// Carte hero d'une fiche membre : photo + nom + tags + actions.
class CarteHeroMembre extends StatelessWidget {
  const CarteHeroMembre({
    super.key,
    required this.nom,
    required this.phone,
    required this.photoUrl,
    required this.membreDepuis,
    required this.roleLabel,
    required this.onAppeler,
    required this.onMessage,
  });

  /// Nom complet du membre.
  final String nom;

  /// Téléphone affiché sous le nom (optionnel).
  final String? phone;

  /// URL de la photo de profil (optionnel).
  final String? photoUrl;

  /// Label « Membre depuis … ».
  final String membreDepuis;

  /// Label du rôle (Membre, Président, …).
  final String roleLabel;

  /// Action « Appeler ».
  final VoidCallback onAppeler;

  /// Action « Message ».
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrHero,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: (photoUrl != null && photoUrl!.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: photoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        const ColoredBox(color: _kPrimarySoft),
                    errorWidget: (_, _, _) => _initialesAvatar(nom),
                  )
                : _initialesAvatar(nom),
          ),
          const SizedBox(height: 12),
          Text(
            nom,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (phone != null && phone!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              phone!,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              EtiquetteInfoMembre(label: roleLabel),
              EtiquetteInfoMembre(label: membreDepuis),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: BoutonActionMembre(
                  icon: Icons.phone_outlined,
                  label: 'Appeler',
                  filled: false,
                  onTap: onAppeler,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BoutonActionMembre(
                  icon: Icons.chat_bubble_outline,
                  label: 'Message',
                  filled: true,
                  onTap: onMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _initialesAvatar(String nom) {
  return Center(
    child: Text(
      initialesMembre(nom),
      style: AppTextStyles.titleLarge.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
    ),
  );
}
