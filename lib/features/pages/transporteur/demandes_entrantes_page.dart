import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/livraison.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/vue_erreur.dart';

// ─── Couleurs locales ─────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(14));

/// Liste des missions disponibles (REQUESTED) matchant les routes du
/// transporteur. Cible `GET /logistics/missions/available`.
final _demandesProvider =
    FutureProvider.autoDispose<List<Livraison>>((ref) async {
  return ref.read(logisticsServiceProvider).getAvailableMissions();
});

/// Page « Demandes entrantes » — missions à accepter (1er arrivé, 1er servi).
class DemandesEntrantesTransporteurPage extends ConsumerWidget {
  const DemandesEntrantesTransporteurPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_demandesProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(title: 'Demandes entrantes'),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger les demandes. $e',
                    onRetry: () => ref.invalidate(_demandesProvider),
                  ),
                ),
                data: (demandes) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(_demandesProvider);
                    await ref.read(_demandesProvider.future);
                  },
                  child: demandes.isEmpty
                      ? const _EmptyState()
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            AppDimens.pagePaddingH,
                            12,
                            AppDimens.pagePaddingH,
                            AppDimens.space24,
                          ),
                          itemCount: demandes.length,
                          itemBuilder: (_, i) => _DemandeCard(
                            mission: demandes[i],
                            onTap: () => context.push(
                              RouteNames.transporteurDemandeDetailPathFor(
                                demandes[i].id,
                              ),
                            ),
                          ),
                        ),
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
  const _Header({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
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
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card demande ─────────────────────────────────────────────────────

class _DemandeCard extends StatelessWidget {
  const _DemandeCard({required this.mission, required this.onTap});
  final Livraison mission;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reference = mission.reference ??
        mission.commandeId.substring(0, 8).toUpperCase();
    final trajet = mission.itineraireLabel ?? '—';
    final qte = mission.quantiteKg != null
        ? '${_nf.format(mission.quantiteKg!.round())} kg'
        : null;
    final prix = mission.prixDevis ?? mission.prixFinal;
    final prixLabel =
        prix != null ? '+${_nf.format(prix.round())} F' : 'à fixer';
    final df = DateFormat('d MMM HH:mm', 'fr_FR');
    final dateLabel = mission.scheduledAt != null
        ? 'Pour ${df.format(mission.scheduledAt!)}'
        : (mission.createdAt != null
            ? 'Publié ${df.format(mission.createdAt!)}'
            : 'À planifier');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: _kBrCard,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: _kBrCard,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _kPrimarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.inbox_outlined,
                      size: 18,
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
                          'Commande #$reference',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          trajet,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.border,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (qte != null) ...[
                    const Icon(
                      Icons.scale_outlined,
                      size: 13,
                      color: AppColors.textSubtle,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      qte,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      dateLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ),
                  Text(
                    prixLabel,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 40,
                color: AppColors.textSubtle.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 12),
              Text(
                'Aucune demande en attente',
                style: AppTextStyles.titleSmall,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Les missions correspondant à tes itinéraires actifs apparaîtront ici.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final _nf = NumberFormat('#,##0', 'fr_FR');
