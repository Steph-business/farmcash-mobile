import 'package:flutter/material.dart';

import '../../../models/enums.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import 'messages_types.dart';

/// Ligne horizontale de chips-filtres pour la liste de conversations.
///
/// La liste des filtres affichés dépend du rôle viewer :
/// - producteur → acheteurs / coops / transporteurs
/// - acheteur → producteurs / coops / transporteurs
/// - coop → farmers / acheteurs / transporteurs
/// - transporteur → producteurs / acheteurs / coops
class FiltresMessages extends StatelessWidget {
  const FiltresMessages({
    required this.current,
    required this.onSelect,
    required this.role,
    super.key,
  });

  final FiltreMessages current;
  final ValueChanged<FiltreMessages> onSelect;
  final UserRole? role;

  List<(FiltreMessages, String)> get _items {
    switch (role) {
      case UserRole.farmer:
        return const [
          (FiltreMessages.tous, 'Tous'),
          (FiltreMessages.acheteurs, 'Acheteurs'),
          (FiltreMessages.cooperatives, 'Coopératives'),
          (FiltreMessages.transporteurs, 'Transporteurs'),
        ];
      case UserRole.buyer:
        return const [
          (FiltreMessages.tous, 'Tous'),
          (FiltreMessages.producteurs, 'Producteurs'),
          (FiltreMessages.cooperatives, 'Coopératives'),
          (FiltreMessages.transporteurs, 'Transporteurs'),
        ];
      case UserRole.cooperative:
        return const [
          (FiltreMessages.tous, 'Tous'),
          (FiltreMessages.farmers, 'Farmers'),
          (FiltreMessages.acheteurs, 'Acheteurs'),
          (FiltreMessages.transporteurs, 'Transporteurs'),
        ];
      case UserRole.transporter:
        return const [
          (FiltreMessages.tous, 'Tous'),
          (FiltreMessages.producteurs, 'Producteurs'),
          (FiltreMessages.acheteurs, 'Acheteurs'),
          (FiltreMessages.cooperatives, 'Coopératives'),
        ];
      default:
        return const [(FiltreMessages.tous, 'Tous')];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAcheteur = role == UserRole.buyer;
    final items = _items;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isAcheteur ? 20 : AppDimens.pagePaddingH,
        0,
        isAcheteur ? 20 : AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: SizedBox(
        height: isAcheteur ? 30 : 28,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final (value, label) = items[i];
            final active = value == current;
            return InkWell(
              onTap: () => onSelect(value),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: isAcheteur ? 7 : 6,
                ),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.border,
                    width: AppDimens.borderThin,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: isAcheteur ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? AppColors.onPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
