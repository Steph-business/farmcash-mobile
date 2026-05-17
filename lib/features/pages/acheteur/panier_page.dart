import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/snackbars.dart';

// ─── Couleurs locales ───────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Rôle du vendeur (groupe d'items dans le panier).
enum _VendeurRole { producteur, coop }

/// Modèle local : item du panier (un produit, une quantité).
///
/// NB anti-contournement : nom du producteur tronqué (« Yao K. »).
/// Les coopératives gardent leur nom complet (entité publique).
class _CartItem {
  final String id;
  final String photoUrl;
  final String nom;
  final String quantite; // affiché tel quel ("500 kg")
  final String prixUnitaire; // "350 F/kg"
  final int prixTotalFcfa;

  const _CartItem({
    required this.id,
    required this.photoUrl,
    required this.nom,
    required this.quantite,
    required this.prixUnitaire,
    required this.prixTotalFcfa,
  });
}

class _VendeurGroup {
  final String avatarUrl;
  final String nom;
  final _VendeurRole role;
  final List<_CartItem> items;

  const _VendeurGroup({
    required this.avatarUrl,
    required this.nom,
    required this.role,
    required this.items,
  });
}

/// Mock 1:1 sur `mockups/acheteur/panier.html` — 3 items répartis en 2
/// vendeurs (Yao K. = producteur, COOP-AGRI Lagunes = coop).
const List<_VendeurGroup> _kMockPanier = [
  _VendeurGroup(
    avatarUrl:
        'https://images.unsplash.com/photo-1531123897727-8f129e1688ce'
        '?w=120&h=120&fit=crop&auto=format',
    nom: 'Yao K. · Yopougon',
    role: _VendeurRole.producteur,
    items: [
      _CartItem(
        id: 'cart_mais_yaok',
        photoUrl:
            'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716'
            '?w=200&h=200&fit=crop&auto=format',
        nom: 'Maïs grain blanc · Standard',
        quantite: '500 kg',
        prixUnitaire: '350 F/kg',
        prixTotalFcfa: 175000,
      ),
      _CartItem(
        id: 'cart_tomate_yaok',
        photoUrl:
            'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31'
            '?w=200&h=200&fit=crop&auto=format',
        nom: 'Tomate fraîche · Premium',
        quantite: '60 kg',
        prixUnitaire: '1 200 F/kg',
        prixTotalFcfa: 72000,
      ),
    ],
  ),
  _VendeurGroup(
    avatarUrl:
        'https://images.unsplash.com/photo-1625246333195-78d9c38ad449'
        '?w=120&h=120&fit=crop&auto=format',
    nom: 'COOP-AGRI Lagunes',
    role: _VendeurRole.coop,
    items: [
      _CartItem(
        id: 'cart_manioc_coop',
        photoUrl:
            'https://images.unsplash.com/photo-1574484284002-952d92456975'
            '?w=200&h=200&fit=crop&auto=format',
        nom: 'Manioc amer · Standard',
        quantite: '200 kg',
        prixUnitaire: '380 F/kg',
        prixTotalFcfa: 76000,
      ),
    ],
  ),
];

/// Page Panier de l'acheteur — push hors shell (header back).
///
/// Reproduction fidèle de `mockups/acheteur/panier.html` :
/// - Header back + titre « Mon panier (n) » + lien « Vider » rouge.
/// - Liste groupée par vendeur (avatar + nom + chip rôle).
/// - Cards items avec photo, stepper qty (- / + ), prix total, poubelle.
/// - Section adresse de livraison (modifiable).
/// - Section code promo.
/// - Récapitulatif (sous-total, livraison, frais service, total vert
///   Poppins gros).
/// - Bouton sticky bas « Commander · MONTANT ».
///
/// Mock-first : pas d'endpoint dédié pour V1. Le montant total est calculé
/// dynamiquement à partir des items du panier (utile dès que les steppers
/// modifient les quantités).
class PanierAcheteurPage extends ConsumerStatefulWidget {
  const PanierAcheteurPage({super.key});

  @override
  ConsumerState<PanierAcheteurPage> createState() =>
      _PanierAcheteurPageState();
}

