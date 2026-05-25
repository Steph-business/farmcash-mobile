import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'annonce_detail_constants.dart';

/// Tuile pour un traitement déclaré : icône selon type (eco si bio, science
/// sinon), nom, méta (type · dosage · date) et chip "Délai carence respecté"
/// si applicable. Utilisée dans la section traçabilité.
class TraitementTileAnnonce extends StatelessWidget {
  const TraitementTileAnnonce({required this.t, super.key});
  final AnnonceTraitement t;

  @override
  Widget build(BuildContext context) {
    final isBio = _isBio(t.type);
    final df = DateFormat('d MMM y', 'fr_FR');
    final nom = t.produitTraitementNom?.trim().isNotEmpty == true
        ? t.produitTraitementNom!
        : 'Traitement';

    // Métadonnées concaténées par "·" (omises si vides) pour rester sobre.
    final metaParts = <String>[
      if (t.type != null && t.type!.trim().isNotEmpty) _typeLabel(t.type!),
      if (t.dosageUtilise != null && t.dosageUtilise!.trim().isNotEmpty)
        t.dosageUtilise!,
      if (t.dateApplication != null) df.format(t.dateApplication!),
    ];
    final meta = metaParts.join(' · ');

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: kAnnonceDetailPrimarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(
              isBio ? Icons.eco_outlined : Icons.science_outlined,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nom,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (t.delaiCarenceRespecte == true) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: kAnnonceDetailPrimarySoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Délai carence respecté',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isBio(String? type) {
    if (type == null) return false;
    final t = type.toUpperCase();
    return t == 'BIO' || t == 'NATUREL' || t == 'ORGANIC';
  }

  String _typeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'BIO':
        return 'Bio';
      case 'CHIMIQUE':
        return 'Chimique';
      case 'NATUREL':
        return 'Naturel';
      case 'ORGANIQUE':
      case 'ORGANIC':
        return 'Organique';
      default:
        return type;
    }
  }
}
