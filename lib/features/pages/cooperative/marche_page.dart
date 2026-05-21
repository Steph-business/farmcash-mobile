import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/enums.dart';
import '../../../models/publication_coop.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/header_utilisateur.dart';
import '../../widgets/communs/vue_erreur.dart';

// ─── Couleurs locales (alignées sur la maquette) ────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Onglets en haut de la page Marché coop.
enum _PubTab { actives, archivees }

/// Bundle pour la page : publications actives + archivées (filtrées
/// côté client) + total kg pour le compteur hero.
class _MarcheBundle {
  const _MarcheBundle({required this.actives, required this.archivees});
  final List<PublicationCoop> actives;
  final List<PublicationCoop> archivees;
}

bool _isActive(PublicationCoop p) =>
    p.status == ProductStatus.active || p.status == ProductStatus.unknown;

final _marcheCoopProvider = FutureProvider.autoDispose
    .family<_MarcheBundle, String>((ref, cooperativeId) async {
  final svc = ref.read(cooperativesServiceProvider);
  final page = await svc.listPublications(
    cooperativeId: cooperativeId,
    limit: 100,
  );
  final all = page.data;
  return _MarcheBundle(
    actives: all.where(_isActive).toList(growable: false),
    archivees: all
        .where((p) =>
            p.status == ProductStatus.sold ||
            p.status == ProductStatus.expired ||
            p.status == ProductStatus.paused)
        .toList(growable: false),
  );
});

/// Onglet Marché de la coopérative — branché sur `listPublications`.
class MarcheCooperativePage extends ConsumerStatefulWidget {
  const MarcheCooperativePage({super.key});

  @override
  ConsumerState<MarcheCooperativePage> createState() =>
      _MarcheCooperativePageState();
}

class _MarcheCooperativePageState extends ConsumerState<MarcheCooperativePage> {
  _PubTab _tab = _PubTab.actives;

  void _ouvrirPub(PublicationCoop p) {
    // V1 : pas d'écran "détail publication" coop. On informe.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Détail publication ${p.titre} — à venir'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final coopId = user?.cooperativeId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderUtilisateur(variant: HeaderVariant.cooperative),
            const _PageTitle(),
            Expanded(
              child: coopId == null
                  ? const _NoCoopState()
                  : _buildLoaded(coopId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoaded(String coopId) {
    final async = ref.watch(_marcheCoopProvider(coopId));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Chargement(size: 22),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(AppDimens.pagePaddingH),
        child: VueErreur(
          message: 'Impossible de charger les publications. $e',
          onRetry: () => ref.invalidate(_marcheCoopProvider(coopId)),
        ),
      ),
      data: (bundle) {
        final pubs = _tab == _PubTab.actives ? bundle.actives : bundle.archivees;
        final totalKgActives =
            bundle.actives.fold<double>(0, (acc, p) => acc + p.quantiteKg);
        final tonnesLabel = _formatTonnes(totalKgActives);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.pagePaddingH,
                0,
                AppDimens.pagePaddingH,
                AppDimens.space12,
              ),
              child: _CounterHero(
                titre: '${bundle.actives.length} publications actives',
                sousTitre: tonnesLabel,
              ),
            ),
            _TabBar(
              current: _tab,
              activesCount: bundle.actives.length,
              archiveesCount: bundle.archivees.length,
              onSelect: (t) => setState(() => _tab = t),
            ),
            Expanded(
              child: pubs.isEmpty
                  ? _EmptyState(tab: _tab)
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {
                        ref.invalidate(_marcheCoopProvider(coopId));
                        await ref.read(_marcheCoopProvider(coopId).future);
                      },
                      child: GridView.builder(
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
            ),
          ],
        );
      },
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
    required this.archiveesCount,
    required this.onSelect,
  });

  final _PubTab current;
  final int activesCount;
  final int archiveesCount;
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
          _tab(_PubTab.archivees, 'Archivées ($archiveesCount)'),
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

  final PublicationCoop pub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photoUrl = pub.photos.isNotEmpty ? pub.photos.first : null;
    final qteLabel = '${_fmtKg(pub.quantiteKg)} kg';
    final prixLabel = '${_fmtMontant(pub.prixParKg)} F/kg';
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
                child: photoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: photoUrl,
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
                      )
                    : Container(
                        color: AppColors.surfaceSoft,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.textSubtle,
                          size: 22,
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
                      pub.titre,
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
                      qteLabel,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      prixLabel,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _statusLabel(pub.status),
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
  const _EmptyState({required this.tab});

  final _PubTab tab;

  @override
  Widget build(BuildContext context) {
    final msg = tab == _PubTab.actives
        ? 'Aucune publication active.'
        : 'Aucune publication archivée.';
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
              msg,
              style: AppTextStyles.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoCoopState extends StatelessWidget {
  const _NoCoopState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Text(
          "Aucune coopérative associée à votre compte.",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────

String _formatTonnes(double kg) {
  if (kg < 1000) return '${kg.round()} kg';
  final tonnes = kg / 1000;
  if (tonnes >= 10) return '${tonnes.toStringAsFixed(0)} tonnes';
  return '${tonnes.toStringAsFixed(1)} tonnes';
}

String _fmtKg(double kg) {
  final i = kg.round();
  return _fmtMontant(i.toDouble());
}

String _fmtMontant(double v) {
  final i = v.round();
  if (i < 1000) return '$i';
  final s = '$i';
  final buf = StringBuffer();
  for (var k = 0; k < s.length; k++) {
    if (k > 0 && (s.length - k) % 3 == 0) buf.write(' ');
    buf.write(s[k]);
  }
  return buf.toString();
}

String _statusLabel(ProductStatus status) {
  switch (status) {
    case ProductStatus.active:
      return 'Active';
    case ProductStatus.paused:
      return 'En pause';
    case ProductStatus.sold:
      return 'Vendue';
    case ProductStatus.expired:
      return 'Expirée';
    case ProductStatus.draft:
      return 'Brouillon';
    case ProductStatus.unknown:
      return '';
  }
}