class _PanierAcheteurPageState extends ConsumerState<PanierAcheteurPage> {
  static const int _kLivraisonFcfa = 12500;
  static const double _kFraisServiceTaux = 0.01;
  static const String _kOrderMockId = 'panier_mock';

  // Mocks restent en const, mais on garde la possibilité d'évoluer si
  // l'utilisateur clique sur la poubelle (suppression pour V1 silencieux).
  late List<_VendeurGroup> _groupes;
  final TextEditingController _promoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _groupes = List<_VendeurGroup>.from(_kMockPanier);
  }

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  int get _totalItemsCount =>
      _groupes.fold<int>(0, (acc, g) => acc + g.items.length);

  int get _sousTotalFcfa => _groupes.fold<int>(
        0,
        (acc, g) => acc + g.items.fold<int>(0, (a, i) => a + i.prixTotalFcfa),
      );

  int get _fraisServiceFcfa =>
      (_sousTotalFcfa * _kFraisServiceTaux).round();

  int get _totalFcfa =>
      _sousTotalFcfa + _kLivraisonFcfa + _fraisServiceFcfa;

  void _vider() {
    setState(() => _groupes = const []);
    Snackbars.showInfo(context, 'Panier vidé');
  }

  void _appliquerPromo() {
    final code = _promoCtrl.text.trim();
    if (code.isEmpty) return;
    Snackbars.showInfo(context, 'Code « $code » appliqué (à venir)');
  }

  void _modifierAdresse() {
    Snackbars.showInfo(context, 'Modification adresse — à venir');
  }

  void _commander() {
    if (_groupes.isEmpty) return;
    context.push(RouteNames.acheteurPaiementCommandePathFor(_kOrderMockId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              count: _totalItemsCount,
              onVider: _groupes.isEmpty ? null : _vider,
            ),
            Expanded(
              child: _groupes.isEmpty
                  ? const _EmptyPanier()
                  : Stack(
                      children: [
                        ListView(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                          children: [
                            ..._groupes.map((g) => _SellerGroup(group: g)),
                            const _SectionTitle(label: 'Adresse de livraison'),
                            _AddrCard(onModifier: _modifierAdresse),
                            const _SectionTitle(label: 'Code promo'),
                            _Coupon(
                              controller: _promoCtrl,
                              onAppliquer: _appliquerPromo,
                            ),
                            const _SectionTitle(label: 'Récapitulatif'),
                            _Recap(
                              sousTotal: _sousTotalFcfa,
                              livraison: _kLivraisonFcfa,
                              fraisService: _fraisServiceFcfa,
                              total: _totalFcfa,
                            ),
                          ],
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: _StickyBottom(
                            total: _totalFcfa,
                            onCommander: _commander,
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

// ─── Header (back + titre + Vider) ──────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.count, required this.onVider});

  final int count;
  final VoidCallback? onVider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RouteNames.accueilAcheteurPath);
              }
            },
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
              'Mon panier ($count)',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
            onTap: onVider,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                'Vider',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: onVider == null
                      ? AppColors.textSubtle
                      : AppColors.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Groupe vendeur ─────────────────────────────────────────────────────

class _SellerGroup extends StatelessWidget {
  const _SellerGroup({required this.group});

  final _VendeurGroup group;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _kPrimarySoft,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.border,
                      width: AppDimens.borderThin,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: group.avatarUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        const ColoredBox(color: _kPrimarySoft),
                    errorWidget: (_, _, _) => const Icon(
                      Icons.person_outline,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    group.nom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ),
                _ChipRole(role: group.role),
              ],
            ),
          ),
          ...group.items.map((it) => _ItemCard(item: it)),
        ],
      ),
    );
  }
}

class _ChipRole extends StatelessWidget {
  const _ChipRole({required this.role});

  final _VendeurRole role;

