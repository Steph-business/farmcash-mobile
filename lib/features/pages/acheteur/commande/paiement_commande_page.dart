import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/annonce_vente.dart';
import '../../../../models/enums.dart';
import '../../../../models/wallet_with_transactions.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Constantes visuelles ──────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

// ─── Modes ──────────────────────────────────────────────────────────────

enum _DeliveryMode { auto, choisir }

class _PaymentChoice {
  const _PaymentChoice({
    required this.provider,
    required this.short,
    required this.name,
    required this.color,
    this.dark = false,
  });
  final MobileProvider provider;
  final String short;
  final String name;
  final Color color;
  final bool dark;
}

const List<_PaymentChoice> _kChoices = [
  _PaymentChoice(
    provider: MobileProvider.wallet,
    short: 'FC',
    name: 'Solde wallet',
    color: AppColors.primary,
  ),
  _PaymentChoice(
    provider: MobileProvider.orangeMoney,
    short: 'OM',
    name: 'Orange Money',
    color: Color(0xFFFF6B00),
  ),
  _PaymentChoice(
    provider: MobileProvider.mtnMomo,
    short: 'MTN',
    name: 'MTN MoMo',
    color: Color(0xFFFFCC00),
    dark: true,
  ),
  _PaymentChoice(
    provider: MobileProvider.wave,
    short: 'WV',
    name: 'Wave',
    color: AppColors.primary,
  ),
];

// ─── Provider ─────────────────────────────────────────────────────────

class _PaiementBundle {
  const _PaiementBundle({required this.annonce, required this.wallet});
  final AnnonceVente annonce;
  final WalletWithTransactions? wallet;
}

final _paiementBundleProvider = FutureProvider.autoDispose
    .family<_PaiementBundle, String>((ref, annonceId) async {
  final svc = ref.read(marketplaceServiceProvider);
  final finance = ref.read(financeServiceProvider);
  final results = await Future.wait<dynamic>([
    svc.getAnnonceVente(annonceId),
    finance.getWallet(limit: 1).then<Object?>((v) => v).catchError((_) => null),
  ]);
  return _PaiementBundle(
    annonce: results[0] as AnnonceVente,
    wallet: results[1] as WalletWithTransactions?,
  );
});

/// Paiement d'une commande (acheteur, depuis une annonce ferme).
class PaiementCommandePage extends ConsumerStatefulWidget {
  const PaiementCommandePage({
    required this.annonceId,
    this.quantiteKgInitiale,
    super.key,
  });

  final String annonceId;
  final int? quantiteKgInitiale;

  @override
  ConsumerState<PaiementCommandePage> createState() =>
      _PaiementCommandePageState();
}

