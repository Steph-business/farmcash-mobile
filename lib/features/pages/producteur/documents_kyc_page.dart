import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/kyc_document.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/communs/vue_erreur.dart';
import '../../widgets/producteur/profil/add_button_kyc.dart';
import '../../widgets/producteur/profil/doc_row_kyc.dart';
import '../../widgets/producteur/profil/kyc_doc_type_kyc.dart';
import '../../widgets/producteur/profil/sheet_source_doc_kyc.dart';
import '../../widgets/producteur/profil/sheet_type_doc_kyc.dart';

/// Provider : liste des documents KYC du user connecté.
final _kycDocsProvider = FutureProvider.autoDispose<List<KycDocument>>(
  (ref) async {
    final svc = ref.watch(authServiceProvider);
    return svc.listMyKyc();
  },
);

/// Liste des documents KYC du producteur — branché sur l'API.
class DocumentsKycPage extends ConsumerWidget {
  const DocumentsKycPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_kycDocsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(color: AppColors.text),
        title: Text(
          'Documents (KYC)',
          style: AppTextStyles.titleSmall.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: async.when(
        loading: () => const Padding(
          padding: EdgeInsets.only(top: AppDimens.space32),
          child: Chargement(size: 22),
        ),
        error: (_, _) => Padding(
          padding: const EdgeInsets.all(AppDimens.pagePaddingH),
          child: VueErreur(
            message: 'Impossible de charger tes documents.',
            onRetry: () => ref.invalidate(_kycDocsProvider),
          ),
        ),
        data: (docs) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ref.invalidate(_kycDocsProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.pagePaddingH,
              AppDimens.space8,
              AppDimens.pagePaddingH,
              AppDimens.space24,
            ),
            children: [
              Text(
                'Téléverse tes justificatifs pour activer l\'ensemble des '
                'fonctionnalités de FarmCash (paiements, signature de contrats).',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppDimens.vGap24,
              if (docs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Aucun document pour l\'instant.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                for (final d in docs) ...[
                  DocRowKyc(
                    doc: d,
                    onDelete: d.status == 'PENDING'
                        ? () => _confirmAndDelete(context, ref, d.id)
                        : null,
                  ),
                  AppDimens.vGap12,
                ],
              AppDimens.vGap8,
              AddButtonKyc(onTap: () => _ouvrirAjout(context, ref)),
              AppDimens.vGap24,
              Container(
                padding: const EdgeInsets.all(AppDimens.space12),
                decoration: BoxDecoration(
                  color: kPrimarySoftKyc,
                  borderRadius: AppDimens.brCard,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    AppDimens.hGap8,
                    Expanded(
                      child: Text(
                        'Tes documents sont chiffrés et utilisés uniquement à des '
                        'fins de vérification.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _ouvrirAjout(BuildContext context, WidgetRef ref) async {
    final docType = await showSheetTypeDocKyc(context);
    if (docType == null || !context.mounted) return;

    final source = await showSheetSourceDocKyc(context);
    if (source == null || !context.mounted) return;

    XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1800,
        imageQuality: 82,
      );
    } catch (_) {
      if (context.mounted) {
        Snackbars.showErreur(context, 'Impossible de récupérer l\'image.');
      }
      return;
    }
    if (picked == null || !context.mounted) return;

    await _uploadAndRefresh(context, ref, docType, File(picked.path));
  }

  Future<void> _uploadAndRefresh(
    BuildContext context,
    WidgetRef ref,
    KycDocTypeKyc docType,
    File file,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text('Téléversement en cours…'),
          ],
        ),
        duration: Duration(seconds: 30),
        behavior: SnackBarBehavior.floating,
      ),
    );
    try {
      await ref.read(authServiceProvider).uploadKyc(
            file: file,
            docType: docType.apiValue,
          );
      messenger.hideCurrentSnackBar();
      if (!context.mounted) return;
      Snackbars.showSucces(context, 'Justificatif envoyé.');
      ref.invalidate(_kycDocsProvider);
    } on ApiException catch (e) {
      messenger.hideCurrentSnackBar();
      if (!context.mounted) return;
      Snackbars.showErreur(context, e.message);
    } catch (_) {
      messenger.hideCurrentSnackBar();
      if (!context.mounted) return;
      Snackbars.showErreur(context, 'Impossible d\'envoyer le justificatif.');
    }
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce document ?'),
        content: const Text(
          'Cette action est définitive. Tu pourras le re-téléverser ensuite.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Supprimer',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(authServiceProvider).deleteKyc(id);
      if (!context.mounted) return;
      Snackbars.showSucces(context, 'Document supprimé.');
      ref.invalidate(_kycDocsProvider);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      Snackbars.showErreur(context, e.message);
    } catch (_) {
      if (!context.mounted) return;
      Snackbars.showErreur(context, 'Impossible de supprimer le document.');
    }
  }
}
