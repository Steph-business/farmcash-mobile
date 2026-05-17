import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/snackbars.dart';

// ─── Couleurs accent ─────────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kOrangeSoft = Color(0xFFFFF3E0);
const Color _kOrange = Color(0xFFE65100);

enum _ChipStatus { agregeable, delaiCourt, minFournisseurs }

enum _PrevStatus { confirmee, plantation }

/// Une ligne farmer dans le détail d'une prévision. Membres en **FULL**
/// (règle 3b chantier — visibilité interne coop).
class _MockFarmerLine {
  final String avatar;
  final String nom;
  final int qtyKg;
  final String dateLivraison;
  final _PrevStatus status;

  const _MockFarmerLine({
    required this.avatar,
    required this.nom,
    required this.qtyKg,
    required this.dateLivraison,
    required this.status,
  });
}

/// Une carte de prévision groupée par produit.
class _MockGroupCard {
  final String produit;
  final IconData icon;
  final int nbPrev;
  final int cumulKg;
  final String fenetreLivraison;
  final _ChipStatus chipStatus;
  final List<_MockFarmerLine> details; // vide si non-expanded

  const _MockGroupCard({
    required this.produit,
    required this.icon,
    required this.nbPrev,
    required this.cumulKg,
    required this.fenetreLivraison,
    required this.chipStatus,
    this.details = const [],
  });
}

const List<_MockGroupCard> _kMockGroups = [
  // MANIOC (expanded with detail)
  _MockGroupCard(
    produit: 'Manioc',
    icon: Icons.eco_outlined,
    nbPrev: 5,
    cumulKg: 2800,
    fenetreLivraison: '10-22 juin',
    chipStatus: _ChipStatus.agregeable,
    details: [
      _MockFarmerLine(
        avatar:
            'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=120&h=120&fit=crop&auto=format',
        nom: 'Yao Konan',
        qtyKg: 800,
        dateLivraison: 'Livraison 10 juin',
        status: _PrevStatus.confirmee,
      ),
      _MockFarmerLine(
        avatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120&h=120&fit=crop&auto=format',
        nom: "Aya N'Guessan",
        qtyKg: 700,
        dateLivraison: 'Livraison 14 juin',
        status: _PrevStatus.confirmee,
      ),
      _MockFarmerLine(
        avatar:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120&h=120&fit=crop&auto=format',
        nom: 'Kouadio Bertin',
        qtyKg: 600,
        dateLivraison: 'Livraison 18 juin',
        status: _PrevStatus.plantation,
      ),
      _MockFarmerLine(
        avatar:
            'https://images.unsplash.com/photo-1493612276216-ee3925520721?w=120&h=120&fit=crop&auto=format',
        nom: 'Diabaté Awa',
        qtyKg: 400,
        dateLivraison: 'Livraison 20 juin',
        status: _PrevStatus.plantation,
      ),
      _MockFarmerLine(
        avatar:
            'https://images.unsplash.com/photo-1573497019418-b400bb3ab074?w=120&h=120&fit=crop&auto=format',
        nom: 'Adjoua Brigitte',
        qtyKg: 300,
        dateLivraison: 'Livraison 22 juin',
        status: _PrevStatus.confirmee,
      ),
    ],
  ),
  // MAÏS BLANC
  _MockGroupCard(
    produit: 'Maïs blanc',
    icon: Icons.grain,
    nbPrev: 4,
    cumulKg: 1800,
    fenetreLivraison: '5-15 juillet',
    chipStatus: _ChipStatus.agregeable,
  ),
  // TOMATE
  _MockGroupCard(
    produit: 'Tomate',
    icon: Icons.circle_outlined,
    nbPrev: 2,
    cumulKg: 600,
    fenetreLivraison: '28 mai',
    chipStatus: _ChipStatus.delaiCourt,
  ),
  // BANANE PLANTAIN
  _MockGroupCard(
    produit: 'Banane plantain',
    icon: Icons.spa_outlined,
    nbPrev: 1,
    cumulKg: 1000,
    fenetreLivraison: '20 juin',
    chipStatus: _ChipStatus.minFournisseurs,
  ),
];

/// Tente de récupérer les prévisions du back, sinon retombe sur les
/// groupes mock (l'agrégation par produit n'est pas exposée en V1).
final _previsionsGroupsProvider =
    FutureProvider.autoDispose<List<_MockGroupCard>>((ref) async {
  try {
    await ref.watch(marketplaceServiceProvider).listPrevisions();
    // V1 : on retombe sur les mocks pour le pixel-perfect.
    return _kMockGroups;
  } catch (_) {
    return _kMockGroups;
  }
});

/// Prévisions agrégées par produit des membres de la coopérative.
/// Permet à la coop d'évaluer ce qui est "prêt à agréger" et de pousser
/// vers la publication marché.
class PrevisionsMembresPage extends ConsumerStatefulWidget {
  const PrevisionsMembresPage({super.key});

  @override
  ConsumerState<PrevisionsMembresPage> createState() =>
      _PrevisionsMembresPageState();
}

