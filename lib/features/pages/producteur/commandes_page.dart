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
const Color _kWarnSoft = Color(0xFFFFF8E1);
const Color _kWarn = Color(0xFFB26A00);

/// Type sémantique de chip statut commande producteur.
enum _ChipKind { warn, green }

/// Action contextuelle sur une commande.
enum _OrderAction { preparer, livrer, voir }

/// Onglet en haut de la page Commandes producteur.
enum _OrderTab { enCours, livrees, annulees }

/// Modèle local pour une commande mock — calqué sur la maquette HTML.
class _MockOrder {
  final String id;
  final String photoUrl;
  final String clientNom;
  final String info;
  final String chipLabel;
  final _ChipKind chipKind;
  final _OrderAction action;
  final _OrderTab tab;

  const _MockOrder({
    required this.id,
    required this.photoUrl,
    required this.clientNom,
    required this.info,
    required this.chipLabel,
    required this.chipKind,
    required this.action,
    required this.tab,
  });
}

/// Liste mock alignée 1:1 sur `mockups/producteur/commandes.html`
/// (4 commandes en cours).
const List<_MockOrder> _kMockOrders = [
  _MockOrder(
    id: 'cmd_baoule_mais',
    photoUrl:
        'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716'
        '?w=300&h=300&fit=crop&auto=format',
    clientNom: 'Restaurant Le Baoulé',
    info: '500 kg maïs blanc · 175 000 F',
    chipLabel: 'À préparer',
    chipKind: _ChipKind.warn,
    action: _OrderAction.preparer,
    tab: _OrderTab.enCours,
  ),
  _MockOrder(
    id: 'cmd_marie_tomate',
    photoUrl:
        'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31'
        '?w=300&h=300&fit=crop&auto=format',
    clientNom: 'Marie Yao',
    info: '80 kg tomate · 96 000 F',
    chipLabel: 'En transit',
    chipKind: _ChipKind.green,
    action: _OrderAction.voir,
    tab: _OrderTab.enCours,
  ),
  _MockOrder(
    id: 'cmd_industries_manioc',
    photoUrl:
        'https://images.unsplash.com/photo-1574484284002-952d92456975'
        '?w=300&h=300&fit=crop&auto=format',
    clientNom: 'Industries Agricoles SA',
    info: '1 t manioc · 350 000 F',
    chipLabel: 'Paiement reçu',
    chipKind: _ChipKind.green,
    action: _OrderAction.voir,
    tab: _OrderTab.enCours,
  ),
  _MockOrder(
    id: 'cmd_beaurivage_banane',
    photoUrl:
        'https://images.unsplash.com/photo-1488459716781-31db52582fe9'
        '?w=300&h=300&fit=crop&auto=format',
    clientNom: 'Hôtel Beau Rivage',
    info: '200 kg banane · 140 000 F',
    chipLabel: 'À livrer',
    chipKind: _ChipKind.warn,
    action: _OrderAction.livrer,
    tab: _OrderTab.enCours,
  ),
];

/// Onglet Commandes du producteur — accessible via le bottom-nav (shell).
///
/// Reproduction fidèle de `mockups/producteur/commandes.html` : header
/// producteur + titre, compteur récapitulatif, tab bar « En cours »/
/// « Livrées »/« Annulées », liste de cards commande avec photo, chip
/// statut, bouton d'action contextuel.
///
/// Mock-first : aucun endpoint dédié pour V1.
class CommandesProducteurPage extends ConsumerStatefulWidget {
  const CommandesProducteurPage({super.key});

  @override
  ConsumerState<CommandesProducteurPage> createState() =>
      _CommandesProducteurPageState();
}

