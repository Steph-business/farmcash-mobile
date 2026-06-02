import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/enums.dart';
import '../../../../services/orders_service.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

final _nf = NumberFormat('#,##0', 'fr_FR');

/// Carte commande côté producteur — design simplifié, scannable d'un
/// coup d'œil. Calque le même pattern que la carte acheteur pour une
/// cohérence cross-rôle. Affiche le **net** (après frais 3 %) côté
/// montant — c'est ce que le producteur va réellement toucher.
///
/// ```
/// ┌──────────────────────────────────────────────┐
/// │ [B]  Banane plantain · 545 kg     Détails ›  │
/// │      Buyer Test                              │
/// ├──────────────────────────────────────────────┤
/// │ 290 758 FCFA                  ● Acceptée     │
/// ├ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤
/// │ → À préparer pour le transporteur            │
/// └──────────────────────────────────────────────┘
/// ```
class CarteCommandeListe extends StatelessWidget {
  const CarteCommandeListe({
    super.key,
    required this.item,
    required this.onTap,
  });

  final OrderListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = item.commande;
    final clientNom = (item.buyerName?.trim().isNotEmpty ?? false)
        ? item.buyerName!.trim()
        : 'Acheteur';
    final qte = '${_nf.format(c.quantiteKg.round())} kg';
    final brut = c.montantTotal;
    // Net producteur = brut × (1 - 3 %). Aligné sur le calcul du détail.
    final netLabel = _nf.format((brut * 0.97).round());
    final produit = (item.produitNom ?? '').trim().isNotEmpty
        ? item.produitNom!
        : 'Produit';
    final action = _actionRequise(c.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
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
                // Header : avatar acheteur + produit·qté (titre) + acheteur
                // (sous-ligne) + lien « Détails ».
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _AvatarAcheteur(
                        nom: clientNom,
                        photoUrl: item.buyerPhotoUrl,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Ligne 1 : QUOI a été vendu (produit + qté)
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
                            // Ligne 2 : À QUI (acheteur)
                            Text(
                              clientNom,
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
                // Ligne unique : montant net à recevoir + chip statut.
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
                                text: netLabel,
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
                      _ChipStatut(
                        status: c.status,
                        escrow: c.escrowReleased,
                      ),
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

  /// Action contextuelle attendue côté producteur. Affichée en bandeau
  /// ambré en pied de carte.
  String? _actionRequise(OrderStatus s) {
    switch (s) {
      case OrderStatus.sent:
        return 'À accepter ou rejeter';
      case OrderStatus.accepted:
        return 'À préparer pour le transporteur';
      case OrderStatus.inProgress:
        return 'Livraison en cours';
      case OrderStatus.disputed:
        return 'Litige en cours';
      default:
        return null;
    }
  }
}

class _AvatarAcheteur extends StatelessWidget {
  const _AvatarAcheteur({required this.nom, required this.photoUrl});

  final String nom;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 44,
        height: 44,
        color: AppColors.primary,
        alignment: Alignment.center,
        child: hasPhoto
            ? CachedNetworkImage(
                imageUrl: photoUrl!,
                fit: BoxFit.cover,
                width: 44,
                height: 44,
                placeholder: (_, _) => _Initiale(nom: nom),
                errorWidget: (_, _, _) => _Initiale(nom: nom),
              )
            : _Initiale(nom: nom),
      ),
    );
  }
}

class _Initiale extends StatelessWidget {
  const _Initiale({required this.nom});
  final String nom;

  @override
  Widget build(BuildContext context) {
    final n = nom.trim();
    final lettre = n.isEmpty ? '?' : n.characters.first.toUpperCase();
    return Container(
      color: AppColors.primary,
      alignment: Alignment.center,
      child: Text(
        lettre,
        style: AppTextStyles.titleMedium.copyWith(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
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

/// Chip statut compact partagé avec la carte acheteur — mêmes couleurs
/// cross-rôle (BLEU = attend producteur, ORANGE = transporteur en route,
/// VERT = livré, ROUGE = blocage).
class _ChipStatut extends StatelessWidget {
  const _ChipStatut({required this.status, required this.escrow});
  final OrderStatus status;
  final bool escrow;

  @override
  Widget build(BuildContext context) {
    final (label, color, fond) = _spec(status, escrow);
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

  /// Cycle de vie côté producteur :
  /// - 🔵 Bleu : commande à traiter (acheteur a payé) — Nouvelle / Acceptée
  /// - 🟠 Orange : transporteur a pris la marchandise — En transport
  /// - 🟢 Vert : livré / clôturé — escrow libéré, l'argent est arrivé
  /// - 🔴 Rouge : rejet / litige
  /// - ⚪ Gris : annulée / inconnu
  (String, Color, Color) _spec(OrderStatus s, bool escrow) {
    const bleu = Color(0xFF1E40AF);
    const fondBleu = Color(0xFFDBEAFE);
    const orange = Color(0xFFB45309);
    const fondOrange = Color(0xFFFFF3CD);
    const fondVert = Color(0xFFE8F5E9);
    const fondRouge = Color(0xFFFEE2E2);
    const fondGris = AppColors.surfaceSoft;
    switch (s) {
      case OrderStatus.sent:
        return ('Nouvelle', bleu, fondBleu);
      case OrderStatus.accepted:
        return ('Acceptée', bleu, fondBleu);
      case OrderStatus.inProgress:
        return ('En transport', orange, fondOrange);
      case OrderStatus.delivered:
        return ('Livrée', AppColors.primary, fondVert);
      case OrderStatus.completed:
        return (
          escrow ? 'Payée' : 'Clôturée',
          AppColors.primary,
          fondVert,
        );
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
