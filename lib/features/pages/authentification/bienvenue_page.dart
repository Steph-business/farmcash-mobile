import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/authentification/selecteur_langue.dart';
import '../../widgets/communs/bouton_principal.dart';
import '../../widgets/communs/bouton_secondaire.dart';

/// Écran d'introduction sobre — pas de tagline marketing, pas d'animation.
///
/// Deux choix : se connecter ou créer un compte.
class BienvenuePage extends StatelessWidget {
  const BienvenuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppDimens.vGap16,
              const Align(
                alignment: Alignment.centerRight,
                child: SelecteurLangue(),
              ),
              AppDimens.vGap32,
              const _Logo(),
              const Spacer(),
              Text(
                'Marketplace agricole\nde Côte d\'Ivoire',
                style: AppTextStyles.displayMedium.copyWith(
                  fontSize: 28,
                  height: 1.25,
                ),
              ),
              AppDimens.vGap12,
              Text(
                'Achète, vends et suis tes récoltes en un seul endroit.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(flex: 2),
              BoutonPrincipal(
                label: 'Se connecter',
                onPressed: () => context.go(RouteNames.connexionPath),
              ),
              AppDimens.vGap16,
              Center(
                child: LienTexte(
                  prefixe: 'Pas encore de compte ?',
                  lien: 'Créer un compte',
                  onPressed: () => context.go(RouteNames.choixRolePath),
                ),
              ),
              AppDimens.vGap32,
            ],
          ),
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
        Icon(Icons.eco_outlined, size: 28, color: AppColors.primary),
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
