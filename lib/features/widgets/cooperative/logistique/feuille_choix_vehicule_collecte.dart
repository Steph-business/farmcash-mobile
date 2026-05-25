import 'package:flutter/material.dart';

import '../../../../models/coop_vehicle.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Bottomsheet de sélection d'un véhicule pour la collecte coopérative.
/// Permet aussi de choisir « Aucun » (à assigner plus tard).
///
/// Retourne le `CoopVehicle` sélectionné, ou `null` si l'utilisateur a
/// choisi « Aucun » OU dismiss le bottomsheet (sémantique d'origine).
Future<CoopVehicle?> ouvrirFeuilleChoixVehiculeCollecte(
  BuildContext context, {
  required List<CoopVehicle> vehicles,
}) {
  return showModalBottomSheet<CoopVehicle?>(
    context: context,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return SafeArea(
        top: false,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Text(
                'Choisir un véhicule (optionnel)',
                style: AppTextStyles.titleSmall.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.clear,
                color: AppColors.textSecondary,
              ),
              title: const Text('Aucun (à assigner plus tard)'),
              onTap: () => Navigator.of(ctx).pop(null),
            ),
            for (final v in vehicles)
              ListTile(
                leading: const Icon(
                  Icons.local_shipping_outlined,
                  color: AppColors.primary,
                ),
                title: Text(
                  (v.marque ?? '').isEmpty
                      ? '${v.type} · ${v.immatriculation ?? '—'}'
                      : '${v.marque!} ${v.type} · ${v.immatriculation ?? '—'}',
                ),
                subtitle: Text('${v.chargeMaxKg.round()} kg max'),
                onTap: () => Navigator.of(ctx).pop(v),
              ),
          ],
        ),
      );
    },
  );
}
