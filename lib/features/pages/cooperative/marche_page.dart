import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/header_utilisateur.dart';

// ─── Couleurs locales (alignées sur la maquette) ────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Onglets en haut de la page Marché coop.
enum _PubTab { actives, archivees }

/// Modèle local pour une publication coop mock.
class _MockPub {
  final String id;
  final String produit;
  final String quantiteLabel;
  final String prixKgLabel;
  final int nbContributeurs;
  final String photoUrl;

  const _MockPub({
    required this.id,
    required this.produit,
    required this.quantiteLabel,
    required this.prixKgLabel,
    required this.nbContributeurs,
    required this.photoUrl,
  });
}

/// Liste mock alignée 1:1 sur `mockups/cooperative/marche.html` (6 cards
/// publication actives).
const List<_MockPub> _kMockPubs = [
  _MockPub(
    id: 'pub_mais',
    produit: 'Maïs grain blanc',
    quantiteLabel: '500 kg',
    prixKgLabel: '350 F/kg',
    nbContributeurs: 3,
    photoUrl:
        'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716'
        '?w=400&h=300&fit=crop&auto=format',
  ),
  _MockPub(
    id: 'pub_manioc',
    produit: 'Manioc frais',
    quantiteLabel: '1 000 kg',
    prixKgLabel: '95 F/kg',
    nbContributeurs: 6,
    photoUrl:
        'https://images.unsplash.com/photo-1574484284002-952d92456975'
        '?w=400&h=300&fit=crop&auto=format',
  ),
  _MockPub(
    id: 'pub_riz',
    produit: 'Riz local',
    quantiteLabel: '200 kg',
    prixKgLabel: '360 F/kg',
    nbContributeurs: 2,
    photoUrl:
        'https://images.unsplash.com/photo-1586201375761-83865001e31c'
        '?w=400&h=300&fit=crop&auto=format',
  ),
  _MockPub(
    id: 'pub_igname',
    produit: 'Igname pilable',
    quantiteLabel: '300 kg',
    prixKgLabel: '160 F/kg',
    nbContributeurs: 3,
    photoUrl:
        'https://images.unsplash.com/photo-1568569350062-ebfa3cb195df'
        '?w=400&h=300&fit=crop&auto=format',
  ),
  _MockPub(
    id: 'pub_tomate',
    produit: 'Tomate',
    quantiteLabel: '80 kg',
    prixKgLabel: '450 F/kg',
    nbContributeurs: 2,
    photoUrl:
        'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31'
        '?w=400&h=300&fit=crop&auto=format',
  ),
  _MockPub(
    id: 'pub_banane',
    produit: 'Banane plantain',
    quantiteLabel: '450 kg',
    prixKgLabel: '180 F/kg',
    nbContributeurs: 4,
    photoUrl:
        'https://images.unsplash.com/photo-1488459716781-31db52582fe9'
        '?w=400&h=300&fit=crop&auto=format',
  ),
];

/// Onglet Marché de la coopérative — accessible via le bottom-nav (shell).
///
/// Reproduction fidèle de `mockups/cooperative/marche.html` : header coop,
/// compteur primary-soft, tab bar « Actives / Archivées », grille 2 col de
/// cards publication avec photo, quantité, prix kg, nb contributeurs.
///
/// Mock-first : à brancher sur `coopSvc.listPublications()` quand prêt.
class MarcheCooperativePage extends ConsumerStatefulWidget {
  const MarcheCooperativePage({super.key});

  @override
  ConsumerState<MarcheCooperativePage> createState() =>
      _MarcheCooperativePageState();
}

class _MarcheCooperativePageState extends ConsumerState<MarcheCooperativePage> {
  _PubTab _tab = _PubTab.actives;

  List<_MockPub> get _filtered =>
      _tab == _PubTab.actives ? _kMockPubs : const [];

  void _ouvrirPub(_MockPub p) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Détail publication ${p.produit} à venir'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final pubs = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderUtilisateur(variant: HeaderVariant.cooperative),
            const _PageTitle(),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimens.pagePaddingH,
                0,
                AppDimens.pagePaddingH,
                AppDimens.space12,
              ),
              child: _CounterHero(
                titre: '8 publications actives',
                sousTitre: '4.2 tonnes',
              ),
            ),
            _TabBar(
              current: _tab,
              activesCount: _kMockPubs.length,
              onSelect: (t) => setState(() => _tab = t),
            ),
            Expanded(
              child: pubs.isEmpty
                  ? const _EmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.pagePaddingH,
                        AppDimens.space12,
                        AppDimens.pagePaddingH,
                        AppDimens.space16,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: pubs.length,
                      itemBuilder: (_, i) => _PubCard(
                        pub: pubs[i],
                        onTap: () => _ouvrirPub(pubs[i]),
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
      child: Text(
        'Marché · Publications',
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

// ─── Compteur hero (primary soft) ───────────────────────────────────────

class _CounterHero extends StatelessWidget {
  const _CounterHero({required this.titre, required this.sousTitre});

  final String titre;
  final String sousTitre;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            titre,
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sousTitre,
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

// ─── Tab bar ────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.current,
    required this.activesCount,
    required this.onSelect,
  });

  final _PubTab current;
  final int activesCount;
  final ValueChanged<_PubTab> onSelect;

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
          _tab(_PubTab.actives, 'Actives ($activesCount)'),
          _tab(_PubTab.archivees, 'Archivées'),
        ],
      ),
    );
  }

  Widget _tab(_PubTab value, String label) {
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

// ─── Publication card (grid item) ───────────────────────────────────────

class _PubCard extends StatelessWidget {
  const _PubCard({required this.pub, required this.onTap});

  final _MockPub pub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 11,
                child: CachedNetworkImage(
                  imageUrl: pub.photoUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      const ColoredBox(color: AppColors.surfaceSoft),
                  errorWidget: (_, _, _) => Container(
                    color: AppColors.surfaceSoft,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_outlined,
                      color: AppColors.textSubtle,
                      size: 22,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pub.produit,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pub.quantiteLabel,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pub.prixKgLabel,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pub.nbContributeurs} contributeurs',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
              Icons.storefront_outlined,
              size: 40,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Aucune publication archivée',
              style: AppTextStyles.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
