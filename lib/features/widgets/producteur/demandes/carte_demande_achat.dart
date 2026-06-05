import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import 'demande_achat_modeles.dart';

/// Carte « offre d'achat » côté FARMER — structure premium :
///
///   1. **Hero photo produit** plein largeur (180px) avec **badge
///      audience** (PUBLIC / COOP) en overlay top-left
///   2. **Buyer row** : avatar + nom + ville
///   3. **Titre produit** gros : « 500 kg de Maïs grain blanc »
///   4. **2 lignes info** : Prix unitaire / Valeur totale (label / valeur)
///   5. **Footer** : publié + chip livraison (vert ou ambre si urgent)
///
/// Palette : vert primary existant (pas de variante dark/gold). Tap →
/// page de détails de la demande (puis sheet candidature).
class CarteDemandeAchat extends StatelessWidget {
  const CarteDemandeAchat({super.key, required this.demande});

  final MockDemande demande;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.push(
          RouteNames.producteurDemandeAchatRepondrePathFor(demande.id),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Hero photo + badge audience overlay ──────────────
              _HeroPhoto(
                imageUrl: demande.produitThumb,
                viaCoop: demande.viaCoop,
              ),

              // ── 2. Buyer row + 3. Titre + 4. Infos + 5. Footer ──────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BuyerRow(
                      nom: demande.buyerNom,
                      ville: demande.ville,
                      photoUrl: demande.buyerAvatar,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      demande.quantite,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: AppColors.text,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    _LigneInfo(
                      label: 'Prix unitaire',
                      valeur: demande.prixMaxLabel,
                      valeurEnAccent: true,
                    ),
                    const SizedBox(height: 6),
                    _LigneInfo(
                      label: 'Valeur totale',
                      valeur: demande.valeurTotaleLabel,
                      valeurEnAccent: false,
                    ),
                    const SizedBox(height: 12),
                    const Divider(
                      height: 1,
                      thickness: 0.6,
                      color: AppColors.border,
                    ),
                    const SizedBox(height: 10),
                    _Footer(publieIlYa: demande.publieIlYa),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 1. Hero photo + badge audience ───────────────────────────────

class _HeroPhoto extends StatelessWidget {
  const _HeroPhoto({required this.imageUrl, required this.viaCoop});

  final String imageUrl;
  final bool viaCoop;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
            errorWidget: (_, _, _) => Container(
              color: AppColors.surfaceSoft,
              alignment: Alignment.center,
              child: const Icon(
                Icons.image_outlined,
                size: 32,
                color: AppColors.textSubtle,
              ),
            ),
          ),
          // Dégradé bas → texte du badge reste lisible même sur photo claire.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4],
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: _BadgeAudience(viaCoop: viaCoop),
          ),
        ],
      ),
    );
  }
}

class _BadgeAudience extends StatelessWidget {
  const _BadgeAudience({required this.viaCoop});
  final bool viaCoop;

  @override
  Widget build(BuildContext context) {
    final label = viaCoop ? 'COOP' : 'PUBLIC';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          fontFamily: 'Poppins',
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─── 2. Buyer row ─────────────────────────────────────────────────

class _BuyerRow extends StatelessWidget {
  const _BuyerRow({
    required this.nom,
    required this.ville,
    required this.photoUrl,
  });

  final String nom;
  final String ville;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    final initiale = nom.trim().isEmpty ? '?' : nom.trim()[0].toUpperCase();
    return Row(
      children: [
        ClipOval(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CachedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => _avatarFallback(initiale),
              errorWidget: (_, _, _) => _avatarFallback(initiale),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                nom,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                ville.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _avatarFallback(String initiale) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Text(
        initiale,
        style: AppTextStyles.bodyMedium.copyWith(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ─── 4. Ligne info (label / valeur) ───────────────────────────────

class _LigneInfo extends StatelessWidget {
  const _LigneInfo({
    required this.label,
    required this.valeur,
    required this.valeurEnAccent,
  });

  final String label;
  final String valeur;
  final bool valeurEnAccent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          valeur,
          style: AppTextStyles.bodyMedium.copyWith(
            fontFamily: 'Poppins',
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: valeurEnAccent ? AppColors.primary : AppColors.text,
          ),
        ),
      ],
    );
  }
}

// ─── 5. Footer : juste la date de publication ─────────────────────

class _Footer extends StatelessWidget {
  const _Footer({required this.publieIlYa});

  final String publieIlYa;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.access_time_rounded,
          size: 13,
          color: AppColors.textSubtle,
        ),
        const SizedBox(width: 5),
        Text(
          publieIlYa.toUpperCase(),
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: AppColors.textSubtle,
          ),
        ),
      ],
    );
  }
}
