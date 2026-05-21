import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
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

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Types de documents proposés à l'upload. La valeur `apiValue` est le
/// string attendu côté backend dans `doc_type`.
enum _KycDocType {
  cniRecto('CNI_RECTO', 'CNI — Recto', Icons.badge_outlined),
  cniVerso('CNI_VERSO', 'CNI — Verso', Icons.badge_outlined),
  selfie('SELFIE', 'Selfie', Icons.face_outlined),
  carteProducteur('CARTE_PRODUCTEUR', 'Carte producteur', Icons.card_membership),
  justificatifParcelle(
    'JUSTIFICATIF_PARCELLE',
    'Justificatif de parcelle',
    Icons.landscape_outlined,
  );

  const _KycDocType(this.apiValue, this.label, this.icon);
  final String apiValue;
  final String label;
  final IconData icon;

  static _KycDocType? fromApi(String raw) {
    for (final t in values) {
      if (t.apiValue == raw) return t;
    }
    return null;
  }
}

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
                  _DocRow(
                    doc: d,
                    onDelete: d.status == 'PENDING'
                        ? () => _confirmAndDelete(context, ref, d.id)
                        : null,
                  ),
                  AppDimens.vGap12,
                ],
              AppDimens.vGap8,
              _AddButton(onTap: () => _ouvrirAjout(context, ref)),
              AppDimens.vGap24,
              Container(
                padding: const EdgeInsets.all(AppDimens.space12),
                decoration: BoxDecoration(
                  color: _kPrimarySoft,
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
    final docType = await showModalBottomSheet<_KycDocType>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: AppDimens.brBottomSheet,
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDimens.vGap8,
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space24,
                vertical: AppDimens.space8,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Type de justificatif',
                  style: AppTextStyles.titleLarge,
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            for (final t in _KycDocType.values) ...[
              ListTile(
                leading: Icon(t.icon, color: AppColors.primary),
                title: Text(t.label),
                onTap: () => Navigator.of(ctx).pop(t),
              ),
              if (t != _KycDocType.values.last)
                const Divider(height: 1, color: AppColors.border),
            ],
            AppDimens.vGap8,
          ],
        ),
      ),
    );
    if (docType == null || !context.mounted) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppDimens.brBottomSheet,
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDimens.vGap8,
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space24,
                vertical: AppDimens.space8,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Source du document',
                  style: AppTextStyles.titleLarge,
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            ListTile(
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            const Divider(height: 1, color: AppColors.border),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Choisir dans la galerie'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            AppDimens.vGap8,
          ],
        ),
      ),
    );
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
    _KycDocType docType,
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

// ─── UI ──────────────────────────────────────────────────────────────

class _DocRow extends StatelessWidget {
  const _DocRow({required this.doc, required this.onDelete});

  final KycDocument doc;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final type = _KycDocType.fromApi(doc.docType);
    final label = type?.label ?? doc.docType;
    final icon = type?.icon ?? Icons.description_outlined;

    return Container(
      padding: const EdgeInsets.all(AppDimens.space12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Thumb(url: doc.url, icon: icon),
          AppDimens.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                _StatusChip(status: doc.status),
                if (doc.status == 'REJECTED' &&
                    doc.rejectionReason != null &&
                    doc.rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Motif : ${doc.rejectionReason}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDelete != null) ...[
            AppDimens.hGap8,
            IconButton(
              tooltip: 'Supprimer',
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.url, required this.icon});

  final String url;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final hasUrl = url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'));
    final isImageLike = hasUrl &&
        (url.toLowerCase().endsWith('.jpg') ||
            url.toLowerCase().endsWith('.jpeg') ||
            url.toLowerCase().endsWith('.png') ||
            url.toLowerCase().endsWith('.webp') ||
            url.toLowerCase().endsWith('.heic') ||
            url.toLowerCase().contains('/image'));

    if (isImageLike) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 44,
          height: 44,
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(color: _kPrimarySoft),
            errorWidget: (_, _, _) => _IconBox(icon: icon),
          ),
        ),
      );
    }
    return _IconBox(icon: icon);
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 20, color: AppColors.primary),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color fg;
    late final Color bg;
    switch (status) {
      case 'VALIDATED':
        label = 'Validé';
        fg = AppColors.primary;
        bg = _kPrimarySoft;
        break;
      case 'REJECTED':
        label = 'Refusé';
        fg = AppColors.error;
        bg = const Color(0xFFFDECEA);
        break;
      case 'PENDING':
      default:
        label = 'En attente';
        fg = const Color(0xFF1D4ED8);
        bg = const Color(0xFFDBEAFE);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.brCard,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: _kPrimarySoft,
          borderRadius: AppDimens.brCard,
          border: Border.all(
            color: AppColors.primary,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle_outline,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Ajouter un justificatif',
              style: AppTextStyles.button.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
