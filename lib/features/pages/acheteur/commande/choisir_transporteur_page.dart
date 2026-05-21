import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../models/models.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Constantes ────────────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

// ─── Args devis ────────────────────────────────────────────────────────

/// Trio nécessaire pour interroger `logisticsService.getQuotes(...)`.
class _QuoteArgs {
  const _QuoteArgs({
    required this.origineZone,
    required this.destinationZone,
    required this.quantiteKg,
  });

  final String origineZone;
  final String destinationZone;
  final double quantiteKg;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _QuoteArgs &&
          other.origineZone == origineZone &&
          other.destinationZone == destinationZone &&
          other.quantiteKg == quantiteKg;

  @override
  int get hashCode => Object.hash(origineZone, destinationZone, quantiteKg);
}

final _quotesProvider = FutureProvider.autoDispose
    .family<List<TransportQuote>, _QuoteArgs>((ref, args) async {
  return ref.read(logisticsServiceProvider).getQuotes(
        origineZone: args.origineZone,
        destinationZone: args.destinationZone,
        quantiteKg: args.quantiteKg,
      );
});

/// Choix du transporteur depuis le flow de paiement acheteur.
///
/// Reçoit en arguments [origineZone], [destinationZone] et [quantiteKg]
/// via les `extras` de la route. Si l'un manque, on affiche un état vide
/// expliquant qu'il faut passer par le flow paiement.
class ChoisirTransporteurPage extends ConsumerWidget {
  const ChoisirTransporteurPage({
    super.key,
    this.origineZone,
    this.destinationZone,
    this.quantiteKg,
  });

  final String? origineZone;
  final String? destinationZone;
  final double? quantiteKg;

  bool get _hasArgs =>
      (origineZone?.isNotEmpty ?? false) &&
      (destinationZone?.isNotEmpty ?? false) &&
      quantiteKg != null &&
      quantiteKg! > 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Expanded(child: _body(context, ref)),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref) {
    if (!_hasArgs) {
      return const _MissingArgsState();
    }
    final args = _QuoteArgs(
      origineZone: origineZone!,
      destinationZone: destinationZone!,
      quantiteKg: quantiteKg!,
    );
    final async = ref.watch(_quotesProvider(args));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: AppDimens.space32),
        child: Chargement(size: 22),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(AppDimens.pagePaddingH),
        child: VueErreur(
          message: 'Impossible de charger les devis transport. $e',
          onRetry: () => ref.invalidate(_quotesProvider(args)),
        ),
      ),
      data: (quotes) {
        if (quotes.isEmpty) {
          return _EmptyQuotesState(args: args);
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          children: [
            _InfoTrip(args: args),
            const SizedBox(height: 14),
            for (var i = 0; i < quotes.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TransporteurCard(
                  quote: quotes[i],
                  isBest: i == 0,
                  onChoose: () => Navigator.of(context).pop(quotes[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Choisir mon transporteur',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bandeau info trajet ───────────────────────────────────────────────

class _InfoTrip extends StatelessWidget {
  const _InfoTrip({required this.args});
  final _QuoteArgs args;
  @override
  Widget build(BuildContext context) {
    final qte = _nf.format(args.quantiteKg.round());
    return Container(
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.local_shipping_outlined,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Trajet : ${args.origineZone} → ${args.destinationZone} · $qte kg',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card transporteur ─────────────────────────────────────────────────

class _TransporteurCard extends StatelessWidget {
  const _TransporteurCard({
    required this.quote,
    required this.isBest,
    required this.onChoose,
  });
  final TransportQuote quote;
  final bool isBest;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final nom = quote.transporterName.isNotEmpty
        ? quote.transporterName
        : 'Transporteur';
    final delai = quote.delaiTypique?.trim();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBest ? AppColors.primary : AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.local_shipping_outlined,
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
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      nom,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isBest) const _BestPriceChip(),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  quote.rating > 0
                      ? '${quote.rating.toStringAsFixed(1)} ★'
                      : 'Nouveau',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_nf.format(quote.tarifTotal)} F',
                            style: AppTextStyles.titleSmall.copyWith(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (delai != null && delai.isNotEmpty)
                            Text(
                              delai,
                              style: AppTextStyles.labelSmall.copyWith(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onChoose,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primary,
                            width: AppDimens.borderThin,
                          ),
                        ),
                        child: Text(
                          'Choisir',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BestPriceChip extends StatelessWidget {
  const _BestPriceChip();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Meilleur prix',
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ─── États vides ───────────────────────────────────────────────────────

class _MissingArgsState extends StatelessWidget {
  const _MissingArgsState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 44,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Devis transport indisponibles',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: AppDimens.space8),
            Text(
              'Ouvre cette page depuis l\'écran de paiement\nd\'une commande pour comparer les transporteurs.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyQuotesState extends StatelessWidget {
  const _EmptyQuotesState({required this.args});
  final _QuoteArgs args;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 44,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Aucun devis pour ce trajet',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: AppDimens.space8),
            Text(
              'Aucun transporteur n\'a déclaré une route\n${args.origineZone} → ${args.destinationZone}.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ───────────────────────────────────────────────────────────

final _nf = NumberFormat('#,##0', 'fr_FR');
