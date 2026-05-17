import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/sollicitation.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

// ─── Couleurs accent (warn-soft pour chip urgent) ────────────────────────

const Color _kWarnSoft = Color(0xFFFFF8E1);
const Color _kWarn = Color(0xFFB26A00);

const String _kCoopAvatar =
    'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=120&h=120&fit=crop&auto=format';
const String _kMaisThumb =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=200&h=200&fit=crop&auto=format';
const String _kManiocThumb =
    'https://images.unsplash.com/photo-1574484284002-952d92456975?w=200&h=200&fit=crop&auto=format';

/// Modèle d'affichage local — calque la maquette HTML qui montre une coop
/// initiatrice + un produit + des compteurs de progression. Le modèle
/// backend `Sollicitation` n'embarque pas ces champs riches (il faut un
/// 2e appel `getSollicitation(id)` qui renvoie une Map). Mock-first pour
/// rester aligné pixel à pixel sur la maquette.
class _MockSollicitation {
  final String id;
  final String coopNom;
  final String coopAvatar;
  final String timing;
  final bool urgent;
  final String besoin;
  final String produitThumb;
  final String progression;

  const _MockSollicitation({
    required this.id,
    required this.coopNom,
    required this.coopAvatar,
    required this.timing,
    required this.urgent,
    required this.besoin,
    required this.produitThumb,
    required this.progression,
  });
}

/// Liste mock alignée 1:1 avec `mockups/producteur/sollicitations_recues.html`.
const List<_MockSollicitation> _kMockSollicitations = [
  _MockSollicitation(
    id: 'sol-1',
    coopNom: 'COOP-AGRI Lagunes',
    coopAvatar: _kCoopAvatar,
    timing: 'Sollicitation reçue · il y a 2 h',
    urgent: true,
    besoin: 'Besoin de 500 kg de maïs blanc · max 7 jours · prix ≥ 800 F/kg',
    produitThumb: _kMaisThumb,
    progression:
        '3 / 8 farmers ont déjà répondu (1 200 kg engagés sur 5 000 kg)',
  ),
  _MockSollicitation(
    id: 'sol-2',
    coopNom: 'COOP-AGRI Lagunes',
    coopAvatar: _kCoopAvatar,
    timing: 'Sollicitation reçue · hier',
    urgent: false,
    besoin: 'Besoin de 300 kg de manioc · max 14 jours · prix ≥ 380 F/kg',
    produitThumb: _kManiocThumb,
    progression:
        '5 / 12 farmers ont déjà répondu (800 kg engagés sur 3 000 kg)',
  ),
];

/// Tente de récupérer les sollicitations depuis le backend, sinon
/// tombe sur les mocks (endpoint non encore branché côté producteur).
final _sollicitationsProvider =
    FutureProvider.autoDispose<List<_MockSollicitation>>((ref) async {
  try {
    final paginated =
        await ref.watch(cooperativesServiceProvider).listSollicitations();
    if (paginated.data.isEmpty) return _kMockSollicitations;
    return paginated.data.map(_sollicitationToMock).toList(growable: false);
  } catch (_) {
    return _kMockSollicitations;
  }
});

/// Convertit un `Sollicitation` backend en mock d'affichage. Les champs
/// riches non présents dans le modèle plat retombent sur des valeurs
/// neutres — l'UI reste cohérente, juste moins détaillée.
_MockSollicitation _sollicitationToMock(Sollicitation s) {
  final dejaRepondu = s.totalResponses;
  final total = s.totalRecipients;
  final quantite = s.quantiteCibleKg ?? 0;
  final offerte = s.totalQuantiteOfferte;
  return _MockSollicitation(
    id: s.id,
    coopNom: 'Ma coopérative',
    coopAvatar: _kCoopAvatar,
    timing: 'Sollicitation reçue',
    urgent: false,
    besoin: s.message ??
        'Besoin de ${quantite.toStringAsFixed(0)} kg · à honorer',
    produitThumb: _kMaisThumb,
    progression:
        '$dejaRepondu / $total farmers ont déjà répondu '
        '(${offerte.toStringAsFixed(0)} kg engagés sur '
        '${quantite.toStringAsFixed(0)} kg)',
  );
}

/// Liste des sollicitations reçues par le producteur de sa coopérative.
class SollicitationsRecuesPage extends ConsumerWidget {
  const SollicitationsRecuesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_sollicitationsProvider);

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
                error: (_, _) => _Body(items: _kMockSollicitations),
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
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sollicitations de ma coop ($count)',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Réponds pour participer',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Body ────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({required this.items});

  final List<_MockSollicitation> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _SolCard(sol: items[i]),
      ),
    );
  }
}

// ─── Carte sollicitation ─────────────────────────────────────────────────

class _SolCard extends StatelessWidget {
  const _SolCard({required this.sol});

  final _MockSollicitation sol;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card (avatar + nom coop + chip urgent)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    border: Border.all(
                      color: AppColors.border,
                      width: AppDimens.borderThin,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: CachedNetworkImage(
                    imageUrl: sol.coopAvatar,
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
                      sol.coopNom,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sol.timing,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (sol.urgent) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _kWarnSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Urgent',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _kWarn,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Besoin + vignette produit
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  sol.besoin,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    border: Border.all(
                      color: AppColors.border,
                      width: AppDimens.borderThin,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: CachedNetworkImage(
                    imageUrl: sol.produitThumb,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: AppColors.surfaceSoft),
                    errorWidget: (_, _, _) =>
                        Container(color: AppColors.surfaceSoft),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progression
          Text(
            sol.progression,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // Bouton mini primary à droite-bas
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => context.push(
                RouteNames.producteurSollicitationRepondrePathFor(sol.id),
              ),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary,
                    width: AppDimens.borderThin,
                  ),
                ),
                child: Text(
                  'Je peux fournir',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