class _PaiementCommandePageState extends ConsumerState<PaiementCommandePage> {
  MobileProvider _provider = MobileProvider.wallet;
  _DeliveryMode _delivery = _DeliveryMode.auto;
  final TextEditingController _noteCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_paiementBundleProvider(widget.annonceId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              _Header(),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const _Header(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la commande. $e',
                    onRetry: () => ref.invalidate(
                      _paiementBundleProvider(widget.annonceId),
                    ),
                  ),
                ),
              ),
            ],
          ),
          data: (bundle) => _build(bundle),
        ),
      ),
    );
  }

  Widget _build(_PaiementBundle bundle) {
    final annonce = bundle.annonce;
    final dispo = annonce.quantiteKg.round();
    final qteMin = (annonce.quantiteMinKg ?? 1).round().clamp(1, dispo);
    final qte = (widget.quantiteKgInitiale ?? qteMin).clamp(qteMin, dispo);
    final prix = annonce.prixParKg.round();
    final sousTotal = qte * prix;
    final frais = (sousTotal * 0.015).round();
    final total = sousTotal + frais;

    final soldeWallet = bundle.wallet?.wallet.balance ?? 0.0;
    final walletInsuffisant =
        _provider == MobileProvider.wallet && soldeWallet < total;

    return Column(
      children: [
        const _Header(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            children: [
              _RecapCard(annonce: annonce, quantiteKg: qte),
              const SizedBox(height: 18),
              const _SectionTitle('Mode de livraison'),
              const SizedBox(height: 10),
              _DeliveryOptions(
                selected: _delivery,
                onChange: (mode) {
                  setState(() => _delivery = mode);
                  if (mode == _DeliveryMode.choisir) {
                    context.push(
                      RouteNames.acheteurChoisirTransporteurPath,
                    );
                  }
                },
              ),
              const SizedBox(height: 18),
              const _SectionTitle('Montants'),
              const SizedBox(height: 10),
              _AmountsCard(
                sousTotal: sousTotal,
                frais: frais,
                total: total,
              ),
              const SizedBox(height: 18),
              const _SectionTitle('Méthode de paiement'),
              const SizedBox(height: 10),
              _MethodsGrid(
                selected: _provider,
                soldeWallet: soldeWallet,
                onSelect: (p) => setState(() => _provider = p),
              ),
              if (walletInsuffisant) ...[
                const SizedBox(height: 8),
                _WalletLowBanner(
                  manquant: (total - soldeWallet).round(),
                  onRecharger: () =>
                      context.push(RouteNames.acheteurWalletRechargerPath),
                ),
              ],
              const SizedBox(height: 18),
              const _SectionTitle('Adresse de livraison'),
              const SizedBox(height: 10),
              _AddressCard(
                onEdit: () => context
                    .push(RouteNames.acheteurAdressesLivraisonPath),
              ),
              const SizedBox(height: 18),
              const _SectionTitle('Note pour le vendeur (optionnel)'),
              const SizedBox(height: 10),
              _NoteField(controller: _noteCtrl),
            ],
          ),
        ),
        _StickyBottom(
          total: total,
          busy: _busy,
          enabled: !walletInsuffisant,
          onPay: () => _payer(annonce, qte),
        ),
      ],
    );
  }

  Future<void> _payer(AnnonceVente annonce, int qte) async {
    if (_busy) return;
    setState(() => _busy = true);
    final idempotencyKey = _generateIdempotencyKey();
    try {
      final commande = await ref
          .read(ordersServiceProvider)
          .createOrder(
        annonceId: annonce.id,
        quantiteKg: qte.toDouble(),
        paymentProvider: _provider,
        idempotencyKey: idempotencyKey,
      );
      // Rafraîchit le wallet (le débit immédiat éventuel).
      ref.invalidate(_paiementBundleProvider(widget.annonceId));
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        'Commande créée · escrow activé',
      );
      context.go(RouteNames.acheteurCommandeSuccesPathFor(commande.id));
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// UUID v4 simplifié à partir de Random.secure() + timestamp. Suffisant
  /// pour l'idempotency key (côté backend : header `Idempotency-Key`).
  String _generateIdempotencyKey() {
    final rnd = Random.secure();
    String chunk(int n) {
      final buf = StringBuffer();
      for (var i = 0; i < n; i++) {
        buf.write(rnd.nextInt(16).toRadixString(16));
      }
      return buf.toString();
    }

    return '${chunk(8)}-${chunk(4)}-4${chunk(3)}-'
        '${(8 + rnd.nextInt(4)).toRadixString(16)}${chunk(3)}-${chunk(12)}';
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
              'Paiement commande',
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

// ─── Recap card ────────────────────────────────────────────────────────

class _RecapCard extends StatelessWidget {
  const _RecapCard({required this.annonce, required this.quantiteKg});
  final AnnonceVente annonce;
  final int quantiteKg;

  @override
  Widget build(BuildContext context) {
    final photo =
        annonce.photos.isNotEmpty ? annonce.photos.first : null;
    final nom = annonce.produitLabel;
    final vendeur = annonce.vendeurNom ?? 'Vendeur';
    final loc = annonce.localisationLabel;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: double.infinity,
              height: 110,
              child: photo != null
                  ? CachedNetworkImage(
                      imageUrl: photo,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          Container(color: AppColors.surfaceSoft),
                      errorWidget: (_, _, _) =>
                          Container(color: AppColors.surfaceSoft),
                    )
                  : Container(
                      color: AppColors.surfaceSoft,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_outlined,
                        size: 36,
                        color: AppColors.textSubtle,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${_nf.format(quantiteKg)} kg · $nom',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${_nf.format(annonce.prixParKg.round())} F/kg · $vendeur',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          if (loc != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 12,
                  color: AppColors.textSubtle,
                ),
                const SizedBox(width: 4),
                Text(
                  loc,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSubtle,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Section title ────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 4),
      child: Text(
        text,
        style: AppTextStyles.titleSmall.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
    );
  }
}

// ─── Delivery options ─────────────────────────────────────────────────

class _DeliveryOptions extends StatelessWidget {
  const _DeliveryOptions({required this.selected, required this.onChange});
  final _DeliveryMode selected;
  final ValueChanged<_DeliveryMode> onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DOption(
          isSelected: selected == _DeliveryMode.auto,
          title: 'Trouvé automatiquement par FarmCash',
          badge: 'Recommandé',
          subtitle:
              'Prix fixe · ETA 1-2j · Le 1er transporteur dispo prend',
          onTap: () => onChange(_DeliveryMode.auto),
        ),
        const SizedBox(height: 8),
        _DOption(
          isSelected: selected == _DeliveryMode.choisir,
          title: 'Choisir mon transporteur',
          badge: null,
          subtitle: 'Compare les transporteurs dispos dans ta zone',
          onTap: () => onChange(_DeliveryMode.choisir),
        ),
      ],
    );
  }
}

