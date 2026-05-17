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
const Color _kWarn = Color(0xFFB45309);

/// Tabs en haut de la page Commandes acheteur.
enum _OrderTab { enCours, aNoter, toutes }

/// Type sémantique de chip statut.
enum _ChipKind { warn, green }

/// Action contextuelle sur une commande (boutons additionnels).
enum _OrderAction { none, suivre }

/// Modèle local pour une commande mock — calqué sur la maquette HTML.
///
/// NB anti-contournement : noms producteurs tronqués (« Yao K. », « Aya N. »,
/// « Marie Y. ») — l'acheteur ne doit pas pouvoir contacter le producteur
/// en dehors de la plateforme.
class _MockOrder {
  final String id;
  final String photoUrl;
  final String titre;
  final String montant;
  final String chipLabel;
  final _ChipKind chipKind;
  final String sousTexte;
  final _OrderAction action;
  final _OrderTab tab;

  const _MockOrder({
    required this.id,
    required this.photoUrl,
    required this.titre,
    required this.montant,
    required this.chipLabel,
    required this.chipKind,
    required this.sousTexte,
    required this.action,
    required this.tab,
  });
}

/// Liste mock alignée 1:1 sur `mockups/acheteur/commandes.html`.
const List<_MockOrder> _kMockOrders = [
  _MockOrder(
    id: 'ord_mais_yaok',
    photoUrl:
        'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716'
        '?w=200&h=200&fit=crop&auto=format',
    titre: 'Yao K. · 500 kg Maïs blanc',
    montant: '175 000 F',
    chipLabel: 'En préparation',
    chipKind: _ChipKind.warn,
    sousTexte: 'Livraison prévue le 18 mai',
    action: _OrderAction.none,
    tab: _OrderTab.enCours,
  ),
  _MockOrder(
    id: 'ord_manioc_ayan',
    photoUrl:
        'https://images.unsplash.com/photo-1574484284002-952d92456975'
        '?w=200&h=200&fit=crop&auto=format',
    titre: 'Aya N. · 200 kg Manioc',
    montant: '76 000 F',
    chipLabel: 'En transit',
    chipKind: _ChipKind.green,
    sousTexte: "ETA 14h aujourd'hui",
    action: _OrderAction.suivre,
    tab: _OrderTab.enCours,
  ),
  _MockOrder(
    id: 'ord_tomate_mariey',
    photoUrl:
        'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31'
        '?w=200&h=200&fit=crop&auto=format',
    titre: 'Marie Y. · 60 kg Tomate',
    montant: '72 000 F',
    chipLabel: 'Payée · à expédier',
    chipKind: _ChipKind.green,
    sousTexte: 'Producteur prépare ta commande',
    action: _OrderAction.none,
    tab: _OrderTab.enCours,
  ),
];

/// Onglet Commandes de l'acheteur — accessible via le bottom-nav (shell).
///
/// Reproduction fidèle de `mockups/acheteur/commandes.html` : header
/// acheteur (panier + notif), titre, compteur récap, tab bar
/// « En cours »/« À noter »/« Toutes », liste de cards commande avec
/// photo, montant, chip statut, sous-texte d'état.
///
/// Mock-first : aucun endpoint dédié pour V1.
class CommandesAcheteurPage extends ConsumerStatefulWidget {
  const CommandesAcheteurPage({super.key});

  @override
  ConsumerState<CommandesAcheteurPage> createState() =>
      _CommandesAcheteurPageState();
}

class _CommandesAcheteurPageState
    extends ConsumerState<CommandesAcheteurPage> {
  _OrderTab _tab = _OrderTab.enCours;

  List<_MockOrder> get _filtered =>
      _kMockOrders.where((o) => o.tab == _tab).toList(growable: false);

  int get _countEnCours =>
      _kMockOrders.where((o) => o.tab == _OrderTab.enCours).length;

  void _ouvrirCommande(_MockOrder o) {
    context.push(RouteNames.acheteurCommandeDetailPathFor(o.id));
  }

  void _suivre(_MockOrder o) {
    // Pour V1 on ouvre simplement le détail de la commande (livraison QR
    // est branchée depuis le détail).
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
            const HeaderUtilisateur(
              variant: HeaderVariant.acheteur,
              cartCount: 3,
              unreadNotifications: 1,
            ),
            const _PageTitle(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, AppDimens.space16),
                children: [
                  const _CounterBox(
                    valeur: '3 en cours',
                    sousTexte: '5 livrées ce mois',
                  ),
                  AppDimens.vGap16,
                  _Tabs(
                    current: _tab,
                    enCoursCount: _countEnCours,
                    aNoterCount: 2,
                    onSelect: (t) => setState(() => _tab = t),
                  ),
                  AppDimens.vGap16,
                  if (orders.isEmpty)
                    const _EmptyState()
                  else
                    ...orders.map(
                      (o) => _OrderCard(
                        order: o,
                        onTap: () => _ouvrirCommande(o),
                        onSuivre: () => _suivre(o),
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

// ─── Titre de page ──────────────────────────────────────────────────────

class _PageTitle extends StatelessWidget {
  const _PageTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        AppDimens.space8,
        20,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Mes commandes',
              style: AppTextStyles.headlineSmall.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Counter box ────────────────────────────────────────────────────────

class _CounterBox extends StatelessWidget {
  const _CounterBox({required this.valeur, required this.sousTexte});

  final String valeur;
  final String sousTexte;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            valeur,
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sousTexte,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tabs ───────────────────────────────────────────────────────────────

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.current,
    required this.enCoursCount,
    required this.aNoterCount,
    required this.onSelect,
  });

  final _OrderTab current;
  final int enCoursCount;
  final int aNoterCount;
  final ValueChanged<_OrderTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
          _tab(_OrderTab.aNoter, 'À noter ($aNoterCount)'),
          _tab(_OrderTab.toutes, 'Toutes'),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
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
              fontWeight: FontWeight.w600,
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
    required this.onSuivre,
  });

  final _MockOrder order;
  final VoidCallback onTap;
  final VoidCallback onSuivre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Top : photo + titre/montant + chip ───────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(10),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          order.titre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          order.montant,
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ChipStatut(label: order.chipLabel, kind: order.chipKind),
                ],
              ),
              // ── Separator ────────────────────────────────────────────
              const SizedBox(height: 10),
              const Divider(
                height: 1,
                thickness: AppDimens.borderThin,
                color: AppColors.border,
              ),
              const SizedBox(height: 10),
              // ── Bottom : sous-texte + bouton "Suivre" optionnel ──────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.sousTexte,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (order.action == _OrderAction.suivre) ...[
                    const SizedBox(width: 8),
                    _BtnTrack(onTap: onSuivre),
                  ],
                ],
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bg, width: AppDimens.borderThin),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1.2,
        ),
      ),
    );
  }
}

class _BtnTrack extends StatelessWidget {
  const _BtnTrack({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary,
            width: AppDimens.borderThin,
          ),
        ),
        child: Text(
          'Suivre',
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
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
    return Padding(
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
    );
  }
}
