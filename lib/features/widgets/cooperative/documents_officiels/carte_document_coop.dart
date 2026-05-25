import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Statut d'un document officiel coop.
enum StatutDocumentCoop {
  /// Document jamais uploadé.
  manquant,

  /// Document uploadé, en attente de validation par l'admin.
  enAttente,

  /// Document validé par l'admin.
  valide,

  /// Document refusé — à re-uploader.
  refuse,

  /// Document validé mais expiré (ex. assurance annuelle).
  expire,
}

extension _StatutInfo on StatutDocumentCoop {
  Color get couleur {
    switch (this) {
      case StatutDocumentCoop.valide:
        return AppColors.success;
      case StatutDocumentCoop.enAttente:
        return const Color(0xFFB45309);
      case StatutDocumentCoop.refuse:
      case StatutDocumentCoop.expire:
        return AppColors.error;
      case StatutDocumentCoop.manquant:
        return AppColors.textSubtle;
    }
  }

  Color get fondPastille {
    switch (this) {
      case StatutDocumentCoop.valide:
        return const Color(0xFFE8F5E9);
      case StatutDocumentCoop.enAttente:
        return const Color(0xFFFFF3CD);
      case StatutDocumentCoop.refuse:
      case StatutDocumentCoop.expire:
        return const Color(0xFFFEE2E2);
      case StatutDocumentCoop.manquant:
        return AppColors.surfaceSoft;
    }
  }

  String get label {
    switch (this) {
      case StatutDocumentCoop.valide:
        return 'Validé';
      case StatutDocumentCoop.enAttente:
        return 'En attente';
      case StatutDocumentCoop.refuse:
        return 'Refusé';
      case StatutDocumentCoop.expire:
        return 'Expiré';
      case StatutDocumentCoop.manquant:
        return 'À uploader';
    }
  }

  IconData get icone {
    switch (this) {
      case StatutDocumentCoop.valide:
        return Icons.check_circle_outline;
      case StatutDocumentCoop.enAttente:
        return Icons.hourglass_empty;
      case StatutDocumentCoop.refuse:
        return Icons.cancel_outlined;
      case StatutDocumentCoop.expire:
        return Icons.event_busy_outlined;
      case StatutDocumentCoop.manquant:
        return Icons.upload_file_outlined;
    }
  }
}

/// Carte d'un document officiel coop (statuts, agrément, assurance).
/// Affiche l'icône type document, le nom, une description courte et un
/// badge de statut. Bouton d'action varie selon le statut.
class CarteDocumentCoop extends StatelessWidget {
  /// Construit la carte.
  const CarteDocumentCoop({
    super.key,
    required this.icone,
    required this.nom,
    required this.description,
    required this.statut,
    this.dateUpload,
    required this.onAction,
  });

  /// Icône représentant le type de document.
  final IconData icone;

  /// Nom court du document.
  final String nom;

  /// Description / utilité du document.
  final String description;

  /// Statut courant (manquant, en attente, validé, etc.).
  final StatutDocumentCoop statut;

  /// Date d'upload formatée (ex. "14 mars 2026"), null si manquant.
  final String? dateUpload;

  /// Callback du bouton principal.
  final VoidCallback onAction;

  String get _libelleAction {
    switch (statut) {
      case StatutDocumentCoop.manquant:
        return 'Uploader';
      case StatutDocumentCoop.enAttente:
        return 'Voir';
      case StatutDocumentCoop.valide:
        return 'Voir / Remplacer';
      case StatutDocumentCoop.refuse:
      case StatutDocumentCoop.expire:
        return 'Re-uploader';
    }
  }

  @override
  Widget build(BuildContext context) {
    final couleurStatut = statut.couleur;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icone, size: 22, color: AppColors.text),
              ),
              AppDimens.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nom,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statut.fondPastille,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                statut.icone,
                                size: 12,
                                color: couleurStatut,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                statut.label,
                                style: AppTextStyles.labelSmall.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: couleurStatut,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    if (dateUpload != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Uploadé le $dateUpload',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSubtle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          AppDimens.vGap12,
          OutlinedButton.icon(
            onPressed: onAction,
            icon: Icon(
              statut == StatutDocumentCoop.manquant ||
                      statut == StatutDocumentCoop.refuse ||
                      statut == StatutDocumentCoop.expire
                  ? Icons.upload_file_outlined
                  : Icons.visibility_outlined,
              size: 16,
            ),
            label: Text(_libelleAction),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
              minimumSize: const Size.fromHeight(40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: AppTextStyles.button.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
