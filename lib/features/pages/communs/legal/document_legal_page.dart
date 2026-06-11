import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/profil_settings/entete_profil_settings.dart';
import 'contenu_legal.dart';

/// Page générique d'affichage d'un document légal (CGU, CGV, Privacy,
/// Mentions). Le contenu est résolu depuis `kLegalDocuments` via le
/// `docType` passé en path param.
class DocumentLegalPage extends StatelessWidget {
  /// Crée la page viewer.
  const DocumentLegalPage({
    required this.docType,
    required this.fallbackPath,
    super.key,
  });

  /// Identifiant du document à afficher (`cgu`, `cgv`, `privacy`,
  /// `mentions`). Cf. [LegalDocType].
  final String docType;

  /// Chemin de repli si la pile de navigation est vide (deep link).
  final String fallbackPath;

  @override
  Widget build(BuildContext context) {
    final document = resolveLegalDocument(docType);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            EnteteProfilSettings(
              fallbackPath: fallbackPath,
              titre: document?.title ?? 'Document légal',
            ),
            Expanded(
              child: document == null
                  ? const _DocumentIntrouvable()
                  : _CorpsDocument(document: document),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentIntrouvable extends StatelessWidget {
  const _DocumentIntrouvable();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.pagePaddingH),
      child: Center(
        child: Text(
          'Document introuvable. Reviens à la page Légal et confidentialité '
          'pour choisir un autre document.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CorpsDocument extends StatelessWidget {
  const _CorpsDocument({required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    // On découpe le corps en blocs sur double saut de ligne pour rendre
    // un layout lisible avec des espacements verticaux constants.
    final blocs = document.body
        .split('\n\n')
        .map((b) => b.trim())
        .where((b) => b.isNotEmpty)
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space16,
        AppDimens.pagePaddingH,
        AppDimens.space32,
      ),
      children: [
        Text(
          document.title,
          style: AppTextStyles.titleMedium.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        AppDimens.vGap4,
        Text(
          document.subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSubtle,
          ),
        ),
        AppDimens.vGap24,
        for (final bloc in blocs) ...[
          _BlocParagraphe(text: bloc),
          AppDimens.vGap16,
        ],
        AppDimens.vGap8,
        _BandeauDisclaimer(),
      ],
    );
  }
}

/// Rend un bloc de texte. Si la première ligne commence par un numéro
/// suivi d'un point (« 1. Objet »), elle est stylée en titre de section ;
/// le reste du paragraphe est aligné dessous en corps de texte.
class _BlocParagraphe extends StatelessWidget {
  const _BlocParagraphe({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final firstLine = lines.first.trim();
    final isHeading = RegExp(r'^\d+\.\s').hasMatch(firstLine);

    if (isHeading) {
      final body = lines.skip(1).join('\n').trim();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            firstLine,
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          if (body.isNotEmpty) ...[
            AppDimens.vGap8,
            Text(
              body,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ],
      );
    }

    return Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondary,
        height: 1.6,
      ),
    );
  }
}

class _BandeauDisclaimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E0),
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: const Color(0xFFE0C36B),
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: Color(0xFF8A6D1B),
          ),
          AppDimens.hGap8,
          Expanded(
            child: Text(
              kDisclaimerLegal,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF6B5413),
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
