import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/enums.dart';
import '../../../../services/orders_service.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../demandes/mapper_annonce_achat.dart' show thumbnailPourProduit;

final _nf = NumberFormat('#,##0', 'fr_FR');

/// Carte commande côté acheteur — design simplifié, scannable d'un coup
/// d'œil.
///
/// ```
/// ┌──────────────────────────────────────────────┐
/// │ [🍌]  Banane plantain · 545 kg   Détails ›  │  ← photo PRODUIT + lien
/// │       N'DAH STEPHANE                         │
/// ├──────────────────────────────────────────────┤
/// │ 299 750 FCFA                  ● Acceptée     │  ← montant + chip statut
/// ├ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤
/// │ → Voir mon QR de réception (si action req.)  │
/// └──────────────────────────────────────────────┘
/// ```
///
/// Choix de design :
/// - **Vignette = photo générique de la culture** (mangue, banane,
///   manioc…), même thumbnail que l'onglet Négociations pour cohérence
///   visuelle entre les deux listes.
/// - **Lien « Détails › »** à droite du titre : la carte entière est
///   cliquable, c'est juste l'affordance visuelle (pas un CTA massif).
/// - **Montant + chip statut sur la même ligne** en bas : structure
///   « QUOI on a acheté » en haut, « COMBIEN + OÙ ÇA EN EST » en bas.
class CarteCommandeAcheteur extends StatelessWidget {
  const CarteCommandeAcheteur({
    required this.item,
    required this.onTap,
    super.key,
  });

  /// Commande jointe avec les infos vendeur + produit.
  final OrderListItem item;

  /// Callback tap → navigation vers le détail.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = item.commande;
    final qte = '${_nf.format(c.quantiteKg.round())} kg';
    final total = _nf.format(c.montantTotal.round());
    final vendeur = (item.sellerName ?? '').trim().isNotEmpty
        ? item.sellerName!
        : 'Vendeur';
    final produit = (item.produitNom ?? '').trim().isNotEmpty
        ? item.produitNom!
        : 'Produit';
    final action = _actionRequise(c.status, c.escrowReleased);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // En-tête : avatar produit + titre (produit·qté) + sous-titre
                // (vendeur) + lien « Détails ».
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _ThumbnailProduit(produit: produit),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$produit · $qte',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              vendeur,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _LienDetails(),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                  thickness: AppDimens.borderThin,
                  color: AppColors.border,
                ),
                // Ligne unique : montant total + chip statut compacte.
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: total,
                                style: AppTextStyles.headlineSmall.copyWith(
                                  fontFamily: 'Poppins',
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text,
                                  letterSpacing: -0.3,
                                  height: 1.0,
                                ),
                              ),
                              TextSpan(
                                text: ' FCFA',
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
                      const SizedBox(width: 8),
                      _ChipStatut(status: c.status),
                    ],
                  ),
                ),
                if (action != null) _BandeauAction(message: action),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _actionRequise(OrderStatus s, bool escrowReleased) {
    if (escrowReleased) return null;
    switch (s) {
      case OrderStatus.delivered:
        return 'À confirmer · libère le paiement';
      case OrderStatus.inProgress:
        return 'Voir mon QR de réception';
      case OrderStatus.disputed:
        return 'Litige en cours';
      default:
        return null;
    }
  }
}

/// Vignette 44×44 du produit. On utilise les mêmes thumbnails génériques
/// que l'onglet Négociations (`thumbnailPourProduit`) pour garder une
/// cohérence visuelle entre les deux listes. En cas d'échec de chargement
/// ou de produit inconnu, on retombe sur une icône feuille verte sur fond
/// pastel — sobre, ça n'introduit pas de bruit visuel.
class _ThumbnailProduit extends StatelessWidget {
  const _ThumbnailProduit({required this.produit});

  final String produit;

  @override
  Widget build(BuildContext context) {
    final url = thumbnailPourProduit(produit);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 44,
        height: 44,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, _) => const _Fallback(),
          errorWidget: (_, _, _) => const _Fallback(),
        ),
      ),
    );
  }
}

/// Carré pastel + icône feuille — utilisé pendant le chargement du
/// thumbnail ou si l'image distante échoue (réseau, 404…).
class _Fallback extends StatelessWidget {
  const _Fallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      color: const Color(0xFFE8F5E9),
      alignment: Alignment.center,
      child: const Icon(
        Icons.eco_outlined,
        size: 22,
        color: AppColors.primary,
      ),
    );
  }
}

class _LienDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Détails',
          style: AppTextStyles.button.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 2),
        const Icon(
          Icons.chevron_right,
          size: 18,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

/// Chip statut compact : pastille colorée + label. Aligné sur le cycle
/// vie de la commande (cf. `_spec` plus bas).
class _ChipStatut extends StatelessWidget {
  const _ChipStatut({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, fond) = _spec(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Spec couleur d'une étape du cycle de vie commande, alignée sur la
  /// progression vécue par l'acheteur :
  ///
  /// - 🔵 Bleu : il a payé, en attente que le producteur confirme avoir
  ///   remis la marchandise au transporteur (sent, accepted).
  /// - 🟠 Orange : le transporteur a pris la livraison et est en route
  ///   (inProgress).
  /// - 🟢 Vert : livré / clôturé — l'argent est libéré (delivered, completed).
  /// - 🔴 Rouge : la commande a un blocage (rejetée par le producteur,
  ///   litige ouvert).
  /// - ⚪ Gris : annulée / état inconnu (neutre, on n'attire pas l'œil).
  (String, Color, Color) _spec(OrderStatus s) {
    const bleu = Color(0xFF1E40AF);
    const fondBleu = Color(0xFFDBEAFE);
    const orange = Color(0xFFB45309);
    const fondOrange = Color(0xFFFFF3CD);
    const fondVert = Color(0xFFE8F5E9);
    const fondRouge = Color(0xFFFEE2E2);
    const fondGris = AppColors.surfaceSoft;
    switch (s) {
      case OrderStatus.sent:
        return ('En attente', bleu, fondBleu);
      case OrderStatus.accepted:
        return ('Acceptée', bleu, fondBleu);
      case OrderStatus.inProgress:
        return ('En cours', orange, fondOrange);
      case OrderStatus.delivered:
        return ('Livrée', AppColors.primary, fondVert);
      case OrderStatus.completed:
        return ('Clôturée', AppColors.primary, fondVert);
      case OrderStatus.rejected:
        return ('Rejetée', AppColors.error, fondRouge);
      case OrderStatus.disputed:
        return ('Litige', AppColors.error, fondRouge);
      case OrderStatus.cancelled:
        return ('Annulée', AppColors.textSecondary, fondGris);
      case OrderStatus.unknown:
        return ('—', AppColors.textSubtle, fondGris);
    }
  }
}

class _BandeauAction extends StatelessWidget {
  const _BandeauAction({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8E1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.arrow_circle_right_outlined,
            size: 16,
            color: Color(0xFFB45309),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFB45309),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
