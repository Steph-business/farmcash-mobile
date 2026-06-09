import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/enums.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';

/// État vide premium pour la page Messages — refonte 2026-06-05.
///
/// Avant : icône + texte « Aucune conversation ». Cul-de-sac.
///
/// Maintenant : explique CE QUI déclenche une conversation dans
/// FarmCash (négo offre, suivi commande, sollicitation) + CTA
/// contextuel pour aller faire vivre l'app.
///
/// Conversations FarmCash naissent toujours d'un autre flow :
///   - L'acheteur tape « Discuter » sur une annonce/vendeur
///   - Le producteur tape « Discuter » sur une candidature reçue
///   - La coop crée une sollicitation à ses membres
/// Donc le CTA principal pointe vers le bon flow selon le rôle.
class EtatVideMessages extends ConsumerWidget {
  const EtatVideMessages({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserProvider)?.role;
    final cta = _ctaPourRole(role);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune conversation',
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
              _texteContextuel(role),
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),

          // CTA contextuel selon le rôle
          if (cta != null)
            _CarteCta(
              icone: cta.icone,
              titre: cta.titre,
              sousTitre: cta.sousTitre,
              onTap: () {
                if (cta.useGo) {
                  context.go(cta.route);
                } else {
                  context.push(cta.route);
                }
              },
            ),
        ],
      ),
    );
  }

  String _texteContextuel(UserRole? role) {
    switch (role) {
      case UserRole.buyer:
        return 'Tape « Discuter » sur une annonce pour démarrer un échange '
            'avec un vendeur.';
      case UserRole.farmer:
        return 'Quand un acheteur candidatera sur une de tes annonces, vous '
            'pourrez échanger ici.';
      case UserRole.cooperative:
        return 'Sollicite tes membres ou réponds aux offres acheteurs pour '
            'démarrer une conversation.';
      case UserRole.transporter:
        return 'Tes échanges avec acheteurs et vendeurs apparaîtront ici '
            'quand tu accepteras une mission.';
      default:
        return 'Tes échanges apparaîtront ici dès que tu en démarreras un.';
    }
  }

  _CtaSpec? _ctaPourRole(UserRole? role) {
    switch (role) {
      case UserRole.buyer:
        return const _CtaSpec(
          icone: Icons.storefront_outlined,
          titre: 'Voir le marché',
          sousTitre: 'Découvre les producteurs et démarre une discussion',
          route: RouteNames.acheteurMarchePath,
          useGo: true,
        );
      case UserRole.farmer:
        return const _CtaSpec(
          icone: Icons.inbox_outlined,
          titre: 'Voir mes offres reçues',
          sousTitre: 'Réponds aux acheteurs qui ont candidaté',
          route: RouteNames.producteurOffresRecuesPath,
          useGo: false,
        );
      case UserRole.cooperative:
        return const _CtaSpec(
          icone: Icons.inbox_outlined,
          titre: 'Voir les offres acheteurs',
          sousTitre: 'Réponds aux acheteurs qui ciblent ta coop',
          route: RouteNames.cooperativeOffresRecuesPath,
          useGo: false,
        );
      case UserRole.transporter:
        return const _CtaSpec(
          icone: Icons.local_shipping_outlined,
          titre: 'Voir mes missions',
          sousTitre: 'Accepte une mission pour démarrer un échange',
          route: RouteNames.transporteurMissionsPath,
          useGo: true,
        );
      default:
        return null;
    }
  }
}

class _CtaSpec {
  const _CtaSpec({
    required this.icone,
    required this.titre,
    required this.sousTitre,
    required this.route,
    required this.useGo,
  });
  final IconData icone;
  final String titre;
  final String sousTitre;
  final String route;
  final bool useGo;
}

class _CarteCta extends StatelessWidget {
  const _CarteCta({
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
                child: Icon(icone, size: 22, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titre,
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
                      sousTitre,
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
