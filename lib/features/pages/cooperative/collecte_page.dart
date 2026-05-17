import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

// ─── Constantes locales ─────────────────────────────────────────────────
const Color _kPrimarySoft = Color(0xFFE8F5E9);
const BorderRadius _kBrCard14 = BorderRadius.all(Radius.circular(14));
const BorderRadius _kBrThumb = BorderRadius.all(Radius.circular(10));

/// Statut d'une livraison farmer.
enum _Statut { enRoute, arrive }

/// Modèle local d'une livraison à peser (mock).
class _LivraisonMock {
  final String id;
  final String produit;
  final String qteEstimee;
  final String farmer;
  final String distance;
  final _Statut statut;
  final String photoUrl;
  const _LivraisonMock({
    required this.id,
    required this.produit,
    required this.qteEstimee,
    required this.farmer,
    required this.distance,
    required this.statut,
    required this.photoUrl,
  });
}

const List<_LivraisonMock> _kLivraisons = [
  _LivraisonMock(
    id: 'liv-001',
    produit: 'Maïs blanc',
    qteEstimee: '~250 kg',
    farmer: 'Yao Konan',
    distance: '2.4 km',
    statut: _Statut.enRoute,
    photoUrl:
        'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716'
        '?w=200&h=200&fit=crop&auto=format',
  ),
  _LivraisonMock(
    id: 'liv-002',
    produit: 'Manioc',
    qteEstimee: '~400 kg',
    farmer: "Aya N'Guessan",
    distance: '3.1 km',
    statut: _Statut.arrive,
    photoUrl:
        'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b'
        '?w=200&h=200&fit=crop&auto=format',
  ),
  _LivraisonMock(
    id: 'liv-003',
    produit: 'Cacao',
    qteEstimee: '~120 kg',
    farmer: 'Kouassi Bamba',
    distance: '5.7 km',
    statut: _Statut.enRoute,
    photoUrl:
        'https://images.unsplash.com/photo-1606937763571-29b3f3f7a85b'
        '?w=200&h=200&fit=crop&auto=format',
  ),
  _LivraisonMock(
    id: 'liv-004',
    produit: 'Maïs jaune',
    qteEstimee: '~300 kg',
    farmer: 'Adjoua Koffi',
    distance: '1.8 km',
    statut: _Statut.arrive,
    photoUrl:
        'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716'
        '?w=200&h=200&fit=crop&auto=format',
  ),
  _LivraisonMock(
    id: 'liv-005',
    produit: 'Manioc',
    qteEstimee: '~550 kg',
    farmer: 'Moussa Diabaté',
    distance: '4.2 km',
    statut: _Statut.enRoute,
    photoUrl:
        'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b'
        '?w=200&h=200&fit=crop&auto=format',
  ),
  _LivraisonMock(
    id: 'liv-006',
    produit: 'Cacao',
    qteEstimee: '~180 kg',
    farmer: 'Awa Touré',
    distance: '6.3 km',
    statut: _Statut.enRoute,
    photoUrl:
        'https://images.unsplash.com/photo-1606937763571-29b3f3f7a85b'
        '?w=200&h=200&fit=crop&auto=format',
  ),
  _LivraisonMock(
    id: 'liv-007',
    produit: 'Maïs blanc',
    qteEstimee: '~220 kg',
    farmer: 'Ibrahim Cissé',
    distance: '2.9 km',
    statut: _Statut.arrive,
    photoUrl:
        'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716'
        '?w=200&h=200&fit=crop&auto=format',
  ),
  _LivraisonMock(
    id: 'liv-008',
    produit: 'Manioc',
    qteEstimee: '~340 kg',
    farmer: 'Fatou Bakayoko',
    distance: '7.1 km',
    statut: _Statut.enRoute,
    photoUrl:
        'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b'
        '?w=200&h=200&fit=crop&auto=format',
  ),
];

/// Page Collecte coopérative — liste des livraisons farmers à peser.
/// Reproduction fidèle de `mockups/cooperative/collecte.html`.
class CollecteCooperativePage extends StatelessWidget {
  const CollecteCooperativePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(count: _kLivraisons.length),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  AppDimens.space8,
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                ),
                itemCount: _kLivraisons.length,
                itemBuilder: (_, i) {
                  final l = _kLivraisons[i];
                  return _CollecteCard(
                    livraison: l,
                    onPeser: () => context.push(
                      RouteNames.cooperativePeseePathFor(l.id),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header (back + titre avec compteur) ────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

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
                : context.go(RouteNames.accueilCooperativePath),
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
              'Collecte du jour · $count produits',
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

// ─── Card d'une livraison ───────────────────────────────────────────────

class _CollecteCard extends StatelessWidget {
  const _CollecteCard({required this.livraison, required this.onPeser});

  final _LivraisonMock livraison;
  final VoidCallback onPeser;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard14,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: _kBrThumb,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
                borderRadius: _kBrThumb,
              ),
              child: CachedNetworkImage(
                imageUrl: livraison.photoUrl,
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
                  livraison.produit,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  livraison.qteEstimee,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      livraison.farmer,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '· ${livraison.distance}',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    _StatutChip(statut: livraison.statut),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // ── Bouton "Peser" ───────────────────────────────────────────
          ElevatedButton(
            onPressed: onPeser,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            child: Text(
              'Peser',
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatutChip extends StatelessWidget {
  const _StatutChip({required this.statut});

  final _Statut statut;

  @override
  Widget build(BuildContext context) {
    final isArrive = statut == _Statut.arrive;
    final bg = isArrive ? _kPrimarySoft : AppColors.background;
    final fg = isArrive ? AppColors.primary : AppColors.textSecondary;
    final border = isArrive ? _kPrimarySoft : AppColors.border;
    final label = isArrive ? 'Arrivé' : 'En route';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: AppDimens.borderThin),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

