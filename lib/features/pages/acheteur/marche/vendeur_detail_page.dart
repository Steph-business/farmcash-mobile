import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── COULEURS & RADIUS LOCAUX ───────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));

// ─── Provider ──────────────────────────────────────────────────────────

final _annoncesVendeurProvider = FutureProvider.autoDispose
    .family<List<AnnonceVente>, String>((ref, farmerId) async {
  final result = await ref
      .read(marketplaceServiceProvider)
      .listAnnoncesVente(farmerId: farmerId, limit: 50);
  return result.data;
});

/// Profil public d'un vendeur (producteur ou coop) — vue acheteur.
///
/// Branche sur `listAnnoncesVente(farmerId:)` : on filtre les annonces du
/// farmer, et on extrait son nom public depuis la première annonce (le
/// backend joint `users: { full_name, rating, photo_url }`).
///
/// Conforme à la règle 3b chantier 3 : les coordonnées personnelles
/// (téléphone, vraie identité) ne sont JAMAIS affichées. Seul le nom
/// public + le bouton "Message" sont exposés.
class VendeurDetailPage extends ConsumerWidget {
  const VendeurDetailPage({super.key, required this.farmerId});

  final String farmerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_annoncesVendeurProvider(farmerId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger le profil vendeur. $e',
                    onRetry: () => ref
                        .invalidate(_annoncesVendeurProvider(farmerId)),
                  ),
                ),
                data: (annonces) => _buildBody(context, annonces),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<AnnonceVente> annonces) {
    if (annonces.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 44,
                color: AppColors.textSubtle.withValues(alpha: 0.9),
              ),
              const SizedBox(height: AppDimens.space12),
              Text(
                'Profil vendeur indisponible',
                style: AppTextStyles.titleSmall,
              ),
              const SizedBox(height: AppDimens.space8),
              Text(
                'Ce vendeur n\'a aucune annonce active pour\nle moment.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final premiere = annonces.first;
    final vendeur = premiere.vendeur;
    final suffixLen = farmerId.length < 4 ? farmerId.length : 4;
    final nomPublic = vendeur?.fullName?.trim().isNotEmpty == true
        ? vendeur!.fullName!.trim()
        : 'Vendeur ${farmerId.substring(farmerId.length - suffixLen)}';
    final ville = premiere.localisationLabel ?? '';
    final rating = vendeur?.rating;
    final photo = vendeur?.photoUrl;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space24,
      ),
      children: [
        _HeroCard(
          nom: nomPublic,
          ville: ville,
          photoUrl: photo,
          verifie: false,
        ),
        AppDimens.vGap16,
        _StatsRow(
          note: rating != null && rating > 0
              ? rating.toStringAsFixed(1)
              : '—',
          annoncesActives: annonces.length.toString(),
        ),
        AppDimens.vGap24,
        const _SectionTitle('Annonces actives'),
        AppDimens.vGap12,
        _AnnoncesList(
          items: annonces,
          onTap: (a) =>
              context.push(RouteNames.acheteurAnnonceDetailPathFor(a.id)),
        ),
        AppDimens.vGap24,
        _CtaMessage(
          onTap: () =>
              Snackbars.showInfo(context, 'Envoyer un message — à venir'),
        ),
      ],
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

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
          InkWell(
            onTap: () => context.canPop()
                ? context.pop()
                : context.go(RouteNames.acheteurMarchePath),
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
              'Profil vendeur',
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

// ─── Hero card ──────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.nom,
    required this.ville,
    required this.photoUrl,
    required this.verifie,
  });

  final String nom;
  final String ville;
  final String? photoUrl;
  final bool verifie;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: photoUrl != null && photoUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: photoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        const ColoredBox(color: _kPrimarySoft),
                    errorWidget: (_, _, _) => Center(
                      child: Text(
                        _initiales(nom),
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      _initiales(nom),
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            nom,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (ville.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              ville,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (verifie) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: _kPrimarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Vérifié',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Stats row ──────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.note,
    required this.annoncesActives,
  });

  final String note;
  final String annoncesActives;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(value: '$note★', label: 'Note')),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(value: annoncesActives, label: 'Annonces'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard,
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
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: AppColors.text,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section title ──────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.titre);

  final String titre;

  @override
  Widget build(BuildContext context) {
    return Text(
      titre,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ─── Annonces list ──────────────────────────────────────────────────────

class _AnnoncesList extends StatelessWidget {
  const _AnnoncesList({required this.items, required this.onTap});

  final List<AnnonceVente> items;
  final ValueChanged<AnnonceVente> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            InkWell(
              onTap: () => onTap(items[i]),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.space16,
                  vertical: AppDimens.space12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _kPrimarySoft,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.border,
                          width: AppDimens.borderThin,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: items[i].photos.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: items[i].photos.first,
                              fit: BoxFit.cover,
                              placeholder: (_, _) =>
                                  const ColoredBox(color: _kPrimarySoft),
                              errorWidget: (_, _, _) => const Icon(
                                Icons.image_outlined,
                                size: 22,
                                color: AppColors.textSubtle,
                              ),
                            )
                          : const Icon(
                              Icons.image_outlined,
                              size: 22,
                              color: AppColors.textSubtle,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            items[i].produitLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_fmtKg(items[i].quantiteKg)} disponibles',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_nf.format(items[i].prixParKg)} F/kg',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (i < items.length - 1)
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

// ─── CTA Message ────────────────────────────────────────────────────────

class _CtaMessage extends StatelessWidget {
  const _CtaMessage({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(
          Icons.chat_bubble_outline,
          size: 18,
          color: AppColors.onPrimary,
        ),
        label: Text(
          'Envoyer un message',
          style: AppTextStyles.button.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.onPrimary,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimens.brButton,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space24,
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────

final _nf = NumberFormat('#,##0', 'fr_FR');

String _fmtKg(double v) => '${_nf.format(v.round())} kg';

String _initiales(String s) {
  final t = s.trim();
  if (t.isEmpty) return '?';
  final parts = t.split(RegExp(r'[\s\-_]+'))..removeWhere((p) => p.isEmpty);
  if (parts.length >= 2) {
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
  if (t.length == 1) return t.toUpperCase();
  return t.substring(0, 2).toUpperCase();
}
