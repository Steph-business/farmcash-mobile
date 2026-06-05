import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/enums.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/authentification/auth_premium_bg.dart';
import '../../widgets/authentification/carte_role.dart';
import '../../widgets/authentification/cta_auth_premium.dart';
import '../../widgets/authentification/logo_farmcash.dart';
import '../../widgets/authentification/selecteur_langue.dart';

/// Choix du rôle utilisateur avant l'inscription — version premium
/// (mesh-gradient, logo brand, CTA flèche). Les rôles ADMIN/EXPORTER
/// ne sont pas exposés sur mobile.
class ChoixRolePage extends StatefulWidget {
  const ChoixRolePage({super.key});

  @override
  State<ChoixRolePage> createState() => _ChoixRolePageState();
}

class _ChoixRolePageState extends State<ChoixRolePage> {
  UserRole? _selectedRole;

  static const List<_RoleOption> _options = [
    _RoleOption(
      role: UserRole.farmer,
      title: 'Producteur',
      description: 'Je cultive et je vends ma récolte.',
      icon: Icons.agriculture_outlined,
    ),
    _RoleOption(
      role: UserRole.buyer,
      title: 'Acheteur',
      description: "J'achète des produits agricoles en gros.",
      icon: Icons.shopping_basket_outlined,
    ),
    _RoleOption(
      role: UserRole.cooperative,
      title: 'Coopérative',
      description: 'Je gère un groupement de producteurs.',
      icon: Icons.groups_outlined,
    ),
    _RoleOption(
      role: UserRole.transporter,
      title: 'Transporteur',
      description: 'Je livre les marchandises.',
      icon: Icons.local_shipping_outlined,
    ),
  ];

  void _selectRole(UserRole role) {
    setState(() => _selectedRole = role);
  }

  void _continuer() {
    final role = _selectedRole;
    if (role == null) return;
    context.go('${RouteNames.inscriptionPath}?role=${role.apiValue}');
  }

  void _retour() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.bienvenuePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _selectedRole != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const AuthPremiumBg(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _BoutonRetourPremium(onTap: _retour),
                              const Spacer(),
                              const SelecteurLangue(),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const LogoFarmcash(),
                          const SizedBox(height: 28),
                          Text(
                            'Quel est ton rôle ?',
                            style: AppTextStyles.displayLarge.copyWith(
                              fontSize: 28,
                              height: 1.2,
                              letterSpacing: -0.6,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Choisis le profil qui correspond à ton activité.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 14.5,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          for (var i = 0; i < _options.length; i++) ...[
                            if (i > 0) const SizedBox(height: 12),
                            CarteRole(
                              title: _options[i].title,
                              description: _options[i].description,
                              icon: _options[i].icon,
                              selected: _selectedRole == _options[i].role,
                              onTap: () => _selectRole(_options[i].role),
                            ),
                          ],
                          const Spacer(),
                          const SizedBox(height: 24),
                          CtaAuthPremium(
                            label: 'Continuer',
                            onTap: canContinue ? _continuer : null,
                            enabled: canContinue,
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () =>
                                  context.go(RouteNames.connexionPath),
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
                                      const TextSpan(text: 'Déjà un compte ?  '),
                                      TextSpan(
                                        text: 'Se connecter',
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
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleOption {
  const _RoleOption({
    required this.role,
    required this.title,
    required this.description,
    required this.icon,
  });

  final UserRole role;
  final String title;
  final String description;
  final IconData icon;
}

// Bouton retour rond avec subtil fond blanc + bord — plus premium que
// l'icône fil sur fond transparent.
class _BoutonRetourPremium extends StatelessWidget {
  const _BoutonRetourPremium({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: AppColors.text,
          ),
        ),
      ),
    );
  }
}
