import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../models/negociation.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';

// ─── Constantes ────────────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarn = Color(0xFFB45309);

// ─── Mock propositions ─────────────────────────────────────────────────

class _MockProposition {
  const _MockProposition({
    required this.id,
    required this.farmerNom,
    required this.farmerVille,
    required this.farmerDistance,
    required this.rating,
    required this.avatarUrl,
    required this.qteDispo,
    required this.prixParKg,
    required this.note,
  });
  final String id;
  final String farmerNom;
  final String farmerVille;
  final String farmerDistance;
  final double rating;
  final String avatarUrl;
  final int qteDispo;
  final int prixParKg;
  final String? note;
}

const List<_MockProposition> _kMockPropositions = [
  _MockProposition(
    id: 'p-1',
    farmerNom: 'Yao K.',
    farmerVille: 'Yopougon',
    farmerDistance: 'à 12 km',
    rating: 4.8,
    avatarUrl:
        'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=200&h=200&fit=crop&auto=format',
    qteDispo: 500,
    prixParKg: 780,
    note:
        'J\'ai exactement la quantité, qualité standard sèche. Livrable dès demain.',
  ),
  _MockProposition(
    id: 'p-2',
    farmerNom: 'Mariam K.',
    farmerVille: 'Korhogo',
    farmerDistance: 'à 38 km',
    rating: 4.6,
    avatarUrl:
        'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200&h=200&fit=crop&auto=format',
    qteDispo: 500,
    prixParKg: 810,
    note: null,
  ),
  _MockProposition(
    id: 'p-3',
    farmerNom: 'COOP-AGRI L.',
    farmerVille: 'Abidjan',
    farmerDistance: 'à 8 km',
    rating: 4.9,
    avatarUrl:
        'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=200&h=200&fit=crop&auto=format',
    qteDispo: 500,
    prixParKg: 820,
    note: 'Qualité premium, lot homogène contrôlé par la coop.',
  ),
  _MockProposition(
    id: 'p-4',
    farmerNom: 'Adama D.',
    farmerVille: 'Bouaké',
    farmerDistance: 'à 95 km',
    rating: 4.4,
    avatarUrl:
        'https://images.unsplash.com/photo-1567521464027-f127ff144326?w=200&h=200&fit=crop&auto=format',
    qteDispo: 300,
    prixParKg: 830,
    note: null,
  ),
  _MockProposition(
    id: 'p-5',
    farmerNom: 'Issa T.',
    farmerVille: 'Daloa',
    farmerDistance: 'à 65 km',
    rating: 4.7,
    avatarUrl:
        'https://images.unsplash.com/photo-1574484284002-952d92456975?w=200&h=200&fit=crop&auto=format',
    qteDispo: 500,
    prixParKg: 850,
    note: null,
  ),
];

_MockProposition _propositionToMock(Proposition p, int index) {
  final fallback = _kMockPropositions[index % _kMockPropositions.length];
  return _MockProposition(
    id: p.id,
    farmerNom: fallback.farmerNom,
    farmerVille: fallback.farmerVille,
    farmerDistance: fallback.farmerDistance,
    rating: fallback.rating,
    avatarUrl: fallback.avatarUrl,
    qteDispo: p.quantiteKg.round(),
    prixParKg: p.prixProposeKg.round(),
    note: (p.message != null && p.message!.isNotEmpty) ? p.message : null,
  );
}

final _propositionsAcheteurProvider = FutureProvider.autoDispose
    .family<List<_MockProposition>, String>((ref, demandeId) async {
  try {
    final props = await ref
        .watch(negotiationServiceProvider)
        .listPropositions(direction: 'incoming');
    final filtered =
        props.where((p) => p.annonceAchatId == demandeId).toList();
    if (filtered.isEmpty) return _kMockPropositions;
    return [
      for (var i = 0; i < filtered.length; i++)
        _propositionToMock(filtered[i], i),
    ];
  } catch (_) {
    return _kMockPropositions;
  }
});

