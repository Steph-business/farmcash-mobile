// =====================================================================
//  Page : Mes documents officiels (transporteur)
//  ---------------------------------------------------------------------
//  Upload de 2 documents obligatoires :
//    • Permis de conduire (PERMIS_CONDUIRE)
//    • Carte grise du véhicule (CARTE_GRISE)
//
//  Le transporteur peut prendre une photo ou choisir depuis sa galerie.
//  Le statut backend (PENDING / APPROVED / REJECTED) est affiché.
//  Si REJECTED : le motif est visible et le transporteur peut renvoyer
//  une nouvelle version.
// =====================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/kyc_document.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/entete_page_compacte_acheteur.dart';
import '../../widgets/communs/snackbars.dart';

const _docPermis = 'PERMIS_CONDUIRE';
const _docCarteGrise = 'CARTE_GRISE';

final _mesDocsProvider =
    FutureProvider.autoDispose<List<KycDocument>>((ref) async {
  return ref.read(authServiceProvider).listMyKyc();
});

class MesDocumentsTransporteurPage extends ConsumerWidget {
  const MesDocumentsTransporteurPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(_mesDocsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageCompacteAcheteur(title: 'Mes documents'),
            Expanded(
              child: docsAsync.when(
                data: (docs) => RefreshIndicator(
                  onRefresh: () async => ref.invalidate(_mesDocsProvider),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      const _Bandeau(),
                      const SizedBox(height: 14),
                      _CarteDocument(
                        docs: docs,
                        docType: _docPermis,
                        titre: 'Permis de conduire',
                        sousTitre:
                            'Photo recto du permis valide.',
                      ),
                      const SizedBox(height: 12),
                      _CarteDocument(
                        docs: docs,
                        docType: _docCarteGrise,
                        titre: 'Carte grise',
                        sousTitre:
                            'Photo recto de la carte grise du véhicule.',
                      ),
                    ],
                  ),
                ),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Erreur : $e',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),
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

class _Bandeau extends StatelessWidget {
  const _Bandeau();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 17,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Ces documents sont vérifiés par FarmCash. Tu pourras accepter '
              'des missions dès qu\'ils sont approuvés (sous 24-48h).',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11.5,
                color: AppColors.text,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarteDocument extends ConsumerStatefulWidget {
  const _CarteDocument({
    required this.docs,
    required this.docType,
    required this.titre,
    required this.sousTitre,
  });

  final List<KycDocument> docs;
  final String docType;
  final String titre;
  final String sousTitre;

  @override
  ConsumerState<_CarteDocument> createState() => _CarteDocumentState();
}

class _CarteDocumentState extends ConsumerState<_CarteDocument> {
  bool _uploading = false;

  KycDocument? get _doc {
    final filtered =
        widget.docs.where((d) => d.docType == widget.docType).toList();
    if (filtered.isEmpty) return null;
    // Le plus récent gagne.
    filtered.sort((a, b) {
      final aUp = a.uploadedAt ?? DateTime(2000);
      final bUp = b.uploadedAt ?? DateTime(2000);
      return bUp.compareTo(aUp);
    });
    return filtered.first;
  }

  Future<void> _choisirSource() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choisir depuis la galerie'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    await _uploader(source);
  }

  Future<void> _uploader(ImageSource source) async {
    if (_uploading) return;
    setState(() => _uploading = true);
    try {
      final picker = ImagePicker();
      final picked =
          await picker.pickImage(source: source, imageQuality: 78);
      if (picked == null) return;
      await ref.read(authServiceProvider).uploadKyc(
            file: File(picked.path),
            docType: widget.docType,
          );
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        '${widget.titre} envoyé · validation FarmCash sous 24-48h.',
      );
      ref.invalidate(_mesDocsProvider);
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = _doc;
    final statusInfo = _statusInfo(doc?.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimens.brCard,
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: statusInfo.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Icon(
                  widget.docType == _docPermis
                      ? Icons.badge_outlined
                      : Icons.description_outlined,
                  size: 19,
                  color: statusInfo.color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.titre,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.sousTitre,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (doc != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusInfo.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusInfo.label,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: statusInfo.color,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (doc != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.upload_file_rounded,
                  size: 13,
                  color: AppColors.textSubtle,
                ),
                const SizedBox(width: 4),
                Text(
                  doc.uploadedAt != null
                      ? 'Envoyé le ${DateFormat('d MMM y', 'fr_FR').format(doc.uploadedAt!)}'
                      : 'Envoyé',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11.5,
                    color: AppColors.textSubtle,
                  ),
                ),
              ],
            ),
            if (doc.status == 'REJECTED' &&
                doc.rejectionReason != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 14,
                      color: Color(0xFF991B1B),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Motif : ${doc.rejectionReason}',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11.5,
                          color: const Color(0xFF991B1B),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: OutlinedButton.icon(
              onPressed: _uploading ? null : _choisirSource,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.35),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: _uploading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Icon(
                      doc == null ? Icons.upload_rounded : Icons.refresh,
                      size: 16,
                    ),
              label: Text(
                _uploading
                    ? 'Envoi en cours…'
                    : (doc == null
                        ? 'Envoyer le document'
                        : 'Renvoyer une nouvelle version'),
                style: AppTextStyles.button.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ({Color color, String label}) _statusInfo(String? status) {
    switch (status) {
      case 'APPROVED':
        return (color: AppColors.primary, label: 'Approuvé');
      case 'REJECTED':
        return (color: const Color(0xFF991B1B), label: 'Rejeté');
      case 'PENDING':
        return (color: const Color(0xFFD97706), label: 'En attente');
      default:
        return (color: AppColors.textSubtle, label: 'Non envoyé');
    }
  }
}
