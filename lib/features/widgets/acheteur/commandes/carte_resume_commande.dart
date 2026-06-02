import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../models/commande.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Carte résumé commande pliable — produit + 3 chiffres clés visibles,
/// reste des détails caché derrière un chevron. Remplace l'ancienne
/// section « Montants » qui prenait beaucoup de place.
///
/// ```
/// ┌──────────────────────────────────────────────┐
/// │ Anacarde                                     │
/// │                                              │
/// │ Montant à facturer        15 075 000 FCFA    │
/// │ Prix unitaire                  1 700 FCFA    │
/// │ Quantité à recevoir            10 Tonnes     │
/// │                       ⌄                      │
/// └──────────────────────────────────────────────┘
/// ```
///
/// Replié (défaut) : titre produit + 3 lignes ↓
/// Déplié : ajoute « Bloqué en escrow… » + référence courte de commande.
class CarteResumeCommande extends StatefulWidget {
  /// Construit la carte résumé.
  const CarteResumeCommande({
    required this.commande,
    this.annonce,
    super.key,
  });

  /// Commande source de vérité (montants, ref, statut escrow).
  final Commande commande;

  /// Annonce associée (pour récupérer le nom du produit). `null` si
  /// l'annonce a été dépubliée.
  final AnnonceVente? annonce;

  @override
  State<CarteResumeCommande> createState() => _CarteResumeCommandeState();
}

class _CarteResumeCommandeState extends State<CarteResumeCommande> {
  bool _expanded = false;

  String get _produitLabel {
    final n = widget.annonce?.produitLabel.trim();
    if (n != null && n.isNotEmpty) return n;
    return 'Produit';
  }

  /// Affiche la quantité en tonnes si > 1000 kg, sinon en kg pour rester
  /// lisible (10 Tonnes vs 10 000 kg).
  String _quantiteLabel() {
    final kg = widget.commande.quantiteKg;
    if (kg >= 1000) {
      final tonnes = kg / 1000;
      // Pas de décimale si entier, sinon 1 décimale.
      final fmt = tonnes == tonnes.roundToDouble()
          ? tonnes.toStringAsFixed(0)
          : tonnes.toStringAsFixed(1);
      return '$fmt Tonne${tonnes > 1 ? 's' : ''}';
    }
    return '${_nf.format(kg.round())} kg';
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.commande;
    final total = _nf.format(c.montantTotal.round());
    final prixUnit = _nf.format(c.prixUnitaireKg.round());
    final quantite = _quantiteLabel();
    final refCourte = c.reference.isNotEmpty
        ? c.reference
        : c.id.substring(0, 8).toUpperCase();
    final statutEscrow = c.escrowReleased
        ? 'Paiement libéré au vendeur'
        : 'Bloqué en escrow · libéré à la confirmation de réception';

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.pagePaddingH,
        vertical: AppDimens.space8,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _produitLabel,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                AppDimens.vGap12,
                _LigneResume(
                  label: 'Montant à facturer',
                  valeur: '$total FCFA',
                  valeurEnGras: true,
                ),
                AppDimens.vGap8,
                _LigneResume(
                  label: 'Prix unitaire',
                  valeur: '$prixUnit FCFA',
                ),
                AppDimens.vGap8,
                _LigneResume(
                  label: 'Quantité à recevoir',
                  valeur: quantite,
                ),
                if (_expanded) ...[
                  AppDimens.vGap12,
                  const Divider(
                    height: 1,
                    thickness: AppDimens.borderThin,
                    color: AppColors.border,
                  ),
                  AppDimens.vGap12,
                  // Statut escrow (icône cadenas + texte)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        c.escrowReleased
                            ? Icons.lock_open_outlined
                            : Icons.lock_outline,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          statutEscrow,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppDimens.vGap8,
                  _LigneResume(
                    label: 'Référence',
                    valeur: '#$refCourte',
                  ),
                ],
                Center(
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 150),
                    turns: _expanded ? 0.5 : 0,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 24,
                      color: AppColors.textSubtle,
                    ),
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

/// Ligne label/valeur compacte avec ellipsis sur le label si dépassement.
class _LigneResume extends StatelessWidget {
  const _LigneResume({
    required this.label,
    required this.valeur,
    this.valeurEnGras = false,
  });

  final String label;
  final String valeur;
  final bool valeurEnGras;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          valeur,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14,
            fontWeight: valeurEnGras ? FontWeight.w800 : FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}
