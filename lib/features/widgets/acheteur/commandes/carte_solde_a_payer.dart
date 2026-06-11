import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/commande.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/snackbars.dart';

/// Carte premium « Solde à payer » — affichée sur le détail d'une
/// commande en mode STAGED quand le dépôt a déjà été payé mais que le
/// solde reste dû. Apparaît typiquement à partir du moment où la
/// livraison est imminente (commande au statut ACCEPTED, IN_PROGRESS
/// ou DELIVERED).
///
/// Pattern : gradient vert plein + montant clair + CTA « Payer le solde »
/// qui appelle l'endpoint `POST /orders/:id/pay` (2e appel — backend
/// route automatiquement vers payBalanceStaged).
///
/// Visible uniquement si :
///   • paymentMode == STAGED
///   • depositPaidAt != null
///   • balancePaidAt == null
/// Sinon → SizedBox.shrink().
class CarteSoldeAPayer extends ConsumerStatefulWidget {
  const CarteSoldeAPayer({
    super.key,
    required this.commande,
    required this.onPaye,
  });

  final Commande commande;

  /// Appelé après un paiement réussi pour que le parent rafraîchisse
  /// les données (invalidate provider).
  final VoidCallback onPaye;

  @override
  ConsumerState<CarteSoldeAPayer> createState() => _CarteSoldeAPayerState();
}

class _CarteSoldeAPayerState extends ConsumerState<CarteSoldeAPayer> {
  bool _busy = false;

  Future<void> _payerSolde() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(ordersServiceProvider).payOrder(
            id: widget.commande.id,
            idempotencyKey: 'balance-${widget.commande.id}-${widget.commande.updatedAt?.millisecondsSinceEpoch ?? 0}',
          );
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        'Solde payé · le vendeur sera réglé à la livraison confirmée.',
      );
      widget.onPaye();
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.commande;
    // Visible uniquement pour les commandes STAGED avec dépôt payé mais
    // solde encore dû.
    if (c.paymentMode != 'STAGED') return const SizedBox.shrink();
    if (c.depositPaidAt == null) return const SizedBox.shrink();
    if (c.balancePaidAt != null) return const SizedBox.shrink();

    final deposit = c.depositAmount ?? 0;
    final solde = c.montantTotal - deposit;
    final nf = NumberFormat('#,##0', 'fr_FR');

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: _busy ? null : _payerSolde,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryHover],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.30),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 19,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Solde à payer',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontFamily: 'Poppins',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '${nf.format(solde.round())} F CFA',
                            style: AppTextStyles.titleLarge.copyWith(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Mini breakdown rappelant ce qui a déjà été payé.
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Acompte déjà versé : ${nf.format(deposit.round())} F',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.92),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: AppDimens.buttonHeightSmall,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _payerSolde,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppDimens.brButton,
                      ),
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: AppColors.primary,
                            ),
                          )
                        : Text(
                            'Payer le solde maintenant',
                            style: AppTextStyles.button.copyWith(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
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
