import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/enums.dart';
import '../../../../services/orders_service.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

final _nf = NumberFormat('#,##0', 'fr_FR');

/// Carte commande côté producteur — design type « marketplace card »
/// scannable d'un coup d'œil. Calquée sur la carte acheteur pour
/// cohérence cross-rôle.
///
/// ```
/// ┌──────────────────────────────────────────────┐
/// │ [V]   Stephy K.                  Détails ›   │
/// │       Tomates · 850 kg                       │
/// ├──────────────────────────────────────────────┤
/// │ FCFA 1.700 /kg                Wallet FC │    │
/// │ Montant à recevoir   ·     288 575 FCFA      │
/// │ Statut transaction   ·     En cours          │
/// └──────────────────────────────────────────────┘
/// ```
///
/// Affiche le **net** (après frais 3 %) côté « Montant à recevoir ».
/// C'est ce que le producteur va réellement toucher — pas le brut.
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
    final prixUnit = _nf.format(c.prixUnitaireKg.round());
    final brut = c.montantTotal;
    // Net producteur = brut × (1 - 3 %). Aligné sur le calcul du détail.
    final net = (brut * 0.97).round();
    final netLabel = _nf.format(net);
    final produit = (item.produitNom ?? '').trim().isNotEmpty
        ? item.produitNom!
        : 'Produit';

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
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            Text(
                              clientNom,
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
                        label: 'Montant à recevoir',
                        valeur: '$netLabel FCFA',
                        valeurEnVert: true,
                      ),
                      const SizedBox(height: 6),
                      _StatutLigne(status: c.status, escrow: c.escrowReleased),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
  const _StatutLigne({required this.status, required this.escrow});
  final OrderStatus status;
  final bool escrow;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _spec(status, escrow);
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

  (String, Color) _spec(OrderStatus s, bool escrow) {
    switch (s) {
      case OrderStatus.sent:
        return ('Nouvelle', const Color(0xFFB45309));
      case OrderStatus.accepted:
        return ('Acceptée', AppColors.primary);
      case OrderStatus.rejected:
        return ('Rejetée', AppColors.error);
      case OrderStatus.inProgress:
        return ('En transport', AppColors.primary);
      case OrderStatus.delivered:
        return ('Livrée', AppColors.primary);
      case OrderStatus.completed:
        return (escrow ? 'Payée' : 'Clôturée', AppColors.primary);
      case OrderStatus.disputed:
        return ('Litige', const Color(0xFFB45309));
      case OrderStatus.cancelled:
        return ('Annulée', AppColors.textSecondary);
      case OrderStatus.unknown:
        return ('—', AppColors.textSubtle);
    }
  }
}
