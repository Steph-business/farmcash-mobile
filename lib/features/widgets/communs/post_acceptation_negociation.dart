// =====================================================================
//  Helper post-acceptation négociation
//  ---------------------------------------------------------------------
//  Quand un acheteur accepte une proposition (ou une contre-offre coop),
//  le backend crée AUTOMATIQUEMENT la commande au prix négocié et
//  retourne { message, commande_id, reference }.
//
//  Avant ce helper : le mobile IGNORAIT commande_id → la commande créée
//  restait orpheline et était supprimée par le cron 24h plus tard.
//
//  Maintenant : on snackbar enrichi + navigation vers le détail commande
//  où l'acheteur paye au prix négocié.
// =====================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/negociation.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'snackbars.dart';

/// Affiche un snackbar premium signalant qu'une commande a été créée
/// (après acceptation d'une négociation) et navigue vers le détail
/// commande où l'acheteur pourra la payer au prix négocié.
///
/// [result] = retour de traiterCandidature/traiterProposition/
/// traiterContreOffreCoop.
///
/// Si `commande_id` est absent (cas REJECTED, COUNTER_OFFER, CANCELLED),
/// affiche juste un snackbar succès simple.
Future<void> apresAcceptationNegociation(
  BuildContext context,
  TraitementNegociationResultat result, {
  required bool fromAcheteurSide,
}) async {
  final commandeId = result.commandeId;
  if (commandeId == null || commandeId.isEmpty) {
    // Pas d'acceptation = pas de commande créée.
    Snackbars.showSucces(
      context,
      result.message.isNotEmpty ? result.message : 'Action enregistrée.',
    );
    return;
  }

  // Côté acheteur : montrer un snackbar premium avec action « Payer ».
  // Côté vendeur (producteur/coop qui accepte une candidature acheteur) :
  // pas d'action — le vendeur n'a rien à payer, c'est l'acheteur.
  if (!fromAcheteurSide) {
    Snackbars.showSucces(
      context,
      'Offre acceptée · commande créée (réf. ${result.reference ?? "—"}).',
    );
    return;
  }

  // Snackbar enrichi avec bouton inline « Payer ».
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 7),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      content: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Commande créée 🎉',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  result.reference != null
                      ? 'Réf. ${result.reference} · prête à payer'
                      : 'Prête à payer au prix négocié',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      action: SnackBarAction(
        label: 'Payer',
        textColor: Colors.white,
        onPressed: () {
          context.push(RouteNames.acheteurCommandeDetailPathFor(commandeId));
        },
      ),
    ),
  );

  // Navigation automatique après 1 seconde pour ne pas bloquer
  // l'utilisateur si le snackbar disparaît trop vite.
  await Future<void>.delayed(const Duration(milliseconds: 600));
  if (!context.mounted) return;
  context.push(RouteNames.acheteurCommandeDetailPathFor(commandeId));
}
