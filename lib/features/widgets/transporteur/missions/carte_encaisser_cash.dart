// =====================================================================
//  Carte premium « Encaisser le cash » (transporteur)
//  ---------------------------------------------------------------------
//  Affichée sur le détail d'une mission EN COURS quand la commande est
//  en mode CASH_ON_DELIVERY et que le cash n'a pas encore été collecté.
//  Le transporteur saisit le montant exact reçu pour confirmer.
//
//  Chantier 3 mobile — Cash à la livraison.
// =====================================================================

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

/// Visible uniquement si :
///   - paymentMode == CASH_ON_DELIVERY
///   - depositPaidAt != null (acheteur a versé les 5 %)
///   - cashCollectedAt == null (cash pas encore confirmé)
class CarteEncaisserCash extends ConsumerStatefulWidget {
  const CarteEncaisserCash({
    super.key,
    required this.commande,
    required this.onConfirmed,
  });

  final Commande commande;
  final VoidCallback onConfirmed;

  @override
  ConsumerState<CarteEncaisserCash> createState() =>
      _CarteEncaisserCashState();
}

class _CarteEncaisserCashState extends ConsumerState<CarteEncaisserCash> {
  bool _busy = false;

  Future<void> _confirmer() async {
    if (_busy) return;
    final c = widget.commande;
    final deposit = c.depositAmount ?? 0;
    final cash = c.montantTotal - deposit;
    final nf = NumberFormat('#,##0', 'fr_FR');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la réception du cash ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu confirmes avoir reçu de l\'acheteur :',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${nf.format(cash.round())} F CFA en espèces',
                style: AppTextStyles.titleMedium.copyWith(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu devras ensuite remettre ce cash à la coop. '
              'La transaction est enregistrée sur le wallet vendeur.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Je confirme'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(ordersServiceProvider)
          .confirmCashDelivery(widget.commande.id);
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        'Cash confirmé · la commande est clôturée.',
      );
      widget.onConfirmed();
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
    if (c.paymentMode != 'CASH_ON_DELIVERY') return const SizedBox.shrink();
    if (c.depositPaidAt == null) return const SizedBox.shrink();
    if (c.cashCollectedAt != null) return const SizedBox.shrink();

    final deposit = c.depositAmount ?? 0;
    final cash = c.montantTotal - deposit;
    final nf = NumberFormat('#,##0', 'fr_FR');

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: const Color(0xFF92400E),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: _busy ? null : _confirmer,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFD97706), Color(0xFF92400E)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color:
                      const Color(0xFFD97706).withValues(alpha: 0.30),
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
                        Icons.payments_rounded,
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
                            'Cash à encaisser',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontFamily: 'Poppins',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color:
                                  Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '${nf.format(cash.round())} F CFA',
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
                          'Dépôt 5 % déjà versé · '
                          '${nf.format(deposit.round())} F',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color:
                                Colors.white.withValues(alpha: 0.92),
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
                  child: ElevatedButton.icon(
                    onPressed: _busy ? null : _confirmer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF92400E),
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppDimens.brButton,
                      ),
                    ),
                    icon: _busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Color(0xFF92400E),
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: Text(
                      _busy ? 'Confirmation…' : 'J\'ai reçu le cash',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF92400E),
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
