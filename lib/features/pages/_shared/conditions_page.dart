import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/conditions/contenu_cgu.dart';
import '../../widgets/communs/conditions/contenu_confidentialite.dart';
import '../../widgets/communs/profil_settings/entete_profil_settings.dart';

/// Page Conditions & confidentialité partagée — deux onglets (CGU +
/// Politique confidentialité). Texte placeholder structuré.
class ConditionsPage extends StatelessWidget {
  /// Construit la page Conditions.
  const ConditionsPage({super.key, required this.fallbackPath});

  /// Chemin de repli si la pile de navigation est vide (deep link).
  final String fallbackPath;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              EnteteProfilSettings(
                fallbackPath: fallbackPath,
                titre: 'Conditions & confidentialité',
              ),
              const _BarreOnglets(),
              const Expanded(
                child: TabBarView(
                  children: [
                    ContenuCgu(),
                    ContenuConfidentialite(),
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

class _BarreOnglets extends StatelessWidget {
  const _BarreOnglets();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: TabBar(
        indicatorColor: AppColors.primary,
        indicatorWeight: 2,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: AppTextStyles.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'CGU'),
          Tab(text: 'Confidentialité'),
        ],
      ),
    );
  }
}
