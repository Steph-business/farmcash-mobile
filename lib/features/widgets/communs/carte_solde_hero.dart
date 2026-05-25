import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

const Color _kPastelVert = Color(0xFFE8F5E9);
final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Carte hero affichant le **solde wallet** de l'acheteur en haut de
/// l'accueil. Pattern simple et puissant pour un user low-tech :
///   - Petit label « Solde disponible » au-dessus
///   - Gros montant en Poppins (variation primary) qui saute aux yeux
///   - CTA primaire pleine largeur « Mon portefeuille »
///
/// Pendant le chargement, [solde] est `null` → on affiche un placeholder
/// « — F » discret pour ne pas faire sauter le layout.
class CarteSoldeHero extends StatelessWidget {
  const CarteSoldeHero({
    required this.solde,
    required this.onOuvrirWallet,
    this.titre = 'Solde disponible',
    this.labelBouton = 'Mon portefeuille',
    super.key,
  });

  /// Montant en FCFA. `null` pendant le chargement.
  final double? solde;

  /// Callback tap sur le bouton → push vers la page wallet du rôle.
  final VoidCallback onOuvrirWallet;

  /// Label affiché au-dessus du montant (« Solde disponible » par défaut,
  /// peut être remplacé par « Solde coopérative », « Mes gains », etc.).
  final String titre;

  /// Texte du bouton primaire (« Mon portefeuille » par défaut).
  final String labelBouton;

  @override
  Widget build(BuildContext context) {
    final montant = solde != null ? _nf.format(solde!.round()) : '—';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: _kPastelVert,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            titre,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: montant,
                  style: AppTextStyles.displayLarge.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.7,
                    height: 1.05,
                  ),
                ),
                TextSpan(
                  text: ' FCFA',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          AppDimens.vGap12,
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: onOuvrirWallet,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 18,
                      color: AppColors.onPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      labelBouton,
                      style: AppTextStyles.button.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
