import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/barre_sticky_action.dart';
import '../../../widgets/communs/profil_settings/entete_profil_settings.dart';
import '../../../widgets/communs/snackbars.dart';

/// Page « Exporter mes données » — partagée par les 4 rôles.
///
/// Récupère un dump JSON complet via `/auth/account/export`, l'affiche
/// dans un dialog prévisualisable + bouton « Copier » qui place le JSON
/// dans le presse-papier (share_plus n'étant pas dans le pubspec, on se
/// limite à Clipboard pour rester pragmatique).
class ExporterDonneesPage extends ConsumerStatefulWidget {
  /// Crée la page.
  const ExporterDonneesPage({required this.fallbackPath, super.key});

  /// Chemin de repli si la pile de navigation est vide (deep link).
  final String fallbackPath;

  @override
  ConsumerState<ExporterDonneesPage> createState() =>
      _ExporterDonneesPageState();
}

class _ExporterDonneesPageState
    extends ConsumerState<ExporterDonneesPage> {
  bool _loading = false;

  Future<void> _onExport() async {
    setState(() => _loading = true);
    try {
      final legal = ref.read(legalServiceProvider);
      final data = await legal.exportAccountData();
      if (!mounted) return;
      // JSON encode indenté pour lisibilité du preview.
      const encoder = JsonEncoder.withIndent('  ');
      final jsonStr = encoder.convert(data);
      await _afficherDialogPreview(jsonStr);
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (!mounted) return;
      Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _afficherDialogPreview(String jsonStr) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AppColors.background,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimens.brCard,
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.space16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
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
                        Icons.data_object_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    AppDimens.hGap12,
                    Expanded(
                      child: Text(
                        'Tes données (JSON)',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                AppDimens.vGap12,
                Text(
                  '${jsonStr.length} caractères · prévisualisation '
                  'tronquée à 4 000 caractères ci-dessous.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                AppDimens.vGap12,
                Flexible(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 320),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: AppDimens.brInput,
                      border: Border.all(
                        color: AppColors.border,
                        width: AppDimens.borderThin,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        jsonStr.length > 4000
                            ? '${jsonStr.substring(0, 4000)}\n…'
                            : jsonStr,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 11.5,
                          color: AppColors.text,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
                AppDimens.vGap16,
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Fermer'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                            color: AppColors.borderStrong,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppDimens.brButton,
                          ),
                          foregroundColor: AppColors.text,
                        ),
                      ),
                    ),
                    AppDimens.hGap12,
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: jsonStr),
                          );
                          if (!ctx.mounted) return;
                          Navigator.of(ctx).pop();
                          if (!mounted) return;
                          Snackbars.showSuccesDetail(
                            context,
                            titre: 'Données copiées',
                            sousTitre:
                                '${jsonStr.length} caractères dans le '
                                'presse-papier.',
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text('Copier'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppDimens.brButton,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            EnteteProfilSettings(
              fallbackPath: widget.fallbackPath,
              titre: 'Exporter mes données',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                  AppDimens.pagePaddingH,
                  AppDimens.space24,
                ),
                children: const [
                  _Encart(),
                  AppDimens.vGap24,
                  _ListeDonneesIncluses(),
                ],
              ),
            ),
            BarreStickyAction(
              child: BoutonStickyPrincipal(
                label: 'Télécharger mes données',
                icone: Icons.download_rounded,
                busy: _loading,
                onTap: _onExport,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Encart extends StatelessWidget {
  const _Encart();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.cloud_download_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              AppDimens.hGap12,
              Expanded(
                child: Text(
                  'Récupère toutes tes données',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          AppDimens.vGap12,
          Text(
            'Tu peux récupérer toutes tes données personnelles dans un '
            'fichier JSON. Utilise-le pour les transférer ailleurs, les '
            'archiver ou les fournir à un autre service. Droit garanti '
            'par la loi ivoirienne 2013-450 sur la protection des '
            'données personnelles.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListeDonneesIncluses extends StatelessWidget {
  const _ListeDonneesIncluses();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inclus dans l\'export',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppDimens.vGap12,
          const _LigneDonnee(
            icone: Icons.person_outline,
            label: 'Profil et informations personnelles',
          ),
          AppDimens.vGap8,
          const _LigneDonnee(
            icone: Icons.receipt_long_outlined,
            label: 'Toutes mes commandes',
          ),
          AppDimens.vGap8,
          const _LigneDonnee(
            icone: Icons.account_balance_wallet_outlined,
            label: 'Historique des transactions',
          ),
          AppDimens.vGap8,
          const _LigneDonnee(
            icone: Icons.fingerprint_rounded,
            label: 'Documents KYC',
          ),
        ],
      ),
    );
  }
}

class _LigneDonnee extends StatelessWidget {
  const _LigneDonnee({required this.icone, required this.label});

  final IconData icone;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icone, color: AppColors.primary, size: 16),
        ),
        AppDimens.hGap12,
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }
}
