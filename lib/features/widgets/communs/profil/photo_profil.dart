import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'icone_tuile_profil.dart' show kVertProfilDoux;

/// Photo de profil 72×72 avec badge "edit" rond vert en bas-droite.
///
/// Affiche [photoUrl] (via `CachedNetworkImage`) si disponible, sinon les
/// [initiales] en gros sur fond vert pâle. La forme est circulaire par
/// défaut (acheteur, producteur, transporteur) ; passer [carre] à `true`
/// pour un coin arrondi 14px (variante coopérative — logo).
class PhotoProfil extends StatelessWidget {
  /// Construit la photo profil.
  const PhotoProfil({
    super.key,
    required this.initiales,
    this.photoUrl,
    this.onEdit,
    this.carre = false,
    this.taille = 72,
  });

  /// URL distante (optionnel) — affichée prioritaire si non vide.
  final String? photoUrl;

  /// Initiales fallback (1-2 lettres) — affichées si pas d'URL ou si erreur.
  final String initiales;

  /// Callback du badge "edit" en bas-droite. Si null, le badge ne s'affiche
  /// pas (utile sur les vues consultation).
  final VoidCallback? onEdit;

  /// Si vrai, photo carrée à coin arrondi (variante coop). Sinon circulaire.
  final bool carre;

  /// Taille (largeur = hauteur). Défaut 72.
  final double taille;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    final BoxDecoration decoration = carre
        ? BoxDecoration(
            color: kVertProfilDoux,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          )
        : BoxDecoration(
            color: kVertProfilDoux,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          );

    return SizedBox(
      width: taille,
      height: taille,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: taille,
            height: taille,
            decoration: decoration,
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: hasPhoto
                ? CachedNetworkImage(
                    imageUrl: photoUrl!,
                    width: taille,
                    height: taille,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        const ColoredBox(color: kVertProfilDoux),
                    errorWidget: (_, _, _) =>
                        _Initiales(texte: initiales),
                  )
                : _Initiales(texte: initiales),
          ),
          if (onEdit != null)
            Positioned(
              right: -2,
              bottom: -2,
              child: InkWell(
                onTap: onEdit,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.background,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.edit,
                    size: 12,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

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
          fontSize: 22,
        ),
      ),
    );
  }
}

/// Retourne les initiales (1-2 lettres en MAJUSCULES) d'un nom complet,
/// pour le fallback d'avatar. Renvoie "?" si le nom est vide/null.
///
/// Si un seul mot : 2 premières lettres (ou 1 si une seule). Si plusieurs
/// mots : 1ère du premier + 1ère du dernier mot.
String initialesProfilDepuisNom(String? nom) {
  final t = nom?.trim() ?? '';
  if (t.isEmpty) return '?';
  final parts = t.split(RegExp(r'[\s\-_]+'))
    ..removeWhere((p) => p.isEmpty);
  if (parts.length >= 2) {
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
  if (t.length == 1) return t.toUpperCase();
  return t.substring(0, 2).toUpperCase();
}
