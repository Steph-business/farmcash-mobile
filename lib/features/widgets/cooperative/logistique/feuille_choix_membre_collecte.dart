import 'package:flutter/material.dart';

import '../../../../models/membre_coop.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Bottomsheet de sélection d'un membre de la coopérative pour la
/// planification d'une collecte. Retourne le `MembreCoop` choisi ou `null`
/// si l'utilisateur ferme sans choisir.
Future<MembreCoop?> ouvrirFeuilleChoixMembreCollecte(
  BuildContext context, {
  required List<MembreCoop> membres,
}) {
  return showModalBottomSheet<MembreCoop>(
    context: context,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.6,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(
                  'Choisir un membre',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: membres.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun membre dans la coop',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: membres.length,
                        itemBuilder: (_, i) {
                          final m = membres[i];
                          return ListTile(
                            title: Text(m.fullName ?? m.userId),
                            subtitle:
                                m.phone != null ? Text(m.phone!) : null,
                            onTap: () => Navigator.of(ctx).pop(m),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
