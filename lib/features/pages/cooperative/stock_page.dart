import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/header_utilisateur.dart';

// ─── Couleurs locales (alignées sur la maquette) ────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarn = Color(0xFFB45309);
const Color _kSuccess = Color(0xFF66BB6A);

/// Modèle local pour un entrepôt mock.
class _MockEntrepot {
  final String id;
  final String nom;
  final String ville;
  final String usageLabel; // « 8 t / 10 t »
  final double pourcentage; // 0..1
  final Color barColor;

  const _MockEntrepot({
    required this.id,
    required this.nom,
    required this.ville,
    required this.usageLabel,
    required this.pourcentage,
    required this.barColor,
  });
}

/// Modèle local pour un lot récent.
class _MockLot {
  final String produit;
  final String quantiteLabel;
  final String dateEntreeLabel;
  final String photoUrl;

  const _MockLot({
    required this.produit,
    required this.quantiteLabel,
    required this.dateEntreeLabel,
    required this.photoUrl,
  });
}

const List<_MockEntrepot> _kMockEntrepots = [
  _MockEntrepot(
    id: 'ent_treichville',
    nom: 'Entrepôt Abidjan-Treichville',
    ville: 'Treichville',
    usageLabel: '8 t / 10 t',
    pourcentage: 0.80,
    barColor: AppColors.primary,
  ),
  _MockEntrepot(
    id: 'ent_bouake',
    nom: 'Entrepôt Bouaké-Centre',
    ville: 'Bouaké',
    usageLabel: '3.4 t / 4 t',
    pourcentage: 0.85,
    barColor: _kWarn,
  ),
  _MockEntrepot(
    id: 'ent_yamoussoukro',
    nom: 'Entrepôt Yamoussoukro',
    ville: 'Yamoussoukro',
    usageLabel: '0.6 t / 2 t',
    pourcentage: 0.30,
    barColor: _kSuccess,
  ),
];

const List<_MockLot> _kMockLots = [
  _MockLot(
    produit: 'Maïs blanc',
    quantiteLabel: '500 kg',
    dateEntreeLabel: 'Entré le 14 mai · Treichville',
    photoUrl:
        'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716'
        '?w=200&h=200&fit=crop&auto=format',
  ),
  _MockLot(
    produit: 'Manioc',
    quantiteLabel: '1 200 kg',
    dateEntreeLabel: 'Entré le 13 mai · Bouaké',
    photoUrl:
        'https://images.unsplash.com/photo-1574484284002-952d92456975'
        '?w=200&h=200&fit=crop&auto=format',
  ),
  _MockLot(
    produit: 'Tomate',
    quantiteLabel: '80 kg',
    dateEntreeLabel: 'Entré le 12 mai · Yamoussoukro',
    photoUrl:
        'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31'
        '?w=200&h=200&fit=crop&auto=format',
  ),
];

/// Onglet Stock de la coopérative — accessible via le bottom-nav (shell).
///
/// Reproduction fidèle de `mockups/cooperative/stock.html` : header coop,
/// compteur récap, 3 cards entrepôt avec barre de remplissage, et section
/// « Lots récents » avec vignette produit.
///
/// Mock-first : à brancher sur `coopSvc.listEntrepots()` quand prêt.
class StockCooperativePage extends ConsumerWidget {
  const StockCooperativePage({super.key});

  void _ouvrirEntrepot(BuildContext context, _MockEntrepot e) {
    context.push(RouteNames.cooperativeStockEntrepotPathFor(e.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderUtilisateur(variant: HeaderVariant.cooperative),
            const _PageTitle(),
            const _Summary(stockLabel: '12 t stockées', nbEntrepots: 3),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  AppDimens.space8,
                  AppDimens.pagePaddingH,
                  AppDimens.space24,
                ),
                children: [
                  const _SectionTitre(label: 'Entrepôts'),
                  AppDimens.vGap12,
                  for (final e in _kMockEntrepots) ...[
                    _EntrepotCard(
                      entrepot: e,
                      onTap: () => _ouvrirEntrepot(context, e),
                    ),
                    AppDimens.vGap12,
                  ],
                  AppDimens.vGap12,
                  const _SectionTitre(label: 'Lots récents'),
                  AppDimens.vGap12,
                  _LotsCard(lots: _kMockLots),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Titre de page ──────────────────────────────────────────────────────

class _PageTitle extends StatelessWidget {
  const _PageTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space8,
      ),
      child: Text(
        'Stock',
        style: AppTextStyles.displayLarge.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

// ─── Récap ──────────────────────────────────────────────────────────────

class _Summary extends StatelessWidget {
  const _Summary({required this.stockLabel, required this.nbEntrepots});

  final String stockLabel;
  final int nbEntrepots;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
          children: [
            TextSpan(
              text: stockLabel,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            TextSpan(text: ' · $nbEntrepots entrepôts'),
          ],
        ),
      ),
    );
  }
}

// ─── Section titre ──────────────────────────────────────────────────────

class _SectionTitre extends StatelessWidget {
  const _SectionTitre({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ─── Entrepôt card ──────────────────────────────────────────────────────

class _EntrepotCard extends StatelessWidget {
  const _EntrepotCard({required this.entrepot, required this.onTap});

  final _MockEntrepot entrepot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.space16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _kPrimarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.warehouse_outlined,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entrepot.nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entrepot.ville,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ProgressBar(
                      pourcentage: entrepot.pourcentage,
                      color: entrepot.barColor,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entrepot.usageLabel} '
                      '(${(entrepot.pourcentage * 100).round()}%)',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textSubtle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.pourcentage, required this.color});

  final double pourcentage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: pourcentage.clamp(0, 1),
        child: Container(color: color),
      ),
    );
  }
}

// ─── Lots récents ───────────────────────────────────────────────────────

class _LotsCard extends StatelessWidget {
  const _LotsCard({required this.lots});

  final List<_MockLot> lots;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < lots.length; i++) ...[
            _LotRow(lot: lots[i]),
            if (i < lots.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.border,
              ),
          ],
        ],
      ),
    );
  }
}

class _LotRow extends StatelessWidget {
  const _LotRow({required this.lot});

  final _MockLot lot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space16,
        vertical: 14,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: CachedNetworkImage(
              imageUrl: lot.photoUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) =>
                  const ColoredBox(color: AppColors.surfaceSoft),
              errorWidget: (_, _, _) => const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.textSubtle,
                size: 20,
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
                  '${lot.produit} · ${lot.quantiteLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lot.dateEntreeLabel,
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
        ],
      ),
    );
  }
}