  @override
  Widget build(BuildContext context) {
    final label = switch (role) {
      _VendeurRole.producteur => 'Farmer',
      _VendeurRole.coop => 'Coop',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── Item card (photo + body + trash) ───────────────────────────────────

class _ItemCard extends StatefulWidget {
  const _ItemCard({required this.item});

  final _CartItem item;

  @override
  State<_ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<_ItemCard> {
  late String _qty = widget.item.quantite;

  void _supprimer() {
    Snackbars.showInfo(context, '${widget.item.nom} retiré du panier');
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 72,
              height: 72,
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
                imageUrl: item.photoUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    const ColoredBox(color: AppColors.surfaceSoft),
                errorWidget: (_, _, _) => const Icon(
                  Icons.image_outlined,
                  size: 28,
                  color: AppColors.textSubtle,
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
                    item.nom,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item.quantite} · ${item.prixUnitaire}',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Stepper(value: _qty, onChanged: (v) {
                        setState(() => _qty = v);
                      }),
                      const Spacer(),
                      Text(
                        _formatFcfa(item.prixTotalFcfa),
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: _supprimer,
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    // V1 : stepper visuel (les steppers en mocks n'altèrent pas les totaux).
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.borderStrong,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepBtn(context, '−', () => onChanged(value)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              value,
              style: AppTextStyles.headlineSmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
          _stepBtn(context, '+', () => onChanged(value)),
        ],
      ),
    );
  }

  Widget _stepBtn(BuildContext context, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 28,
        height: 28,
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section title ──────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ─── Adresse ────────────────────────────────────────────────────────────

class _AddrCard extends StatelessWidget {
  const _AddrCard({required this.onModifier});

  final VoidCallback onModifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.location_on_outlined,
              size: 16,
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
                  'Restaurant Le Baoulé',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '22 Avenue Saint-Pierre · Cocody · Abidjan',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onModifier,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                'Modifier',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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

// ─── Coupon ─────────────────────────────────────────────────────────────

class _Coupon extends StatelessWidget {
  const _Coupon({required this.controller, required this.onAppliquer});

  final TextEditingController controller;
  final VoidCallback onAppliquer;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.borderStrong,
                width: AppDimens.borderThin,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: controller,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.text,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: InputBorder.none,
                hintText: 'Saisir un code',
                hintStyle: AppTextStyles.hint.copyWith(
                  fontSize: 13,
                  color: AppColors.textSubtle,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: onAppliquer,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primary,
                width: AppDimens.borderThin,
              ),
            ),
            child: Text(
              'Appliquer',
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Récapitulatif ──────────────────────────────────────────────────────

class _Recap extends StatelessWidget {
  const _Recap({
    required this.sousTotal,
    required this.livraison,
    required this.fraisService,
    required this.total,
  });

  final int sousTotal;
  final int livraison;
  final int fraisService;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _row('Sous-total', _formatFcfa(sousTotal), divider: true),
          _row(
            'Livraison (estimée)',
            _formatFcfa(livraison),
            divider: true,
          ),
          _row(
            'Frais service (1%)',
            _formatFcfa(fraisService),
            divider: true,
          ),
          _row('Total', _formatFcfa(total), isTotal: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value,
      {bool divider = false, bool isTotal = false}) {
    final labelStyle = isTotal
        ? AppTextStyles.bodyMedium.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          )
        : AppTextStyles.bodySmall.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary,
          );
    final valueStyle = isTotal
        ? AppTextStyles.headlineMedium.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          )
        : AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          );
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: divider ? AppColors.border : Colors.transparent,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          const SizedBox(width: 12),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}

// ─── Sticky bottom ──────────────────────────────────────────────────────

class _StickyBottom extends StatelessWidget {
  const _StickyBottom({required this.total, required this.onCommander});

  final int total;
  final VoidCallback onCommander;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: InkWell(
        onTap: onCommander,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: AppDimens.buttonHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary,
              width: AppDimens.borderThin,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Commander · ',
                style: AppTextStyles.button.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onPrimary,
                ),
              ),
              Text(
                _formatFcfa(total),
                style: AppTextStyles.headlineSmall.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty state ────────────────────────────────────────────────────────

class _EmptyPanier extends StatelessWidget {
  const _EmptyPanier();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 40,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Votre panier est vide',
              style: AppTextStyles.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────

/// Formate un montant en F CFA avec espaces insécables comme séparateurs
/// de milliers — visuel identique à la maquette ("175 000 F").
String _formatFcfa(int value) {
  final s = value.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return '${buf.toString()} F';
}
