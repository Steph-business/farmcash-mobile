import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/buyer_address.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Adresse de livraison par défaut du BUYER, si elle existe.
final defaultBuyerAddressProvider =
    FutureProvider.autoDispose<BuyerAddress?>((ref) async {
  final addresses = await ref.read(buyerServiceProvider).listAddresses();
  for (final a in addresses) {
    if (a.isDefault) return a;
  }
  return addresses.isEmpty ? null : addresses.first;
});

/// Carte « Adresse de livraison » sur le panier acheteur : récupère
/// l'adresse par défaut du buyer et propose un bouton « Modifier » /
/// « Choisir » selon qu'une adresse existe ou non.
class CarteAdressePanier extends ConsumerWidget {
  const CarteAdressePanier({required this.onModifier, super.key});
  final VoidCallback onModifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(defaultBuyerAddressProvider);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _addrContent(async)),
          InkWell(
            onTap: onModifier,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                async.maybeWhen(
                  data: (a) => a == null ? 'Choisir' : 'Modifier',
                  orElse: () => 'Modifier',
                ),
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addrContent(AsyncValue<BuyerAddress?> async) {
    return async.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Chargement de l\'adresse…',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      error: (_, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Adresse indisponible',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Configure une adresse pour la livraison',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      data: (addr) {
        if (addr == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choisir une adresse',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Sélectionne ton adresse de livraison',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        }
        final adresseComplete = addr.adresseComplete.trim();
        final ville = addr.villeNom?.trim();
        final adresseLine = [
          if (adresseComplete.isNotEmpty) adresseComplete,
          if (ville != null && ville.isNotEmpty) ville,
        ].join(' · ');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              addr.libelle,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (adresseLine.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                adresseLine,
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        );
      },
    );
  }
}