class _CommandesProducteurPageState
    extends ConsumerState<CommandesProducteurPage> {
  _OrderTab _tab = _OrderTab.enCours;

  List<_MockOrder> get _filtered =>
      _kMockOrders.where((o) => o.tab == _tab).toList(growable: false);

  int get _countEnCours =>
      _kMockOrders.where((o) => o.tab == _OrderTab.enCours).length;

  void _ouvrirCommande(_MockOrder o) {
    context.push(RouteNames.producteurCommandeDetailPathFor(o.id));
  }

  void _agir(_MockOrder o) {
    // L'action contextuelle ouvre simplement le détail pour V1 — le
    // détail prend la suite (préparation, validation livraison…).
    _ouvrirCommande(o);
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderUtilisateur(variant: HeaderVariant.producteur),
            const _PageTitle(),
            const _Summary(
              enCours: 4,
              livreesCeMois: 2,
            ),
            _TabBar(
              current: _tab,
              enCoursCount: _countEnCours,
              onSelect: (t) => setState(() => _tab = t),
            ),
            Expanded(
              child: orders.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.pagePaddingH,
                        AppDimens.space12,
                        AppDimens.pagePaddingH,
                        AppDimens.space16,
                      ),
                      itemCount: orders.length,
                      itemBuilder: (_, i) => _OrderCard(
                        order: orders[i],
                        onTap: () => _ouvrirCommande(orders[i]),
                        onAction: () => _agir(orders[i]),
                      ),
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
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Commandes',
              style: AppTextStyles.displayLarge.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.2,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Récap ──────────────────────────────────────────────────────────────

class _Summary extends StatelessWidget {
  const _Summary({required this.enCours, required this.livreesCeMois});

  final int enCours;
  final int livreesCeMois;

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
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          children: [
            TextSpan(
              text: '$enCours commandes en cours',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const TextSpan(text: ' · '),
            TextSpan(text: '$livreesCeMois livrées ce mois'),
          ],
        ),
      ),
    );
  }
}

// ─── Tab bar « En cours / Livrées / Annulées » ──────────────────────────

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.current,
    required this.enCoursCount,
    required this.onSelect,
  });

  final _OrderTab current;
  final int enCoursCount;
  final ValueChanged<_OrderTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.pagePaddingH),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          _tab(_OrderTab.enCours, 'En cours ($enCoursCount)'),
          _tab(_OrderTab.livrees, 'Livrées'),
          _tab(_OrderTab.annulees, 'Annulées'),
        ],
      ),
    );
  }

  Widget _tab(_OrderTab value, String label) {
    final active = value == current;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Order card ─────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.onTap,
    required this.onAction,
  });

  final _MockOrder order;
  final VoidCallback onTap;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Photo
              Container(
                width: 64,
                height: 64,
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
                  imageUrl: order.photoUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      const ColoredBox(color: AppColors.surfaceSoft),
                  errorWidget: (_, _, _) => const Icon(
                    Icons.image_outlined,
                    color: AppColors.textSubtle,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Body
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      order.clientNom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.info,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _ChipStatut(
                      label: order.chipLabel,
                      kind: order.chipKind,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Action contextuelle (bouton ou chevron)
              _ActionWidget(action: order.action, onTap: onAction),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipStatut extends StatelessWidget {
  const _ChipStatut({required this.label, required this.kind});

  final String label;
  final _ChipKind kind;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (kind) {
      _ChipKind.warn => (_kWarnSoft, _kWarn),
      _ChipKind.green => (_kPrimarySoft, AppColors.primary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1.2,
        ),
      ),
    );
  }
}

class _ActionWidget extends StatelessWidget {
  const _ActionWidget({required this.action, required this.onTap});

  final _OrderAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    switch (action) {
      case _OrderAction.preparer:
        return _BtnSmallPrimary(label: 'Préparer', onTap: onTap);
      case _OrderAction.livrer:
        return _BtnSmallPrimary(label: 'Marquer livré', onTap: onTap);
      case _OrderAction.voir:
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textSubtle,
            ),
          ),
        );
    }
  }
}

class _BtnSmallPrimary extends StatelessWidget {
  const _BtnSmallPrimary({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary,
            width: AppDimens.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.onPrimary,
          ),
        ),
      ),
    );
  }
}

// ─── État vide ──────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Aucune commande dans cet onglet',
              style: AppTextStyles.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
