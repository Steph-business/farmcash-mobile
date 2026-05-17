import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/enums.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/authentification/carte_role.dart';
import '../../widgets/authentification/selecteur_langue.dart';
import '../../widgets/communs/bouton_principal.dart';
import '../../widgets/communs/bouton_secondaire.dart';

/// Choix du rôle utilisateur avant l'inscription.
///
/// Les rôles ADMIN et EXPORTER ne sont pas exposés sur mobile.
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space32,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppDimens.vGap8,
                      Row(
                        children: [
                          _BoutonRetour(onTap: _retour),
                          const Spacer(),
                          const SelecteurLangue(),
                        ],
                      ),
                      AppDimens.vGap24,
                      const _Logo(),
                      AppDimens.vGap32,
                      Text(
                        'Quel est ton rôle ?',
                        style: AppTextStyles.displaySmall,
                      ),
                      AppDimens.vGap8,
                      Text(
                        'Choisis le profil qui correspond à ton activité.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      AppDimens.vGap32,
                      for (var i = 0; i < _options.length; i++) ...[
                        if (i > 0) AppDimens.vGap12,
                        CarteRole(
                          title: _options[i].title,
                          description: _options[i].description,
                          icon: _options[i].icon,
                          selected: _selectedRole == _options[i].role,
                          onTap: () => _selectRole(_options[i].role),
                        ),
                      ],
                      const Spacer(),
                      AppDimens.vGap32,
                      BoutonPrincipal(
                        label: 'Continuer',
                        onPressed: canContinue ? _continuer : null,
                        enabled: canContinue,
                      ),
                      AppDimens.vGap16,
                      Center(
                        child: LienTexte(
                          prefixe: 'Déjà un compte ?',
                          lien: 'Se connecter',
                          onPressed: () =>
                              context.go(RouteNames.connexionPath),
                        ),
                      ),
                      AppDimens.vGap16,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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

class _BoutonRetour extends StatelessWidget {
  const _BoutonRetour({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: const Padding(
        padding: EdgeInsets.all(AppDimens.space4),
        child: Icon(
          Icons.arrow_back,
          size: 22,
          color: AppColors.text,
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.eco_outlined,
          size: 28,
          color: AppColors.primary,
        ),
        const SizedBox(width: 10),
        Text(
          'FarmCash',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}
