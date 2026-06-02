import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/annonce_vente.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/snackbars.dart';
import 'annonce_detail_constants.dart';

/// Carte titre du détail annonce — version compacte calée sur le
/// mockup de référence :
///
/// ```
/// Banane plantain                           [Équitable]
/// 700 F/kg
/// 200 kg disponibles
/// ─────────────────────────────────────────────────────
/// Vendeur : Coop T. ✓                       Voir profil ›
/// 📍 Sud-Comoé, Côte d'Ivoire
/// ```
///
/// Avant 2026-05-27 il y avait 3 cartes empilées (titre, vendeur,
/// origine) avec avatars et bordures. On regroupe tout en un seul
/// header compact, lisible d'un coup d'œil sans scroll.
class TitleCardAnnonce extends ConsumerWidget {
  const TitleCardAnnonce({
    required this.annonce,
    required this.qteDispo,
    super.key,
  });

  /// Annonce source — on lit nom, prix, vendeur, région via ses getters
  /// joints (vendeurNom, regionNom, …).
  final AnnonceVente annonce;

  /// Quantité dispo (déjà calculée par la page mère pour qu'on n'ait
  /// pas à reformatter en haut + en bas).
  final int qteDispo;

  /// Ouvre (ou retrouve) une conversation 1-1 avec le vendeur puis
  /// navigue vers la page chat. Permet à l'acheteur de poser ses
  /// questions AVANT de commander/ajouter au panier — pattern
  /// e-commerce classique (chat marchand).
  Future<void> _discuter(BuildContext context, WidgetRef ref, String vendeurId) async {
    try {
      final conv = await ref
          .read(messagingServiceProvider)
          .createConversation(participantIds: [vendeurId]);
      if (!context.mounted) return;
      context.push(RouteNames.chatDetailPathFor(conv.id));
    } on ApiException catch (e) {
      if (context.mounted) Snackbars.showErreur(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nom = annonce.produitLabel;
    final prix = annonce.prixParKg.round();
    final vendeur = annonce.vendeurNom?.trim();
    final localisation = annonce.localisationLabel?.trim();
    final vendeurId = annonce.vendeur?.id;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Ligne 1 : Nom + chip qualité ─────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  nom,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kAnnonceDetailPrimarySoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kAnnonceDetailPrimarySoft),
                ),
                child: Text(
                  qualiteLabelAnnonceDetail(annonce.qualite),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // ─── Prix gros ───────────────────────────────────────────
          Text(
            '${kAnnonceDetailNumFmt.format(prix)} F/kg',
            style: AppTextStyles.displaySmall.copyWith(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${kAnnonceDetailNumFmt.format(qteDispo)} kg disponibles',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),

          // ─── Ligne vendeur + lien voir profil ────────────────────
          if (vendeur != null && vendeur.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Vendeur : ',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextSpan(
                                text: vendeur,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Petite coche verte (vérifié) — à brancher sur un
                      // champ `users.is_verified` plus tard. Pour V1 on
                      // l'affiche toujours pour les annonces actives.
                      const Icon(
                        Icons.verified,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                if (vendeurId != null && vendeurId.isNotEmpty)
                  // « Discuter » remplace l'ancien « Voir profil » :
                  // l'acheteur peut poser ses questions au vendeur AVANT
                  // de négocier ou de commander (questions sur la
                  // qualité, le délai, le conditionnement, etc.).
                  InkWell(
                    onTap: () => _discuter(context, ref, vendeurId),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Discuter',
                            style: AppTextStyles.button.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],

          // ─── Localisation (icône + texte) ────────────────────────
          if (localisation != null && localisation.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.textSubtle,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    localisation,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
