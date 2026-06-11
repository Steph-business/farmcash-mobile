// =====================================================================
//  Dialog « Changer de profil » — gestion des attentes V1
//  ---------------------------------------------------------------------
//  En V1 on a délibérément choisi 1 utilisateur = 1 rôle pour éviter :
//   - la confusion UX chez les paysans peu tech
//   - les conflits d'intérêt (coop qui se vend à elle-même, etc.)
//   - une refonte technique lourde des shells / RBAC / wallets
//
//  Pour autant, le besoin existe (président de coop qui vend en perso,
//  producteur devenu collecteur…). Plutôt que d'ignorer ces utilisateurs,
//  on les oriente vers 2 voies propres :
//   1. Créer un 2e compte avec un autre numéro (séparation claire)
//   2. Contacter le support pour les cas particuliers (gérés à la main)
//
//  En V2 (post-lancement), le multi-compte lié sera nativement supporté.
// =====================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import 'snackbars.dart';

/// Numéro du support à exposer (V1, hardcodé — V2 → config dynamique).
const String _kSupportPhone = '+225 07 00 00 00 00';

/// Ouvre le dialog explicatif « Changer de profil ».
Future<void> showDialogChangerProfil(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => const _ChangerProfilDialog(),
  );
}

class _ChangerProfilDialog extends StatelessWidget {
  const _ChangerProfilDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header : icône + titre
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  size: 28,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Changer de profil',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
                fontSize: 19,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pour le moment, un compte FarmCash = un seul rôle. '
              'C\'est plus simple et plus sûr.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),

            // 2 options proposées
            _OptionCard(
              icon: Icons.person_add_alt_1_rounded,
              titre: 'Créer un 2e compte',
              corps:
                  'Inscris-toi avec un autre numéro de téléphone. Tu pourras '
                  'avoir un compte acheteur ET un compte producteur, par '
                  'exemple, totalement séparés.',
            ),
            const SizedBox(height: 10),
            _OptionCard(
              icon: Icons.support_agent_rounded,
              titre: 'Contacter le support',
              corps:
                  'Pour les cas particuliers (coopérative qui vend en perso, '
                  'collecteur…), notre équipe peut t\'aider à distance.',
              copyValue: _kSupportPhone,
              copyLabel: _kSupportPhone,
            ),

            const SizedBox(height: 14),
            // Bandeau « bientôt »
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bientôt : lier plusieurs profils en 1 clic.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // CTA principal
            SizedBox(
              height: AppDimens.buttonHeight,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppDimens.brButton,
                  ),
                ),
                child: Text(
                  'J\'ai compris',
                  style: AppTextStyles.button.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte d'option dans le dialog. Si [copyValue] est fourni, un bouton
/// copier-coller s'affiche pour partager le numéro support.
class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.titre,
    required this.corps,
    this.copyValue,
    this.copyLabel,
  });

  final IconData icon;
  final String titre;
  final String corps;
  final String? copyValue;
  final String? copyLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 17, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titre,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      corps,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (copyValue != null && copyLabel != null) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: copyValue!));
                if (context.mounted) {
                  Snackbars.showSucces(
                    context,
                    'Numéro copié : $copyLabel',
                  );
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.phone_in_talk_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      copyLabel!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.content_copy_rounded,
                      size: 13,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
