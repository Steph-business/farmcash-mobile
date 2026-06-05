import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/annonce_achat.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import 'demande_achat_modeles.dart';

const Color _kWarn = Color(0xFFB45309);

/// Récapitulatif d'une demande d'achat — style **e-commerce premium** :
///
///   ┌─ hero photo produit plein largeur 220 px ─┐
///   │ [PUBLIC]                                  │  ← badge audience
///   │                                            │
///   │  Maïs grain blanc                          │  ← titre overlay
///   └────────────────────────────────────────────┘
///   ┌─ carte info unique ───────────────────────┐
///   │  500 kg          ·        900 F/kg max    │  ← 2 KPI big
///   │  demandés                  par kilo        │
///   │  ───                                       │
///   │  👤 Buyer T.    Abidjan                    │  ← buyer compact
///   │  ───                                       │
///   │  📅 Livraison   À confirmer (ambre)       │
///   │  ───                                       │
///   │  Description : lorem… (si présente)        │
///   └────────────────────────────────────────────┘
///
/// Remplace l'ancien design en 3 cartes empilées qui « gaspillaient »
/// l'espace vertical. La photo donne enfin une identité visuelle au
/// produit, et tout le reste est dans une carte cohérente.
class DemandeRecapCard extends StatelessWidget {
  const DemandeRecapCard({required this.demande, super.key});

  final AnnonceAchat demande;

  @override
  Widget build(BuildContext context) {
    final nomProduit = demande.produitLabel;
    final photoUrl = thumbForProduit(nomProduit);
    final qte = _fmt(demande.quantiteKg);
    final prixMax = _fmt(demande.prixMaxKg);
    final region = demande.regionNom;
    final buyer = demande.buyerNom ?? 'Acheteur';
    final buyerPhoto = demande.buyer?.photoUrl;
    final viaCoop = demande.targetCooperativeId != null;
    final dateLimite = demande.dateLimiteLivraison;
    final dateLabel = dateLimite != null
        ? 'Avant le ${DateFormat('d MMM y', 'fr_FR').format(dateLimite)}'
        : 'À confirmer';
    final dateConfirmee = dateLimite != null;
    final description = demande.description?.trim();
    final hasDescription = description != null && description.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 1. HERO PHOTO produit avec badge + titre overlay ────────
        _HeroProduit(
          photoUrl: photoUrl,
          nomProduit: nomProduit,
          viaCoop: viaCoop,
        ),
        const SizedBox(height: 14),

        // ── 2. CARTE INFO unique ────────────────────────────────────
        Container(
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
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 2.1 KPIs side-by-side (qté demandée | prix max)
              _LigneKpis(qte: qte, prixMax: prixMax),
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 14),

              // 2.2 Buyer compact (avatar + nom + ville)
              _LigneBuyer(
                nom: buyer,
                ville: region,
                photoUrl: buyerPhoto,
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 14),

              // 2.3 Livraison
              _LigneLivraison(
                label: dateLabel,
                confirmee: dateConfirmee,
              ),

              // 2.4 Description (si présente)
              if (hasDescription) ...[
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 14),
                _BlocDescription(texte: description),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── 1. Hero photo plein largeur ──────────────────────────────────

class _HeroProduit extends StatelessWidget {
  const _HeroProduit({
    required this.photoUrl,
    required this.nomProduit,
    required this.viaCoop,
  });

  final String photoUrl;
  final String nomProduit;
  final bool viaCoop;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
              errorWidget: (_, _, _) => Container(
                color: AppColors.surfaceSoft,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_outlined,
                  size: 40,
                  color: AppColors.textSubtle,
                ),
              ),
            ),
            // Dégradé bas pour la lisibilité du titre.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.10),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
            // Badge audience top-left
            Positioned(
              top: 14,
              left: 14,
              child: _BadgeAudience(viaCoop: viaCoop),
            ),
            // Titre produit bottom-left
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "L'ACHETEUR CHERCHE",
                    style: AppTextStyles.bodySmall.copyWith(
                      fontFamily: 'Poppins',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nomProduit,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.displayLarge.copyWith(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            color: Colors.black.withValues(alpha: 0.20),
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

// ─── 2.1 Ligne KPIs side-by-side (qte | prix) ─────────────────────

class _LigneKpis extends StatelessWidget {
  const _LigneKpis({required this.qte, required this.prixMax});
  final String qte;
  final String prixMax;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _Kpi(
            valeur: '$qte kg',
            label: 'Quantité demandée',
          ),
        ),
        Container(
          width: 1,
          height: 44,
          color: AppColors.border,
          margin: const EdgeInsets.symmetric(horizontal: 12),
        ),
        Expanded(
          child: _Kpi(
            valeur: '$prixMax F/kg',
            label: 'Prix max accepté',
          ),
        ),
      ],
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.valeur, required this.label});
  final String valeur;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          valeur,
          style: AppTextStyles.titleLarge.copyWith(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: AppColors.primary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 11.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─── 2.2 Buyer compact (avatar + nom + ville) ─────────────────────

class _LigneBuyer extends StatelessWidget {
  const _LigneBuyer({
    required this.nom,
    required this.ville,
    required this.photoUrl,
  });
  final String nom;
  final String? ville;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final initiale = nom.trim().isEmpty ? '?' : nom.trim()[0].toUpperCase();
    return Row(
      children: [
        ClipOval(
          child: SizedBox(
            width: 36,
            height: 36,
            child: (photoUrl != null && photoUrl!.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: photoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => _avatarFallback(initiale),
                    errorWidget: (_, _, _) => _avatarFallback(initiale),
                  )
                : _avatarFallback(initiale),
          ),
        ),
        const SizedBox(width: 12),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              if (ville != null) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        ville!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ─── 2.3 Livraison ────────────────────────────────────────────────

class _LigneLivraison extends StatelessWidget {
  const _LigneLivraison({required this.label, required this.confirmee});
  final String label;
  final bool confirmee;

  @override
  Widget build(BuildContext context) {
    final couleur = confirmee ? AppColors.primary : _kWarn;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: couleur.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.event_outlined,
            size: 18,
            color: couleur,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Livraison',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: couleur,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── 2.4 Description ──────────────────────────────────────────────

class _BlocDescription extends StatelessWidget {
  const _BlocDescription({required this.texte});
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DESCRIPTION',
          style: AppTextStyles.bodySmall.copyWith(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          texte,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            height: 1.5,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}

// ─── Helper ─────────────────────────────────────────────────────────

String _fmt(double v) => NumberFormat('#,##0', 'fr_FR').format(v.round());