/// Liste des propositions reçues sur une demande d'achat — côté ACHETEUR.
/// Calque sur `mockups/acheteur/proposition_detail.html`.
class PropositionDetailAcheteurPage extends ConsumerWidget {
  const PropositionDetailAcheteurPage({required this.demandeId, super.key});

  final String demandeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_propositionsAcheteurProvider(demandeId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              count: async.maybeWhen(
                data: (l) => l.length,
                orElse: () => 5,
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (_, _) => const _Body(items: _kMockPropositions),
                data: (items) => _Body(
                  items: items.isEmpty ? _kMockPropositions : items,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.count});
  final int count;
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
              'Propositions reçues ($count)',
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

// ─── Body ──────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({required this.items});
  final List<_MockProposition> items;

  @override
  Widget build(BuildContext context) {
    final sorted = [...items]
      ..sort((a, b) => a.prixParKg.compareTo(b.prixParKg));
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      children: [
        const _RecapDemande(),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.tune,
                    size: 14,
                    color: AppColors.text,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Trier : Prix le plus bas',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < sorted.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PropositionCard(
              proposition: sorted[i],
              isBest: i == 0,
            ),
          ),
      ],
    );
  }
}

// ─── Recap demande (primary-soft) ──────────────────────────────────────

class _RecapDemande extends StatelessWidget {
  const _RecapDemande();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MA DEMANDE',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '500 kg Maïs blanc · max 850 F/kg · livraison sous 7j',
            style: AppTextStyles.bodyMedium.copyWith(
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

// ─── Card proposition ──────────────────────────────────────────────────

class _PropositionCard extends StatelessWidget {
  const _PropositionCard({
    required this.proposition,
    required this.isBest,
  });
  final _MockProposition proposition;
  final bool isBest;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isBest ? AppColors.primary : AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FarmerRow(proposition: proposition),
              const SizedBox(height: 10),
              _OfferBox(proposition: proposition),
              if (proposition.note != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.border,
                      width: AppDimens.borderThin,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Text(
                    '« ${proposition.note} »',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              _Actions(proposition: proposition),
            ],
          ),
        ),
        if (isBest)
          Positioned(
            top: -9,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: _kPrimarySoft,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.primary,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Text(
                '★ Meilleur prix',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FarmerRow extends StatelessWidget {
  const _FarmerRow({required this.proposition});
  final _MockProposition proposition;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: Container(
            width: 38,
            height: 38,
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
              imageUrl: proposition.avatarUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
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
                proposition.farmerNom,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                '${proposition.farmerVille} · ${proposition.farmerDistance}',
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
          '★ ${proposition.rating.toStringAsFixed(1)}',
          style: const TextStyle(
            color: _kWarn,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _OfferBox extends StatelessWidget {
  const _OfferBox({required this.proposition});
  final _MockProposition proposition;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'QUANTITÉ',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${proposition.qteDispo} kg dispo',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_nf.format(proposition.prixParKg)} F',
                style: AppTextStyles.displaySmall.copyWith(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                '/kg',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.proposition});
  final _MockProposition proposition;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionBtn(
            label: 'Refuser',
            onTap: () => Snackbars.showInfo(
              context,
              'Proposition de ${proposition.farmerNom} refusée.',
            ),
            color: AppColors.textSecondary,
            background: AppColors.background,
            borderColor: AppColors.border,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionBtn(
            label: 'Discuter',
            onTap: () =>
                Snackbars.showInfo(context, 'Messagerie — à venir.'),
            color: AppColors.primary,
            background: AppColors.background,
            borderColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionBtn(
            label: 'Accepter',
            onTap: () => Snackbars.showSucces(
              context,
              'Proposition acceptée — passage au paiement.',
            ),
            color: AppColors.onPrimary,
            background: AppColors.primary,
            borderColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.onTap,
    required this.color,
    required this.background,
    required this.borderColor,
  });
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color background;
  final Color borderColor;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: AppDimens.borderThin,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ───────────────────────────────────────────────────────────

final _nf = NumberFormat('#,##0', 'fr_FR');
