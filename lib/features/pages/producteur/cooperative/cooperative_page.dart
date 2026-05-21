import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../state/auth_state.dart';
import '../../../widgets/communs/snackbars.dart';

// ─── COULEURS & RADIUS LOCAUX ───────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarnSoft = Color(0xFFFFF8E1);
const Color _kWarn = Color(0xFFB26A00);
const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));

// Logo mock pour la coop par défaut.
const String _kLogoMock =
    'https://images.unsplash.com/photo-1530507629858-e3759c3b9d4f'
    '?w=200&h=200&fit=crop&auto=format';

/// Publication mock pour la liste "Publications en cours".
class _PubMock {
  final String id;
  final String titre;
  final String quantite;
  final String prix;
  const _PubMock({
    required this.id,
    required this.titre,
    required this.quantite,
    required this.prix,
  });
}

const List<_PubMock> _kPubsMock = [
  _PubMock(
    id: 'PUB-001',
    titre: 'Maïs grain blanc',
    quantite: '4 500 kg agrégés',
    prix: '350 F/kg',
  ),
  _PubMock(
    id: 'PUB-002',
    titre: 'Manioc frais',
    quantite: '6 200 kg agrégés',
    prix: '200 F/kg',
  ),
  _PubMock(
    id: 'PUB-003',
    titre: 'Cacao fèves',
    quantite: '1 800 kg agrégés',
    prix: '1 250 F/kg',
  ),
];

/// Sollicitation mock pour la liste "Sollicitations".
class _SollicitationMock {
  final String id;
  final String titre;
  final String date;
  const _SollicitationMock({
    required this.id,
    required this.titre,
    required this.date,
  });
}

const List<_SollicitationMock> _kSollicitations = [
  _SollicitationMock(
    id: 'SOL-001',
    titre: 'Cacao fèves · 500 kg demandés',
    date: 'il y a 2 j',
  ),
  _SollicitationMock(
    id: 'SOL-002',
    titre: 'Maïs blanc · 300 kg demandés',
    date: 'il y a 5 j',
  ),
  _SollicitationMock(
    id: 'SOL-003',
    titre: 'Manioc · 800 kg demandés',
    date: 'il y a 1 sem',
  ),
];

/// Aperçu de la coopérative du producteur — vue côté membre.
///
/// Affiche le logo + nom + stats + publications en cours + sollicitations.
/// Tap sur une publication → détail. Tap "Voir tous les membres" →
/// snackbar (route dédiée non encore prête côté API publique).
class CooperativePage extends ConsumerWidget {
  const CooperativePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    // Fallback "COOP-AGRI Lagunes" si l'utilisateur n'a pas de coop ou
    // qu'on n'a pas de nom : pas de blocage UX.
    final coopNom = user?.cooperativeId != null
        ? 'COOP-AGRI Lagunes'
        : 'COOP-AGRI Lagunes';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  0,
                  AppDimens.pagePaddingH,
                  AppDimens.space24,
                ),
                children: [
                  _HeroCard(nom: coopNom),
                  AppDimens.vGap16,
                  const _StatsRow(
                    membres: '48',
                    publications: '3',
                    sollicitations: '2',
                  ),
                  AppDimens.vGap24,
                  const _SectionTitle('Publications en cours'),
                  AppDimens.vGap12,
                  _PublicationsList(
                    items: _kPubsMock,
                    onTap: (p) => context.push(
                      RouteNames.producteurPublicationCoopDetailPathFor(p.id),
                    ),
                  ),
                  AppDimens.vGap24,
                  const _SectionTitle('Sollicitations'),
                  AppDimens.vGap12,
                  _SollicitationsList(
                    items: _kSollicitations,
                    onTap: (_) =>
                        context.push(RouteNames.producteurSollicitationsPath),
                  ),
                  AppDimens.vGap24,
                  _BoutonMembres(
                    onTap: () => Snackbars.showInfo(
                      context,
                      'Liste des membres — à venir',
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
                : context.go(RouteNames.accueilProducteurPath),
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
              'Ma coopérative',
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
  const _HeroCard({required this.nom});

  final String nom;

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
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: CachedNetworkImage(
              imageUrl: _kLogoMock,
              fit: BoxFit.cover,
              placeholder: (_, __) => const ColoredBox(color: _kPrimarySoft),
              errorWidget: (_, __, ___) => Center(
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
          ),
          const SizedBox(height: 12),
          Text(
            nom,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Tu es membre actif',
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

// ─── Stats row ──────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.membres,
    required this.publications,
    required this.sollicitations,
  });

  final String membres;
  final String publications;
  final String sollicitations;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(value: membres, label: 'Membres')),
        const SizedBox(width: 8),
        Expanded(child: _StatCard(value: publications, label: 'Publications')),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(value: sollicitations, label: 'Sollicitations'),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
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

// ─── Publications list ──────────────────────────────────────────────────

class _PublicationsList extends StatelessWidget {
  const _PublicationsList({required this.items, required this.onTap});

  final List<_PubMock> items;
  final ValueChanged<_PubMock> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          InkWell(
            onTap: () => onTap(items[i]),
            borderRadius: _kBrCard,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: _kBrCard,
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _kPrimarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      size: 20,
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
                          items[i].titre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          items[i].quantite,
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
                    items[i].prix,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: -0.2,
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
          if (i < items.length - 1) AppDimens.vGap8,
        ],
      ],
    );
  }
}

// ─── Sollicitations list ────────────────────────────────────────────────

class _SollicitationsList extends StatelessWidget {
  const _SollicitationsList({required this.items, required this.onTap});

  final List<_SollicitationMock> items;
  final ValueChanged<_SollicitationMock> onTap;

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
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _kWarnSoft,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.notifications_outlined,
                        size: 16,
                        color: _kWarn,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            items[i].titre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            items[i].date,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: AppColors.textSubtle,
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

// ─── Bouton "Voir tous les membres" ─────────────────────────────────────

class _BoutonMembres extends StatelessWidget {
  const _BoutonMembres({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(
          Icons.groups_outlined,
          size: 18,
          color: AppColors.primary,
        ),
        label: Text(
          'Voir tous les membres',
          style: AppTextStyles.button.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(
            color: AppColors.primary,
            width: AppDimens.borderThin,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimens.brButton,
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────

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
