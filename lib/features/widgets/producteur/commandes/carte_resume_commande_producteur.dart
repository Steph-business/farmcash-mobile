import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/commande.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Carte résumé commande pliable côté producteur — affiche le produit
/// commandé en titre + 3 chiffres clés (montant net à recevoir, prix
/// unitaire, quantité). Au tap, la carte se déplie pour révéler la
/// décomposition brut / frais / net + la référence courte.
///
/// ```
/// ┌──────────────────────────────────────────────┐
/// │ Banane plantain                              │
/// │                                              │
/// │ Montant à recevoir       290 758 FCFA        │
/// │ Prix unitaire                 550 FCFA       │
/// │ Quantité à livrer             545 kg         │
/// │                       ⌄                      │
/// └──────────────────────────────────────────────┘
/// ```
///
/// Pattern miroir de la carte résumé côté acheteur — même UX, montants
/// adaptés (net après frais 3 %, "à recevoir" au lieu de "à facturer").
class CarteResumeCommandeProducteur extends StatefulWidget {
  /// Construit la carte résumé producteur.
  const CarteResumeCommandeProducteur({
    required this.commande,
    required this.produitNom,
    required this.brut,
    required this.frais,
    required this.net,
    super.key,
  });

  /// Commande source (pour la référence et le statut escrow).
  final Commande commande;

  /// Nom du produit affiché en titre.
  final String produitNom;

  /// Montant brut commande (qte × prix/kg).
  final double brut;

  /// Frais FarmCash (3 % du brut).
  final double frais;

  /// Net producteur (brut − frais).
  final double net;

  @override
  State<CarteResumeCommandeProducteur> createState() =>
      _CarteResumeCommandeProducteurState();
}

class _CarteResumeCommandeProducteurState
    extends State<CarteResumeCommandeProducteur> {
  bool _expanded = false;

  /// Quantité formatée — en tonnes si ≥ 1000 kg, sinon en kg.
  String _quantiteLabel() {
    final kg = widget.commande.quantiteKg;
    if (kg >= 1000) {
      final tonnes = kg / 1000;
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
    final net = _nf.format(widget.net.round());
    final brut = _nf.format(widget.brut.round());
    final frais = _nf.format(widget.frais.round());
    final prixUnit = _nf.format(c.prixUnitaireKg.round());
    final quantite = _quantiteLabel();
    final refCourte = c.reference.isNotEmpty
        ? c.reference
        : c.id.substring(0, 8).toUpperCase();
    final statutEscrow = c.escrowReleased
        ? 'Paiement libéré · arrivé dans ton wallet'
        : 'Bloqué en escrow · libéré à la confirmation de réception';

    return Container(
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
                  widget.produitNom,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                AppDimens.vGap12,
                _LigneResume(
                  label: 'Montant à recevoir',
                  valeur: '$net FCFA',
                  valeurEnGras: true,
                ),
                AppDimens.vGap8,
                _LigneResume(
                  label: 'Prix unitaire',
                  valeur: '$prixUnit FCFA',
                ),
                AppDimens.vGap8,
                _LigneResume(
                  label: 'Quantité à livrer',
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
                  _LigneResume(
                    label: 'Montant brut',
                    valeur: '$brut FCFA',
                  ),
                  AppDimens.vGap8,
                  _LigneResume(
                    label: 'Frais FarmCash (3 %)',
                    valeur: '− $frais FCFA',
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

/// Ligne label/valeur compacte avec ellipsis sur le label.
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