class _DOption extends StatelessWidget {
  const _DOption({
    required this.isSelected,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });
  final bool isSelected;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? _kPrimarySoft : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderStrong,
            width: isSelected ? 1.5 : AppDimens.borderThin,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected ? AppColors.primary : AppColors.borderStrong,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
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
                        title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge!,
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Amounts card ─────────────────────────────────────────────────────

class _AmountsCard extends StatelessWidget {
  const _AmountsCard({
    required this.sousTotal,
    required this.frais,
    required this.total,
  });
  final int sousTotal;
  final int frais;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Column(
        children: [
          _amRow('Sous-total', '${_nf.format(sousTotal)} F'),
          _amRow('Frais service (1,5 %)', '${_nf.format(frais)} F'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Total à payer',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  '${_nf.format(total)} F',
                  style: AppTextStyles.displayLarge.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _amRow(String l, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            v,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Methods grid ─────────────────────────────────────────────────────

class _MethodsGrid extends StatelessWidget {
  const _MethodsGrid({
    required this.selected,
    required this.soldeWallet,
    required this.onSelect,
  });
  final MobileProvider selected;
  final double soldeWallet;
  final ValueChanged<MobileProvider> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 100,
      ),
      itemCount: _kChoices.length,
      itemBuilder: (context, i) {
        final spec = _kChoices[i];
        final active = spec.provider == selected;
        final String? subtitle = spec.provider == MobileProvider.wallet
            ? '${_nf.format(soldeWallet.round())} F dispo'
            : null;
        return InkWell(
          onTap: () => onSelect(spec.provider),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: active ? _kPrimarySoft : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? AppColors.primary : AppColors.border,
                width: active ? 1.5 : AppDimens.borderThin,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: spec.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    spec.short,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: spec.dark ? Colors.black : Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  spec.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      color: spec.provider == MobileProvider.wallet
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: spec.provider == MobileProvider.wallet
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WalletLowBanner extends StatelessWidget {
  const _WalletLowBanner({required this.manquant, required this.onRecharger});
  final int manquant;
  final VoidCallback onRecharger;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFFFE082),
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: Color(0xFFB45309)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Solde insuffisant. Recharge ${_nf.format(manquant)} F pour payer avec le wallet.',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onRecharger,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                'Recharger',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Adresse ────────────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.onEdit});
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.location_on_outlined,
              size: 18,
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
                  'Adresse par défaut',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Modifie depuis ton profil',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 4,
              ),
              child: Text(
                'Modifier',
                style: AppTextStyles.link.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Note vendeur ──────────────────────────────────────────────────────

class _NoteField extends StatelessWidget {
  const _NoteField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 3,
      minLines: 3,
      style: AppTextStyles.bodyMedium.copyWith(
        fontSize: 13,
        color: AppColors.text,
      ),
      decoration: InputDecoration(
        hintText: 'Ex : livrer après 14h, contacter à l\'arrivée...',
        hintStyle: AppTextStyles.bodySmall.copyWith(
          fontSize: 13,
          color: AppColors.textSubtle,
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Sticky bottom ─────────────────────────────────────────────────────

class _StickyBottom extends StatelessWidget {
  const _StickyBottom({
    required this.total,
    required this.busy,
    required this.enabled,
    required this.onPay,
  });

  final int total;
  final bool busy;
  final bool enabled;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final actif = enabled && !busy;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: actif ? onPay : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: actif ? AppColors.primary : AppColors.borderStrong,
              borderRadius: BorderRadius.circular(12),
            ),
            child: busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    enabled
                        ? 'Payer ${_nf.format(total)} F · escrow sécurisé'
                        : 'Solde wallet insuffisant',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 14,
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────

final _nf = NumberFormat('#,##0', 'fr_FR');
