import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

// ─── Couleurs / radius locaux alignés sur la maquette ──────────────────
const Color _kPrimarySoft = Color(0xFFE8F5E9);
const BorderRadius _kBrCard14 = BorderRadius.all(Radius.circular(14));
const BorderRadius _kBrCard12 = BorderRadius.all(Radius.circular(12));
const BorderRadius _kBrThumb = BorderRadius.all(Radius.circular(8));

/// Modèle local d'un lot stocké (mock) — calqué sur la maquette HTML.
class _LotMock {
  final String produit;
  final String farmer;
  final String date;
  final String qualite;
  final String photoUrl;
  const _LotMock({
    required this.produit,
    required this.farmer,
    required this.date,
    required this.qualite,
    required this.photoUrl,
  });
}

const List<_LotMock> _kLots = [
  _LotMock(
    produit: 'Maïs blanc · 500 kg',
    farmer: 'Yao Konan',
    date: '14 mai',
    qualite: 'A',
    photoUrl:
        'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716'
        '?w=200&h=200&fit=crop&auto=format',
  ),
  _LotMock(
    produit: 'Manioc · 800 kg',
    farmer: "Aya N'Guessan",
    date: '13 mai',
    qualite: 'A',
    photoUrl:
        'https://images.unsplash.com/photo-1574484284002-952d92456975'
        '?w=200&h=200&fit=crop&auto=format',
  ),
  _LotMock(
    produit: 'Cacao · 350 kg',
    farmer: 'Kouassi Bamba',
    date: '12 mai',
    qualite: 'B',
    photoUrl:
        'https://images.unsplash.com/photo-1488459716781-31db52582fe9'
        '?w=200&h=200&fit=crop&auto=format',
  ),
  _LotMock(
    produit: 'Maïs jaune · 1 200 kg',
    farmer: 'Adjoua Koffi',
    date: '11 mai',
    qualite: 'A',
    photoUrl:
        'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716'
        '?w=200&h=200&fit=crop&auto=format',
  ),
  _LotMock(
    produit: 'Manioc · 600 kg',
    farmer: 'Moussa Diabaté',
    date: '10 mai',
    qualite: 'A',
    photoUrl:
        'https://images.unsplash.com/photo-1574484284002-952d92456975'
        '?w=200&h=200&fit=crop&auto=format',
  ),
  _LotMock(
    produit: 'Cacao · 2 550 kg',
    farmer: 'Awa Touré',
    date: '9 mai',
    qualite: 'B',
    photoUrl:
        'https://images.unsplash.com/photo-1488459716781-31db52582fe9'
        '?w=200&h=200&fit=crop&auto=format',
  ),
];

/// Détail d'un entrepôt coopérative — capacité, lots stockés, action
/// "Réceptionner un nouveau lot". Reproduction fidèle de
/// `mockups/cooperative/stock_entrepot.html`.
class StockEntrepotPage extends StatelessWidget {
  const StockEntrepotPage({super.key, required this.entrepotId});

  final String entrepotId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  0,
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                ),
                children: [
                  // ── Hero photo ──────────────────────────────────────
                  ClipRRect(
                    borderRadius: _kBrCard12,
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.border,
                          width: AppDimens.borderThin,
                        ),
                        borderRadius: _kBrCard12,
                      ),
                      child: const _HeroImage(
                        url:
                            'https://images.unsplash.com/photo-1488459716781-31db52582fe9'
                            '?w=600&h=300&fit=crop&auto=format',
                      ),
                    ),
                  ),
                  AppDimens.vGap8,
                  // ── KPI row ─────────────────────────────────────────
                  const Padding(
                    padding: EdgeInsets.only(top: 12, bottom: 8),
                    child: _KpiRow(),
                  ),
                  AppDimens.vGap12,
                  // ── Section "Lots dans cet entrepôt" ────────────────
                  Text(
                    'Lots dans cet entrepôt',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppDimens.vGap12,
                  _LotsList(lots: _kLots),
                ],
              ),
            ),
            // ── Sticky bouton "Réceptionner un nouveau lot" ───────────
            _StickyButton(
              onTap: () =>
                  context.push(RouteNames.cooperativeStockReceptionPath),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header (back + titre) ──────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.canPop()
                ? context.pop()
                : context.go(RouteNames.cooperativeStockPath),
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
              'Entrepôt Abidjan-Treichville',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _NotifsButton(
            onTap: () =>
                context.push(RouteNames.cooperativeNotificationsPath),
          ),
        ],
      ),
    );
  }
}

class _NotifsButton extends StatelessWidget {
  const _NotifsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          children: [
            const Center(
              child: Icon(
                Icons.notifications_none,
                size: 22,
                color: AppColors.text,
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.background,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '5',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero photo ─────────────────────────────────────────────────────────

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => const ColoredBox(color: _kPrimarySoft),
      errorWidget: (_, __, ___) => const ColoredBox(color: _kPrimarySoft),
    );
  }
}

// ─── KPI row ────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  const _KpiRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _KpiCard(value: '10 t', label: 'Capacité')),
        SizedBox(width: 8),
        Expanded(child: _KpiCard(value: '6 t', label: 'Utilisée')),
        SizedBox(width: 8),
        Expanded(child: _KpiCard(value: '40%', label: 'Dispo')),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard12,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              height: 1.1,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Liste des lots ─────────────────────────────────────────────────────

class _LotsList extends StatelessWidget {
  const _LotsList({required this.lots});

  final List<_LotMock> lots;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard14,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < lots.length; i++) ...[
            _LotTile(lot: lots[i]),
            if (i != lots.length - 1)
              const Divider(
                height: 1,
                thickness: AppDimens.borderThin,
                color: AppColors.border,
              ),
          ],
        ],
      ),
    );
  }
}

class _LotTile extends StatelessWidget {
  const _LotTile({required this.lot});

  final _LotMock lot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: _kBrThumb,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
                borderRadius: _kBrThumb,
              ),
              child: CachedNetworkImage(
                imageUrl: lot.photoUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ColoredBox(color: _kPrimarySoft),
                errorWidget: (_, __, ___) =>
                    const ColoredBox(color: _kPrimarySoft),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  lot.produit,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${lot.farmer} · ${lot.date} · Qualité ${lot.qualite}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            lot.qualite,
            style: AppTextStyles.labelMedium.copyWith(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sticky bouton ──────────────────────────────────────────────────────

class _StickyButton extends StatelessWidget {
  const _StickyButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.pagePaddingH,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.add, size: 18, color: AppColors.onPrimary),
          label: Text(
            'Réceptionner un nouveau lot',
            style: AppTextStyles.labelLarge.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onPrimary,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: _kBrCard12,
            ),
          ),
        ),
      ),
    );
  }
}

