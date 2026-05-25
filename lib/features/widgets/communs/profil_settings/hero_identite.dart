import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Couleur de fond verte douce utilisée par l'avatar et l'icône verte.
const Color kHeroPrimarySoft = Color(0xFFE8F5E9);

/// Carte d'identité affichée en tête de la page "Profil & paramètres".
///
/// Composée d'un avatar circulaire (88x88), du nom principal, d'un
/// sous-titre optionnel (téléphone, rôle, etc.) et d'un bouton bordé
/// "Modifier le profil" lorsque [onModifier] est fourni.
///
/// Utilisée par les 4 pages profil-settings (acheteur, producteur,
/// transporteur, coopérative). Les variantes spécifiques au rôle
/// (rating étoile transporteur, badge "membre depuis…") peuvent être
/// passées via [extraDessousSousTitre].
class HeroIdentite extends StatelessWidget {
  /// Construit le hero avec un nom obligatoire et des éléments optionnels.
  const HeroIdentite({
    super.key,
    required this.nom,
    required this.initiales,
    this.photoUrl,
    this.sousTitre,
    this.libelleBoutonModifier = 'Modifier le profil',
    this.onModifier,
    this.extraDessousSousTitre,
  });

  /// Nom affiché en gros sous l'avatar.
  final String nom;

  /// Initiales fallback affichées si [photoUrl] est null ou échoue.
  final String initiales;

  /// URL distante de la photo de profil ou du logo (optionnel).
  final String? photoUrl;

  /// Ligne de méta-info (téléphone, rôle, membre depuis…). Vide ou null
  /// si rien à afficher.
  final String? sousTitre;

  /// Libellé du bouton "Modifier le profil" (paramétrable pour la coop).
  final String libelleBoutonModifier;

  /// Callback du bouton. Si null, le bouton est masqué.
  final VoidCallback? onModifier;

  /// Widget additionnel inséré entre le sous-titre et le bouton (ex.
  /// rating étoile pour le transporteur).
  final Widget? extraDessousSousTitre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.space8, bottom: 20),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: kHeroPrimarySoft,
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
                        const ColoredBox(color: kHeroPrimarySoft),
                    errorWidget: (_, _, _) => _Initiales(texte: initiales),
                  )
                : _Initiales(texte: initiales),
          ),
          const SizedBox(height: 12),
          Text(
            nom,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          if (sousTitre != null && sousTitre!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              sousTitre!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
          if (extraDessousSousTitre != null) ...[
            const SizedBox(height: 6),
            extraDessousSousTitre!,
          ],
          if (onModifier != null) ...[
            const SizedBox(height: 14),
            InkWell(
              onTap: onModifier,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary,
                    width: AppDimens.borderThin,
                  ),
                ),
                child: Text(
                  libelleBoutonModifier,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Affiche les initiales centrées dans l'avatar (fallback texte).
class _Initiales extends StatelessWidget {
  const _Initiales({required this.texte});
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        texte,
        style: AppTextStyles.titleLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
      ),
    );
  }
}

/// Convertit un nom complet en deux lettres majuscules pour fallback avatar.
///
/// Renvoie "?" si le nom est vide/null. Si un seul mot, prend les deux
/// premières lettres (ou la première si une seule lettre). Si plusieurs
/// mots, prend la première lettre du premier et du dernier mot.
String initialesDepuisNom(String? nom) {
  final t = nom?.trim() ?? '';
  if (t.isEmpty) return '?';
  final parts = t.split(RegExp(r'\s+'))..removeWhere((p) => p.isEmpty);
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final first = parts.first;
    return first.length >= 2
        ? first.substring(0, 2).toUpperCase()
        : first.substring(0, 1).toUpperCase();
  }
  return (parts.first[0] + parts.last[0]).toUpperCase();
}
