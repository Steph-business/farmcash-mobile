import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/profil/groupe_profil.dart';
import '../../../widgets/communs/profil/tuile_profil.dart';
import '../../../widgets/communs/profil_settings/entete_profil_settings.dart';
import 'contenu_legal.dart';

/// Page « Légal et confidentialité » — partagée par les 4 rôles.
///
/// Liste iOS-Settings-like avec les 4 documents légaux (CGU, CGV,
/// Privacy, Mentions) + 2 raccourcis vers les actions RGPD (export +
/// suppression). Chaque tap pushe vers une page dédiée.
class LegalPage extends StatelessWidget {
  /// Construit la page.
  const LegalPage({required this.fallbackPath, super.key});

  /// Chemin de repli si la pile de navigation est vide (deep link).
  final String fallbackPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            EnteteProfilSettings(
              fallbackPath: fallbackPath,
              titre: 'Légal et confidentialité',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  AppDimens.space8,
                  AppDimens.pagePaddingH,
                  AppDimens.space32,
                ),
                children: [
                  const _BandeauInfo(),
                  AppDimens.vGap16,
                  GroupeProfil(
                    titre: 'Documents juridiques',
                    enfants: [
                      TuileProfil(
                        icone: Icons.description_outlined,
                        accent: true,
                        label: 'Conditions Générales d\'Utilisation',
                        sousTitre: 'CGU · version $kCurrentTermsVersion',
                        onTap: () => context.push(
                          RouteNames.documentLegalPathFor(LegalDocType.cgu),
                        ),
                      ),
                      TuileProfil(
                        icone: Icons.receipt_long_outlined,
                        label: 'Conditions Générales de Vente',
                        sousTitre: 'CGV',
                        onTap: () => context.push(
                          RouteNames.documentLegalPathFor(LegalDocType.cgv),
                        ),
                      ),
                      TuileProfil(
                        icone: Icons.privacy_tip_outlined,
                        label: 'Politique de Confidentialité',
                        sousTitre:
                            'RGPD · loi 2013-450 · version $kCurrentPrivacyVersion',
                        onTap: () => context.push(
                          RouteNames.documentLegalPathFor(LegalDocType.privacy),
                        ),
                      ),
                      TuileProfil(
                        icone: Icons.info_outline,
                        label: 'Mentions légales',
                        sousTitre: 'Éditeur · hébergeur · contacts',
                        onTap: () => context.push(
                          RouteNames.documentLegalPathFor(LegalDocType.mentions),
                        ),
                      ),
                    ],
                  ),
                  AppDimens.vGap16,
                  GroupeProfil(
                    titre: 'Mes données personnelles',
                    enfants: [
                      TuileProfil(
                        icone: Icons.download_rounded,
                        accent: true,
                        label: 'Exporter mes données',
                        sousTitre: 'Profil · commandes · KYC en JSON',
                        onTap: () =>
                            context.push(RouteNames.exporterDonneesPath),
                      ),
                      TuileProfil(
                        icone: Icons.delete_outline,
                        accent: true,
                        label: 'Supprimer mon compte',
                        sousTitre: 'Soft-delete · annulable 30 jours',
                        onTap: () =>
                            context.push(RouteNames.supprimerComptePath),
                      ),
                    ],
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

class _BandeauInfo extends StatelessWidget {
  const _BandeauInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          AppDimens.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tes droits sont protégés',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppDimens.vGap4,
                Text(
                  'FarmCash respecte la loi ivoirienne 2013-450 sur la '
                  'protection des données personnelles. Tu peux exporter '
                  'tes données ou supprimer ton compte à tout moment.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
