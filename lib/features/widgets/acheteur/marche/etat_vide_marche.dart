import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// État vide premium pour le Marché acheteur — refonte 2026-06-05.
///
/// Avant : juste une icône + texte « Aucune annonce disponible ». Cul-de-sac
/// frustrant qui faisait sortir l'acheteur de l'app.
///
/// Maintenant : transforme l'absence d'offre en **opportunité d'action** :
///   1. Carte hero « Publie ta demande » (CTA principal, vert plein) —
///      le levier le plus puissant : l'acheteur fait venir les vendeurs
///      à lui au lieu d'attendre passivement
///   2. Carte secondaire « Mes demandes en cours » (si l'acheteur a déjà
///      publié) — voir qui a répondu
///   3. Texte explicatif court, ton positif
///
/// Pattern inspiré des marketplaces matures (Indeed, BlaBlaCar) qui
/// activent l'utilisateur quand le contenu manque au lieu de l'afficher
/// comme une erreur.
class EtatVideMarche extends StatelessWidget {
  const EtatVideMarche({required this.message, super.key});

  /// Message principal (contextuel : "ce filtre", "cette catégorie", etc.)
  /// Override possible côté call site pour adapter au contexte.
  final String message;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          // ── Hero : icône + titre + message contextuel ────────────
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.storefront_outlined,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Le marché est calme',
            style: AppTextStyles.titleLarge.copyWith(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),

          // ── CTA principal : publier une demande ──────────────────
          _CarteCtaPrincipal(
            onTap: () =>
                context.push(RouteNames.acheteurDemandePublierPath),
          ),
          const SizedBox(height: 12),

          // ── CTA secondaire : voir mes demandes en cours ──────────
          _CarteCtaSecondaire(
            icone: Icons.inbox_outlined,
            titre: 'Mes demandes en cours',
            sousTitre: 'Voir les producteurs qui m\'ont répondu',
            onTap: () => context.push(RouteNames.acheteurDemandesPath),
          ),
          const SizedBox(height: 8),

          // ── CTA secondaire : voir les prévisions de récolte ──────
          _CarteCtaSecondaire(
            icone: Icons.calendar_today_outlined,
            titre: 'Prochaines récoltes prévues',
            sousTitre: 'Réserve à l\'avance les futures productions',
            onTap: () => context.go(RouteNames.acheteurMarchePath),
          ),
        ],
      ),
    );
  }
}

/// Carte hero verte plein — le CTA primaire qui transforme l'attente en
/// action.
class _CarteCtaPrincipal extends StatelessWidget {
  const _CarteCtaPrincipal({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryHover],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.30),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.campaign_rounded,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Publie ta demande',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Dis aux producteurs ce que tu cherches — ils te répondront.',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.92),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 22,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte CTA secondaire — fond surfaceSoft, icône vert primary.
class _CarteCtaSecondaire extends StatelessWidget {
  const _CarteCtaSecondaire({
    required this.icone,
    required this.titre,
    required this.sousTitre,
    required this.onTap,
  });

  final IconData icone;
  final String titre;
  final String sousTitre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icone, size: 19, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titre,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sousTitre,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textSubtle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
