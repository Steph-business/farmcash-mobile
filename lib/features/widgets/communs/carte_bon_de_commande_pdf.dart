import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';

import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'snackbars.dart';

/// Provider : check d'éligibilité au bon de commande PDF.
/// Cache court (auto-dispose) — le résultat est stable pour une
/// commande donnée (le seuil 500 kg ne bouge pas).
final bonDeCommandeEligibleProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, orderId) async {
  return ref.read(ordersServiceProvider).isBonDeCommandeEligible(orderId);
});

/// Carte « Télécharger le bon de commande » premium — affichée sur la
/// page détail d'une commande coop ≥ 500 kg. Visible UNIQUEMENT si
/// l'endpoint backend valide l'éligibilité. Tap → download + ouverture
/// dans le viewer PDF natif (iOS Books / Android PDF viewer).
class CarteBonDeCommandePdf extends ConsumerStatefulWidget {
  const CarteBonDeCommandePdf({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<CarteBonDeCommandePdf> createState() =>
      _CarteBonDeCommandePdfState();
}

class _CarteBonDeCommandePdfState
    extends ConsumerState<CarteBonDeCommandePdf> {
  bool _loading = false;

  Future<void> _telecharger() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final path = await ref
          .read(ordersServiceProvider)
          .downloadBonDeCommande(widget.orderId);
      if (!mounted) return;
      final result = await OpenFilex.open(path);
      if (!mounted) return;
      // open_filex peut échouer silencieusement si aucune app PDF —
      // on log et on signale à l'utilisateur si applicable.
      if (result.type != ResultType.done) {
        Snackbars.showInfo(
          context,
          'Bon de commande téléchargé : ${path.split('/').last}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(bonDeCommandeEligibleProvider(widget.orderId));
    final eligible = async.maybeWhen(data: (v) => v, orElse: () => false);
    if (!eligible) return const SizedBox.shrink();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: _loading ? null : _telecharger,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Bon de commande PDF',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Document officiel pour ton archivage / compta',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (_loading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppColors.primary,
                  ),
                )
              else
                const Icon(
                  Icons.download_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
