import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Spécification visuelle d'une méthode de paiement (logo + libellés + état
/// lié au compte). Utilisée par [TuileMethodePaiement].
class MethodePaiementSpec {
  const MethodePaiementSpec({
    required this.code,
    required this.nom,
    required this.sousTitre,
    required this.logoBg,
    required this.logoFg,
    required this.lie,
    required this.apiId,
  });

  /// Sigle court affiché dans le logo (ex : « OM », « MTN »).
  final String code;

  /// Nom complet de la méthode (ex : « Orange Money »).
  final String nom;

  /// Sous-titre (numéro lié ou « Aucun compte lié »).
  final String sousTitre;

  /// Couleur de fond du logo.
  final Color logoBg;

  /// Couleur du texte du logo.
  final Color logoFg;

  /// `true` si la méthode est liée à un compte sélectionnable, `false` sinon
  /// (auquel cas l'action proposée est « + Ajouter »).
  final bool lie;

  /// Identifiant remonté à l'API (mock pour le moment).
  final String apiId;
}

/// Tuile affichant une méthode de paiement avec son état (sélectionnée ou
/// non) — utilisé sur les pages Recharger.
class TuileMethodePaiement extends StatelessWidget {
  const TuileMethodePaiement({
    super.key,
    required this.spec,
    required this.selectionnee,
    required this.onTap,
    this.libelleNonLie = '+ Ajouter',
    this.libelleLie,
  });

  final MethodePaiementSpec spec;
  final bool selectionnee;
  final VoidCallback onTap;

  /// Texte affiché à droite quand la méthode n'est pas liée (par défaut
  /// `+ Ajouter`).
  final String libelleNonLie;

  /// Texte affiché à droite quand la méthode est liée mais non sélectionnée.
  /// Si `null`, on n'affiche aucun libellé (cas producteur/transporteur où
  /// seules les méthodes non liées affichent un CTA).
  final String? libelleLie;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selectionnee ? _kPrimarySoft : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectionnee ? AppColors.primary : AppColors.border,
            width: selectionnee ? 1.5 : AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: spec.logoBg,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                spec.code,
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: spec.logoFg,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    spec.nom,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    spec.sousTitre,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _Trailing(
              selectionnee: selectionnee,
              lie: spec.lie,
              libelleNonLie: libelleNonLie,
              libelleLie: libelleLie,
            ),
          ],
        ),
      ),
    );
  }
}

class _Trailing extends StatelessWidget {
  const _Trailing({
    required this.selectionnee,
    required this.lie,
    required this.libelleNonLie,
    required this.libelleLie,
  });

  final bool selectionnee;
  final bool lie;
  final String libelleNonLie;
  final String? libelleLie;

  @override
  Widget build(BuildContext context) {
    if (selectionnee) {
      return Container(
        width: 18,
        height: 18,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.check,
          size: 12,
          color: Colors.white,
        ),
      );
    }
    if (lie && libelleLie == null) {
      return const SizedBox.shrink();
    }
    return Text(
      lie ? (libelleLie ?? '') : libelleNonLie,
      style: AppTextStyles.labelMedium.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }
}
