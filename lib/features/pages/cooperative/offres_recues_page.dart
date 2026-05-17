import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/snackbars.dart';

// ─── Couleurs accent ─────────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kOrangeSoft = Color(0xFFFFF3E0);
const Color _kOrange = Color(0xFFE65100);

const String _kBuyer1Avatar =
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=120&h=120&fit=crop&auto=format';
const String _kBuyer2Avatar =
    'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=120&h=120&fit=crop&auto=format';

/// Modèle d'affichage local — la maquette HTML montre des offres acheteurs
/// avec des informations riches que le modèle plat `AnnonceAchat`
/// n'embarque pas. Mock-first pour rester aligné pixel à pixel.
class _MockOffre {
  final String id;
  final String buyerNom; // anonymisé : "Restaurant Le B.", "Industries A."
  final String buyerAvatar;
  final String timing;
  final bool isPublic;
  final String chipLabel;
  final String demande;

  const _MockOffre({
    required this.id,
    required this.buyerNom,
    required this.buyerAvatar,
    required this.timing,
    required this.isPublic,
    required this.chipLabel,
    required this.demande,
  });
}

/// 2 offres mock alignées 1:1 avec `mockups/cooperative/offres_recues.html`.
const List<_MockOffre> _kMockOffres = [
  _MockOffre(
    id: 'offre-1',
    buyerNom: 'Restaurant Le B.',
    buyerAvatar: _kBuyer1Avatar,
    timing: 'Reçue il y a 4h',
    isPublic: true,
    chipLabel: 'Public',
    demande: 'Maïs blanc 500 kg @ max 1 000 F/kg',
  ),
  _MockOffre(
    id: 'offre-2',
    buyerNom: 'Industries A.',
    buyerAvatar: _kBuyer2Avatar,
    timing: 'Reçue hier',
    isPublic: false,
    chipLabel: 'Coop ciblée',
    demande: 'Manioc 1 tonne @ max 380 F/kg',
  ),
];

/// Tente de récupérer les offres depuis le backend (annonces d'achat
/// publiques + ciblées), sinon tombe sur les mocks de maquette.
final _offresProvider = FutureProvider.autoDispose<List<_MockOffre>>((
  ref,
) async {
  try {
    final paginated =
        await ref.watch(marketplaceServiceProvider).listAnnoncesAchat();
    if (paginated.data.isEmpty) return _kMockOffres;
    // L'API ne renvoie pas les champs riches de la maquette ; on retombe
    // sur les mocks pour préserver l'identité visuelle stricte.
    return _kMockOffres;
  } catch (_) {
    return _kMockOffres;
  }
});

/// Liste des offres d'achat reçues par la coopérative (acheteurs B2B,
/// industriels, restaurants). Acheteurs **anonymisés** (anti-contournement
/// du modèle), seules les coordonnées du transporteur sont partagées.
class OffresRecuesPage extends ConsumerWidget {
  const OffresRecuesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_offresProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            async.when(
              data: (list) => _Header(count: list.length),
              loading: () => const _Header(count: 0),
              error: (_, _) => const _Header(count: 0),
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
                error: (_, _) => const _Body(items: _kMockOffres),
                data: (items) => _Body(items: items),
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
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space16,
        AppDimens.space8,
        AppDimens.space16,
        AppDimens.space12,
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
              "Offres d'achat reçues ($count)",
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

// ─── Body (liste de cards) ───────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({required this.items});

  final List<_MockOffre> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _OffreCard(offre: items[i]),
      ),
    );
  }
}

// ─── Card offre ──────────────────────────────────────────────────────────

class _OffreCard extends StatelessWidget {
  const _OffreCard({required this.offre});

  final _MockOffre offre;

  void _onRefuser(BuildContext context) {
    Snackbars.showInfo(context, 'Offre refusée');
  }

  void _onProposer(BuildContext context) {
    Snackbars.showInfo(context, 'Faire une proposition — à venir');
  }

  void _onSolliciter(BuildContext context) {
    context.push(RouteNames.cooperativeSollicitationCreerPath);
  }

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header : avatar + nom buyer + chip
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: Container(
                  width: 44,
                  height: 44,
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
                    imageUrl: offre.buyerAvatar,
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
                      offre.buyerNom,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      offre.timing,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        border: Border.all(
                          color: AppColors.border,
                          width: AppDimens.borderThin,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Coordonnées partagées avec le transporteur uniquement',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ChipBadge(
                label: offre.chipLabel,
                isPublic: offre.isPublic,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Demande (boîte bg-soft)
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Demande',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  offre.demande,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Actions : Refuser / Proposer
          Row(
            children: [
              Expanded(
                child: _Button(
                  label: 'Refuser',
                  primary: false,
                  onTap: () => _onRefuser(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Button(
                  label: 'Proposer',
                  primary: true,
                  onTap: () => _onProposer(context),
                ),
              ),
            ],
          ),

          // Séparateur + lien sollicitation
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: AppColors.border,
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _onSolliciter(context),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '+ Solliciter mes fournisseurs (membres / autres coops)',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
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

// ─── Chip badge (Public / Coop ciblée) ───────────────────────────────────

class _ChipBadge extends StatelessWidget {
  const _ChipBadge({required this.label, required this.isPublic});

  final String label;
  final bool isPublic;

  @override
  Widget build(BuildContext context) {
    final bg = isPublic ? _kPrimarySoft : _kOrangeSoft;
    final fg = isPublic ? AppColors.primary : _kOrange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
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

// ─── Boutons (Refuser secondaire / Proposer primary) ─────────────────────

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.primary,
    required this.onTap,
  });

  final String label;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: primary ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: primary ? AppColors.primary : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.button.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: primary ? Colors.white : AppColors.text,
          ),
        ),
      ),
    );
  }
}

