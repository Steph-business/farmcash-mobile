import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/snackbars.dart';

// ─── Constantes ───────────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarnSoft = Color(0xFFFFF8E1);
const Color _kErrorSoft = Color(0xFFFEE2E2);
const Color _kWarnText = Color(0xFFB45309);
const Color _kErrorText = Color(0xFFB91C1C);

enum _ResStatus { actif, presqueConverti }

class _MockReservation {
  const _MockReservation({
    required this.id,
    required this.qte,
    required this.produit,
    required this.vendeur,
    required this.photoUrl,
    required this.joursRestants,
    required this.acompte,
    required this.reste,
    required this.status,
  });

  final String id;
  final int qte;
  final String produit;
  final String vendeur;
  final String photoUrl;
  final int joursRestants;
  final int acompte;
  final int reste;
  final _ResStatus status;
}

const List<_MockReservation> _kMockReservations = [
  _MockReservation(
    id: 'res-1',
    qte: 200,
    produit: 'Maïs blanc',
    vendeur: 'Yao K.',
    photoUrl:
        'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=200&h=200&fit=crop&auto=format',
    joursRestants: 12,
    acompte: 7000,
    reste: 63000,
    status: _ResStatus.actif,
  ),
  _MockReservation(
    id: 'res-2',
    qte: 500,
    produit: 'Manioc',
    vendeur: 'Aya N.',
    photoUrl:
        'https://images.unsplash.com/photo-1574484284002-952d92456975?w=200&h=200&fit=crop&auto=format',
    joursRestants: 21,
    acompte: 4750,
    reste: 42750,
    status: _ResStatus.actif,
  ),
  _MockReservation(
    id: 'res-3',
    qte: 60,
    produit: 'Tomate',
    vendeur: 'Marie Y.',
    photoUrl:
        'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31?w=200&h=200&fit=crop&auto=format',
    joursRestants: 3,
    acompte: 9250,
    reste: 62750,
    status: _ResStatus.presqueConverti,
  ),
];

enum _Tab { actives, converties, annulees }

// ─── Page ─────────────────────────────────────────────────────────────

/// Liste des réservations acheteur — compteur, tabs, cards.
class MesReservationsAcheteurPage extends ConsumerStatefulWidget {
  const MesReservationsAcheteurPage({super.key});

  @override
  ConsumerState<MesReservationsAcheteurPage> createState() =>
      _MesReservationsAcheteurPageState();
}

class _MesReservationsAcheteurPageState
    extends ConsumerState<MesReservationsAcheteurPage> {
  _Tab _tab = _Tab.actives;

  @override
  Widget build(BuildContext context) {
    final reservations = _kMockReservations;
    final totalAcompte =
        reservations.fold<int>(0, (s, r) => s + r.acompte);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(title: 'Mes réservations'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                children: [
                  _CounterCard(
                    count: reservations.length,
                    totalAcompte: totalAcompte,
                  ),
                  const SizedBox(height: 14),
                  _Tabs(
                    selected: _tab,
                    activesCount: reservations.length,
                    onChanged: (t) => setState(() => _tab = t),
                  ),
                  const SizedBox(height: 14),
                  if (_tab == _Tab.actives)
                    ...reservations.map((r) => _ResCard(r: r))
                  else
                    const _EmptyTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      decoration: const BoxDecoration(color: AppColors.background),
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
              title,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Counter card ─────────────────────────────────────────────────────

class _CounterCard extends StatelessWidget {
  const _CounterCard({required this.count, required this.totalAcompte});

  final int count;
  final int totalAcompte;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count réservations actives',
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${_nf.format(totalAcompte)} F en acompte',
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

// ─── Tabs ─────────────────────────────────────────────────────────────

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.selected,
    required this.activesCount,
    required this.onChanged,
  });

  final _Tab selected;
  final int activesCount;
  final ValueChanged<_Tab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabItem(
              label: 'Actives ($activesCount)',
              active: selected == _Tab.actives,
              onTap: () => onChanged(_Tab.actives),
            ),
          ),
          Expanded(
            child: _TabItem(
              label: 'Converties',
              active: selected == _Tab.converties,
              onTap: () => onChanged(_Tab.converties),
            ),
          ),
          Expanded(
            child: _TabItem(
              label: 'Annulées',
              active: selected == _Tab.annulees,
              onTap: () => onChanged(_Tab.annulees),
            ),
          ),
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
    return InkWell(
      onTap: onTap,
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
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Reservation card ─────────────────────────────────────────────────

class _ResCard extends StatelessWidget {
  const _ResCard({required this.r});

  final _MockReservation r;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Snackbars.showInfo(context, 'Détail réservation — à venir'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 54,
                    height: 54,
                    child: CachedNetworkImage(
                      imageUrl: r.photoUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          Container(color: AppColors.surfaceSoft),
                      errorWidget: (_, _, _) =>
                          Container(color: AppColors.surfaceSoft),
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
                        '${r.qte} kg · ${r.produit}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        r.vendeur,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _Chip(status: r.status, joursRestants: r.joursRestants),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.border,
                      width: AppDimens.borderThin,
                    ),
                  ),
                ),
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            const TextSpan(text: 'Acompte '),
                            TextSpan(
                              text: '${_nf.format(r.acompte)} F',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                            const TextSpan(text: ' payé · Reste '),
                            TextSpan(
                              text: '${_nf.format(r.reste)} F',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Voir',
                        style: AppTextStyles.button.copyWith(
                          fontSize: 12,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Chip statut ──────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({required this.status, required this.joursRestants});

  final _ResStatus status;
  final int joursRestants;

  @override
  Widget build(BuildContext context) {
    final isRed = status == _ResStatus.presqueConverti;
    final bg = isRed ? _kErrorSoft : _kWarnSoft;
    final fg = isRed ? _kErrorText : _kWarnText;
    final label = isRed
        ? 'J-$joursRestants · presque convertie'
        : 'J-$joursRestants';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bg),
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

// ─── Empty tab (Converties/Annulées) ──────────────────────────────────

class _EmptyTab extends StatelessWidget {
  const _EmptyTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 40,
            color: AppColors.textSubtle,
          ),
          const SizedBox(height: 10),
          Text(
            'Aucune réservation ici.',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────

final _nf = NumberFormat('#,##0', 'fr_FR');
