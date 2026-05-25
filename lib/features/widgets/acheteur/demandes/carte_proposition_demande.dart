import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/negociation.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarn = Color(0xFFB45309);

final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Carte d'une proposition recue sur une demande d'achat.
/// Affiche prix, quantite, note du producteur et actions accepter/refuser/discuter.
class CartePropositionDemande extends StatelessWidget {
  const CartePropositionDemande({
    super.key,
    required this.proposition,
    required this.isBest,
    required this.busy,
    required this.onAccepter,
    required this.onRefuser,
    required this.onDiscuter,
  });

  final Proposition proposition;
  final bool isBest;
  final bool busy;
  final VoidCallback onAccepter;
  final VoidCallback onRefuser;
  final VoidCallback onDiscuter;

  @override
  Widget build(BuildContext context) {
    final note = proposition.message?.trim();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isBest ? AppColors.primary : AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OfferBox(proposition: proposition),
              if (note != null && note.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.border,
                      width: AppDimens.borderThin,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Text(
                    '« $note »',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              _Actions(
                busy: busy,
                onRefuser: onRefuser,
                onDiscuter: onDiscuter,
                onAccepter: onAccepter,
              ),
            ],
          ),
        ),
        if (isBest)
          Positioned(
            top: -9,
            left: 14,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: _kPrimarySoft,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.primary,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Text(
                'Meilleur prix',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _OfferBox extends StatelessWidget {
  const _OfferBox({required this.proposition});
  final Proposition proposition;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'QUANTITÉ',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_nf.format(proposition.quantiteKg.round())} kg dispo',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                if (proposition.status.name.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    proposition.status.name.toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _kWarn,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_nf.format(proposition.prixProposeKg.round())} F',
                style: AppTextStyles.displaySmall.copyWith(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                '/kg',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.busy,
    required this.onRefuser,
    required this.onDiscuter,
    required this.onAccepter,
  });
  final bool busy;
  final VoidCallback onRefuser;
  final VoidCallback onDiscuter;
  final VoidCallback onAccepter;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionBtn(
            label: 'Refuser',
            onTap: busy ? null : onRefuser,
            color: AppColors.textSecondary,
            background: AppColors.background,
            borderColor: AppColors.border,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionBtn(
            label: 'Discuter',
            onTap: busy ? null : onDiscuter,
            color: AppColors.primary,
            background: AppColors.background,
            borderColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionBtn(
            label: busy ? '…' : 'Accepter',
            onTap: busy ? null : onAccepter,
            color: AppColors.onPrimary,
            background: AppColors.primary,
            borderColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.onTap,
    required this.color,
    required this.background,
    required this.borderColor,
  });
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final Color background;
  final Color borderColor;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: AppDimens.borderThin,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: onTap == null ? AppColors.textSubtle : color,
          ),
        ),
      ),
    );
  }
}
