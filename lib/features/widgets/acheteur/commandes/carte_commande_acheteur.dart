import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/enums.dart';
import '../../../../services/orders_service.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

final _nf = NumberFormat('#,##0', 'fr_FR');
final _dfShort = DateFormat('d MMM', 'fr_FR');

/// Carte commande côté acheteur — design type « marketplace card » avec
/// hiérarchie d'info scannable d'un coup d'œil. Layout inspiré des apps
/// P2P de référence :
///
/// ```
/// ┌──────────────────────────────────────────────┐
/// │ [SK]  Stephy Koutouandah          Détails ›  │  ← header
/// │       Tomates · 850 kg                       │
/// ├──────────────────────────────────────────────┤
/// │ FCFA 1.700 /kg               Orange Money │  │
/// │                                              │
/// │ Montant payé    ·     297 500 FCFA           │
/// │ Statut          ·     [En cours]             │
/// └──────────────────────────────────────────────┘
/// ```
///
/// Si `Action requise` (à confirmer, voir QR, litige) → bandeau ambré en
/// pied. Sinon footer simple avec la date livraison.
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
    final ref = c.reference.isNotEmpty
        ? c.reference
        : c.id.substring(0, 6).toUpperCase();
    final qte = '${_nf.format(c.quantiteKg.round())} kg';
    final prixUnit = _nf.format(c.prixUnitaireKg.round());
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
                // En-tête : avatar vendeur + nom + sous-titre produit·qté
                // + lien « Détails »
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AvatarVendeur(
                        nom: vendeur,
                        photoUrl: item.sellerPhotoUrl,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              vendeur,
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
                              '$produit · $qte',
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
                // Corps : prix unitaire en hero + moyen paiement
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'FCFA ',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  TextSpan(
                                    text: prixUnit,
                                    style: AppTextStyles.headlineSmall
                                        .copyWith(
                                      fontFamily: 'Poppins',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.text,
                                      letterSpacing: -0.5,
                                      height: 1.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' /kg',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const _ChipPaiement(label: 'Wallet FarmCash'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _Ligne(
                        label: 'Montant payé',
                        valeur: '$total FCFA',
                        valeurEnVert: true,
                      ),
                      const SizedBox(height: 6),
                      _Ligne(
                        label: 'Réf · ${c.id.substring(0, 6).toUpperCase()}',
                        valeur: '#$ref',
                        valeurEnVert: false,
                      ),
                      const SizedBox(height: 6),
                      _StatutLigne(status: c.status),
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

/// Avatar carré arrondi 44×44 avec initiales si pas de photo. Garde le
/// même style que la section Acheteur côté producteur pour cohérence.
class _AvatarVendeur extends StatelessWidget {
  const _AvatarVendeur({required this.nom, required this.photoUrl});

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

/// Petite chip à droite indiquant le moyen de paiement (style barre
/// verticale + texte). À l'avenir, on l'alimentera avec `c.paymentProvider`
/// quand le backend renverra la valeur. Pour l'instant : « Wallet FarmCash ».
class _ChipPaiement extends StatelessWidget {
  const _ChipPaiement({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _Ligne extends StatelessWidget {
  const _Ligne({
    required this.label,
    required this.valeur,
    required this.valeurEnVert,
  });

  final String label;
  final String valeur;
  final bool valeurEnVert;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          valeur,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: valeurEnVert ? AppColors.primary : AppColors.text,
          ),
        ),
      ],
    );
  }
}

class _StatutLigne extends StatelessWidget {
  const _StatutLigne({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _spec(status);
    return Row(
      children: [
        Expanded(
          child: Text(
            'Statut transaction',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  (String, Color) _spec(OrderStatus s) {
    switch (s) {
      case OrderStatus.sent:
        return ('En attente', const Color(0xFFB45309));
      case OrderStatus.accepted:
        return ('Acceptée', AppColors.primary);
      case OrderStatus.rejected:
        return ('Rejetée', AppColors.error);
      case OrderStatus.inProgress:
        return ('En cours', AppColors.primary);
      case OrderStatus.delivered:
        return ('Livrée', AppColors.primary);
      case OrderStatus.completed:
        return ('Clôturée', AppColors.primary);
      case OrderStatus.disputed:
        return ('Litige', const Color(0xFFB45309));
      case OrderStatus.cancelled:
        return ('Annulée', AppColors.textSecondary);
      case OrderStatus.unknown:
        return ('—', AppColors.textSubtle);
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

// Petit helper pour la date de livraison (gardé pour usage futur).
// ignore: unused_element
String _dateLivraison(DateTime? d) {
  if (d == null) return '';
  return _dfShort.format(d);
}
