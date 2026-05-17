import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/snackbars.dart';

// ─── Couleurs / radius locaux alignés sur la maquette ─────────────────────
const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarn = Color(0xFFB45309);
const Color _kWarnSoft = Color(0xFFFEF3C7);

const BorderRadius _kBrCard14 = BorderRadius.all(Radius.circular(14));
const BorderRadius _kBrThumb = BorderRadius.all(Radius.circular(10));
const BorderRadius _kBrChip = BorderRadius.all(Radius.circular(10));

// Photos produits (Unsplash, identiques à celles déjà utilisées ailleurs).
const String _kPhotoMais =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716'
    '?w=200&h=200&fit=crop&auto=format';
const String _kPhotoManioc =
    'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b'
    '?w=200&h=200&fit=crop&auto=format';

// ─── Modèles mock ─────────────────────────────────────────────────────────

class _Vehicule {
  final String modele;
  final String plaque;
  final String type;
  final String chauffeur;

  /// Non null → chip vert "En route · …". Null → chip gris "Disponible".
  final String? statutEnRoute;

  const _Vehicule({
    required this.modele,
    required this.plaque,
    required this.type,
    required this.chauffeur,
    this.statutEnRoute,
  });
}

const List<_Vehicule> _kVehicules = [
  _Vehicule(
    modele: 'Toyota Hilux',
    plaque: '2345 AB 01',
    type: 'Pick-up · 1 200 kg',
    chauffeur: 'Chauffeur Issa',
    statutEnRoute: 'En route · Maïs 500 kg → Bouaké',
  ),
  _Vehicule(
    modele: 'Mitsubishi Canter',
    plaque: '9876 CD 01',
    type: 'Camion 8t · 8 000 kg',
    chauffeur: 'Chauffeur Kouadio',
  ),
];

class _Collecte {
  final String photo;
  final String produit;
  final String farmer;
  final String trajet;
  const _Collecte({
    required this.photo,
    required this.produit,
    required this.farmer,
    required this.trajet,
  });
}

const List<_Collecte> _kCollectes = [
  _Collecte(
    photo: _kPhotoMais,
    produit: 'Maïs blanc · 250 kg',
    farmer: 'Yao Konan',
    trajet: 'Yamoussoukro → entrepôt Abidjan',
  ),
  _Collecte(
    photo: _kPhotoManioc,
    produit: 'Manioc · 400 kg',
    farmer: "Aya N'Guessan",
    trajet: 'Sassandra → entrepôt Abidjan',
  ),
];

class _Transfert {
  final String titre;
  final String detail;
  final String? statutOk;
  final bool attente;
  const _Transfert({
    required this.titre,
    required this.detail,
    this.statutOk,
    this.attente = false,
  });
}

const List<_Transfert> _kTransferts = [
  _Transfert(
    titre: 'Maïs 500 kg · Abidjan → Bouaké',
    detail: 'Camion Vert · ETA 2h',
    statutOk: 'En route',
  ),
  _Transfert(
    titre: 'Cacao 300 kg · Daloa → Abidjan',
    detail: 'Transport Express CI · ETA 4h',
    statutOk: 'En route',
  ),
  _Transfert(
    titre: 'Manioc 1 t · Sassandra → Abidjan',
    detail: 'Aucun transporteur affecté',
    attente: true,
  ),
];

/// Onglet Logistique de la coopérative — parc, collectes, transferts,
/// livraisons acheteurs. Reproduction fidèle de
/// `mockups/cooperative/logistique.html`.
class LogistiqueCooperativePage extends StatefulWidget {
  const LogistiqueCooperativePage({super.key});

  @override
  State<LogistiqueCooperativePage> createState() =>
      _LogistiqueCooperativePageState();
}

