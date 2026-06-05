import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/authentification/auth_premium_bg.dart';
import '../../widgets/authentification/cta_auth_premium.dart';
import '../../widgets/authentification/logo_farmcash.dart';
import '../../widgets/authentification/selecteur_langue.dart';

/// Écran d'introduction premium — mesh-gradient, hero typo dramatique
/// avec accent vert, features pills, CTA flèche premium, footer drapeau
/// Côte d'Ivoire. **Animations d'entrée staggered** (logo → titre →
/// sous-titre → features → CTA) pour un feel apps pro (Revolut, Linear).
class BienvenuePage extends StatefulWidget {
  const BienvenuePage({super.key});

  @override
  State<BienvenuePage> createState() => _BienvenuePageState();
}

class _BienvenuePageState extends State<BienvenuePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    // Démarre 1 frame plus tard pour laisser le 1er paint passer
    // (évite un saut sur les vieux appareils).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Helper : anime un enfant en fade + slide-up de 16 px sur l'intervalle
  /// donné de l'animation maître. Donne le rythme staggered.
  Widget _fadeIn({
    required double begin,
    required double end,
    required Widget child,
  }) {
    final anim = CurvedAnimation(
      parent: _ctrl,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        return Opacity(
          opacity: anim.value,
          child: Transform.translate(
            offset: Offset(0, (1 - anim.value) * 16),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const AuthPremiumBg(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  // Sélecteur langue : pas d'animation (toujours dispo).
                  const Align(
                    alignment: Alignment.centerRight,
                    child: SelecteurLangue(),
                  ),
                  const SizedBox(height: 20),
                  _fadeIn(
                    begin: 0.0,
                    end: 0.35,
                    child: const LogoFarmcash(),
                  ),
                  const Spacer(),
                  _fadeIn(
                    begin: 0.15,
                    end: 0.55,
                    child: Text.rich(
                      TextSpan(
                        style: AppTextStyles.displayLarge.copyWith(
                          fontSize: 34,
                          height: 1.15,
                          letterSpacing: -0.8,
                          color: AppColors.text,
                        ),
                        children: [
                          const TextSpan(text: 'Le marketplace\nagricole '),
                          TextSpan(
                            text: 'de Côte\nd’Ivoire.',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _fadeIn(
                    begin: 0.30,
                    end: 0.65,
                    child: Text(
                      'Achète, vends et fais livrer tes récoltes — '
                      'paiement Mobile Money, prix réels du marché.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _fadeIn(
                    begin: 0.45,
                    end: 0.80,
                    child: const Row(
                      children: [
                        Expanded(
                          child: _FeaturePill(
                            icone: Icons.account_balance_wallet_outlined,
                            libelle: 'Mobile\nMoney',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _FeaturePill(
                            icone: Icons.trending_up,
                            libelle: 'Prix\njustes',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _FeaturePill(
                            icone: Icons.verified_user_outlined,
                            libelle: 'Paiement\nsécurisé',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  _fadeIn(
                    begin: 0.60,
                    end: 0.95,
                    child: CtaAuthPremium(
                      label: 'Se connecter',
                      onTap: () => context.go(RouteNames.connexionPath),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _fadeIn(
                    begin: 0.65,
                    end: 1.0,
                    child: Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => context.go(RouteNames.choixRolePath),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Pas encore de compte ?  ',
                                ),
                                TextSpan(
                                  text: 'Créer un compte',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _fadeIn(
                    begin: 0.75,
                    end: 1.0,
                    child: const _FooterCI(),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mini-card valeur (pill) ───────────────────────────────────────

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icone, required this.libelle});

  final IconData icone;
  final String libelle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icone, size: 18, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Text(
            libelle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Footer drapeau Côte d'Ivoire ──────────────────────────────────

class _FooterCI extends StatelessWidget {
  const _FooterCI();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: 11,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 6, color: const Color(0xFFF77F00)),
                  Container(width: 6, color: Colors.white),
                  Container(width: 6, color: const Color(0xFF009E60)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "Fait en Côte d'Ivoire",
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.textSubtle,
              letterSpacing: 0.3,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