class _PrevisionsMembresPageState
    extends ConsumerState<PrevisionsMembresPage> {
  String _filtre = 'Tous';

  static const List<String> _filtres = [
    'Tous',
    'Maïs',
    'Manioc',
    'Tomate',
    'Banane plantain',
  ];

  void _onAgreger() {
    Snackbars.showInfo(
      context,
      'Agrégation Manioc → publication marché — à venir',
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_previsionsGroupsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            const _SubHeader(),
            _Filtres(
              filtres: _filtres,
              selected: _filtre,
              onSelected: (f) => setState(() => _filtre = f),
            ),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                error: (_, _) => _Body(
                  groups: _filtered(_kMockGroups, _filtre),
                ),
                data: (groups) => _Body(
                  groups: _filtered(groups, _filtre),
                ),
              ),
            ),
            _Sticky(onTap: _onAgreger),
          ],
        ),
      ),
    );
  }

  static List<_MockGroupCard> _filtered(
    List<_MockGroupCard> all,
    String f,
  ) {
    if (f == 'Tous') return all;
    return all.where((g) => g.produit.toLowerCase().contains(
              f.toLowerCase().split(' ').first,
            )).toList();
  }
}

// ─── Header ──────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space16,
        AppDimens.space8,
        AppDimens.space16,
        AppDimens.space4,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
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
              'Prévisions de mes membres',
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

class _SubHeader extends StatelessWidget {
  const _SubHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '12 prévisions actives · 6.2 tonnes prévues',
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Filtres horizontaux ─────────────────────────────────────────────────

class _Filtres extends StatelessWidget {
  const _Filtres({
    required this.filtres,
    required this.selected,
    required this.onSelected,
  });

  final List<String> filtres;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: SizedBox(
        height: 30,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: filtres.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final f = filtres[i];
            final isActive = selected == f;
            return InkWell(
              onTap: () => onSelected(f),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.border,
                    width: AppDimens.borderThin,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  f,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Body ────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({required this.groups});

  final List<_MockGroupCard> groups;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      children: [
        _SectionTitle(title: 'Prêtes à agréger (par produit)'),
        AppDimens.vGap12,
        for (final g in groups) ...[
          _GroupCard(group: g),
          AppDimens.vGap12,
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    );
  }
}

// ─── Group card ──────────────────────────────────────────────────────────

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});

  final _MockGroupCard group;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top : icône + texte + chevron
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _kPrimarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  group.icon,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      group.produit,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${group.nbPrev} prévisions · ${_fmt(group.cumulKg)} kg cumulé · livraison ${group.fenetreLivraison}',
                      style: AppTextStyles.bodySmall.copyWith(
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
          const SizedBox(height: 12),

          // Stats : Cumulé + Fenêtre
          Row(
            children: [
              Expanded(
                child: _StatCell(
                  label: 'Cumulé',
                  value: '${_fmt(group.cumulKg)} kg',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCell(
                  label: 'Fenêtre',
                  value: group.fenetreLivraison,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: AppColors.border,
          ),
          const SizedBox(height: 12),

          // Footer : chip status + lien "Voir détail"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatusChip(status: group.chipStatus),
              Text(
                'Voir détail',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          // Détail expanded (5 farmers) si présents (cas Manioc dans maquette)
          if (group.details.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: AppColors.border,
            ),
            const SizedBox(height: 12),
            Text(
              'Détail des ${group.details.length} prévisions',
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < group.details.length; i++)
              _FarmerLine(
                line: group.details[i],
                isLast: i == group.details.length - 1,
              ),
          ],
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
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
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final _ChipStatus status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    BoxBorder? border;
    switch (status) {
      case _ChipStatus.agregeable:
        bg = _kPrimarySoft;
        fg = AppColors.primary;
        label = 'Agrégeable';
        border = null;
        break;
      case _ChipStatus.delaiCourt:
        bg = _kOrangeSoft;
        fg = _kOrange;
        label = 'Délai court';
        border = null;
        break;
      case _ChipStatus.minFournisseurs:
        bg = AppColors.surfaceSoft;
        fg = AppColors.textSecondary;
        label = 'Min 2 fournisseurs';
        border = Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        );
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: border,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

// ─── Farmer line (détail expanded) ───────────────────────────────────────

class _FarmerLine extends StatelessWidget {
  const _FarmerLine({required this.line, required this.isLast});

  final _MockFarmerLine line;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
      ),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.hardEdge,
              child: CachedNetworkImage(
                imageUrl: line.avatar,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(color: AppColors.surfaceSoft),
                errorWidget: (_, _, _) =>
                    Container(color: AppColors.surfaceSoft),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  // Membre coop — nom FULL (règle 3b chantier)
                  line.nom,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${line.dateLivraison} · ',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _PrevStatusPill(status: line.status),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${line.qtyKg} kg',
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrevStatusPill extends StatelessWidget {
  const _PrevStatusPill({required this.status});

  final _PrevStatus status;

  @override
  Widget build(BuildContext context) {
    final ok = status == _PrevStatus.confirmee;
    final bg = ok ? _kPrimarySoft : _kOrangeSoft;
    final fg = ok ? AppColors.primary : _kOrange;
    final label = ok ? 'Confirmée 100%' : 'Plantation en cours';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
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

// ─── Sticky bouton ───────────────────────────────────────────────────────

class _Sticky extends StatelessWidget {
  const _Sticky({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 12),
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              border: Border.all(
                color: AppColors.primary,
                width: AppDimens.borderThin,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'Agréger Manioc en publication marché',
              style: AppTextStyles.button.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Helper ──────────────────────────────────────────────────────────────

String _fmt(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
}