class _LogistiqueCooperativePageState
    extends State<LogistiqueCooperativePage> {
  int _tabIndex = 0;

  void _info(String message) => Snackbars.showInfo(context, message);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(onAdd: () => _info('Nouvelle mission — à venir')),
            _Tabs(
              index: _tabIndex,
              onChange: (i) => setState(() => _tabIndex = i),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                ),
                children: [
                  // ── KPI row ───────────────────────────────────────────
                  const _KpiRow(),
                  AppDimens.vGap24,

                  // ── Section "Mon parc" ────────────────────────────────
                  _SectionHead(
                    titre: 'Mon parc',
                    actionLabel: '+ Ajouter',
                    onAction: () => context.push(
                      RouteNames.cooperativeVehiculeAjouterPath,
                    ),
                  ),
                  for (final v in _kVehicules)
                    _VehiculeCard(
                      vehicule: v,
                      onTap: () => _info('Détail véhicule — à venir'),
                    ),
                  AppDimens.vGap16,

                  // ── Section "Collectes du jour" ───────────────────────
                  const _SectionHead(titre: 'Collectes du jour'),
                  for (final c in _kCollectes)
                    _CollecteCard(
                      collecte: c,
                      onTap: () => _info('Détail collecte — à venir'),
                    ),
                  AppDimens.vGap16,

                  // ── Section "Transferts entre entrepôts" ──────────────
                  const _SectionHead(titre: 'Transferts entre entrepôts'),
                  for (final t in _kTransferts)
                    _TransfertCard(
                      transfert: t,
                      onTap: () => _info('Détail transfert — à venir'),
                      onTrouver: () => context.push(
                        RouteNames.cooperativeTransportDemandePath,
                      ),
                    ),
                  AppDimens.vGap16,

                  // ── Section "Livraisons acheteurs" ────────────────────
                  const _SectionHead(titre: 'Livraisons acheteurs'),
                  _LivraisonCard(
                    onTap: () => _info('Détail livraison — à venir'),
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

// ─── Header (titre + bouton +) ────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onAdd});

  final VoidCallback onAdd;

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
          Expanded(
            child: Text(
              'Logistique',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.add, size: 24, color: AppColors.text),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tabs ────────────────────────────────────────────────────────────────

class _Tabs extends StatelessWidget {
  const _Tabs({required this.index, required this.onChange});

  final int index;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    const labels = ['En cours (5)', 'Programmées (3)', 'Terminées'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePaddingH),
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
          for (int i = 0; i < labels.length; i++) ...[
            _TabItem(
              label: labels[i],
              active: index == i,
              onTap: () => onChange(i),
            ),
            if (i < labels.length - 1) const SizedBox(width: 18),
          ],
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ─── KPI row ──────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  const _KpiRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _KpiCard(value: '5', label: 'missions actives')),
        SizedBox(width: 8),
        Expanded(child: _KpiCard(value: '2.3 t', label: 'à déplacer')),
        SizedBox(width: 8),
        Expanded(child: _KpiCard(value: '87 000 F', label: 'en transit')),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: AppColors.text,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
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

// ─── Section head ─────────────────────────────────────────────────────────

class _SectionHead extends StatelessWidget {
  const _SectionHead({
    required this.titre,
    this.actionLabel,
    this.onAction,
  });

  final String titre;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titre,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                child: Text(
                  actionLabel!,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 13,
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

// ─── Card de base (parc / transferts / livraisons) ────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    required this.bg,
  });

  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: _kBrChip,
        border: Border.all(color: bg, width: AppDimens.borderThin),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─── Vehicule card ────────────────────────────────────────────────────────

class _VehiculeCard extends StatelessWidget {
  const _VehiculeCard({required this.vehicule, required this.onTap});

  final _Vehicule vehicule;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: _kBrCard14,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: _kBrCard14,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _kPrimarySoft,
                  borderRadius: _kBrThumb,
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
                    Text(
                      '${vehicule.modele} · ${vehicule.plaque}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${vehicule.type} · ${vehicule.chauffeur}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (vehicule.statutEnRoute != null)
                      _Chip(
                        label: vehicule.statutEnRoute!,
                        color: AppColors.primary,
                        bg: _kPrimarySoft,
                      )
                    else
                      _Chip(
                        label: 'Disponible',
                        color: AppColors.textSecondary,
                        bg: AppColors.surfaceSoft,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
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

// ─── Collecte card ────────────────────────────────────────────────────────

class _CollecteCard extends StatelessWidget {
  const _CollecteCard({required this.collecte, required this.onTap});

  final _Collecte collecte;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: _kBrCard14,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: _kBrCard14,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _kPrimarySoft,
                  borderRadius: _kBrThumb,
                  border: Border.all(
                    color: AppColors.border,
                    width: AppDimens.borderThin,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: collecte.photo,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      const ColoredBox(color: _kPrimarySoft),
                  errorWidget: (_, __, ___) =>
                      const ColoredBox(color: _kPrimarySoft),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      collecte.produit,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${collecte.farmer} · ${collecte.trajet}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const _Chip(
                      label: 'Transporteur affecté',
                      color: AppColors.primary,
                      bg: _kPrimarySoft,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
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

// ─── Transfert card ───────────────────────────────────────────────────────

class _TransfertCard extends StatelessWidget {
  const _TransfertCard({
    required this.transfert,
    required this.onTap,
    required this.onTrouver,
  });

  final _Transfert transfert;
  final VoidCallback onTap;
  final VoidCallback onTrouver;

  @override
  Widget build(BuildContext context) {
    final attente = transfert.attente;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: attente ? null : onTap,
        borderRadius: _kBrCard14,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: _kBrCard14,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _kPrimarySoft,
                  borderRadius: _kBrThumb,
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
                    Text(
                      transfert.titre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      transfert.detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (attente)
                      const _Chip(
                        label: 'Attente transporteur',
                        color: _kWarn,
                        bg: _kWarnSoft,
                      )
                    else
                      _Chip(
                        label: transfert.statutOk ?? 'En route',
                        color: AppColors.primary,
                        bg: _kPrimarySoft,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              if (attente)
                _FindButton(onTap: onTrouver)
              else
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

class _FindButton extends StatelessWidget {
  const _FindButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: _kBrChip,
      child: InkWell(
        onTap: onTap,
        borderRadius: _kBrChip,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: _kBrChip,
            border: Border.all(
              color: AppColors.primary,
              width: AppDimens.borderThin,
            ),
          ),
          child: Text(
            'Trouver',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Livraison acheteur card ──────────────────────────────────────────────

class _LivraisonCard extends StatelessWidget {
  const _LivraisonCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: _kBrCard14,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: _kBrCard14,
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _kPrimarySoft,
                borderRadius: _kBrThumb,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.inventory_2_outlined,
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
                    'Lot LOT-2026-0140',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Restaurant Le B. · Abidjan',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const _Chip(
                    label: 'Livré · 15 mai',
                    color: AppColors.primary,
                    bg: _kPrimarySoft,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}


