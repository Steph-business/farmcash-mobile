import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Lien collant en bas de la page bordereau d'enlèvement : permet au
/// producteur de signaler un problème si le transporteur n'arrive pas.
///
/// Pousse vers la vraie page « Signaler un problème » (motifs radio
/// prédéfinis, page existante via `signalerProblemePathFor`). Avant le
/// 2026-06-05 c'était un stub snackbar « à venir » alors que la page
/// existait depuis longtemps.
class StickyLinkEnlevement extends StatelessWidget {
  const StickyLinkEnlevement({super.key, required this.commandeId});

  /// Identifiant de la commande source — utilisé pour lier le litige
  /// au bon ordre côté backend.
  final String commandeId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        // Shadow soft top → effet plateau flottant qui décolle le sticky du
        // contenu scrollable au-dessus.
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        // Padding bottom plus généreux pour éviter que le lien soit
        // collé au home indicator iPhone — même si SafeArea ajoute le
        // safe inset, on rajoute 4px de marge perçue pour ne pas avoir
        // l'air d'être "à la limite".
        minimum: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Center(
            child: InkWell(
              onTap: () => context.push(
                RouteNames.signalerProblemePathFor(commandeId),
              ),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.flag_outlined,
                      size: 15,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Pas de transporteur ? Signaler un problème',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
