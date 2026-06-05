import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/coop_eligible_commande.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Couleurs / radius locaux ────────────────────────────────────────────
const Color _kPrimarySoft = Color(0xFFE8F5E9);
const double _kCardRadius = 14;

/// Provider de la liste des commandes coop éligibles à une demande de
/// transport (payées, sans shipment). Auto-dispose pour ne pas garder en
/// mémoire après navigation. Délègue à `CoopLogisticsService` qui gère
/// les endpoints + le parsing dans un seul endroit testable.
final _eligibleCommandesProvider =
    FutureProvider.autoDispose<List<CoopEligibleCommande>>((ref) async {
  return ref.read(coopLogisticsServiceProvider).listEligibleTransportCommandes();
});

/// Page « Demander un transport » côté coopérative : liste les commandes
/// payées sans shipment et permet d'en envoyer une demande de transport
/// (le backend notifie les transporteurs éligibles via leurs routes).
class TransportDemandePage extends ConsumerStatefulWidget {
  const TransportDemandePage({super.key});

  @override
  ConsumerState<TransportDemandePage> createState() =>
      _TransportDemandePageState();
}

class _TransportDemandePageState extends ConsumerState<TransportDemandePage> {
  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_eligibleCommandesProvider);
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
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message:
                        'Impossible de charger les commandes en attente. $e',
                    onRetry: () =>
                        ref.invalidate(_eligibleCommandesProvider),
                  ),
                ),
                data: (commandes) => _build(commandes),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build(List<CoopEligibleCommande> commandes) {
    if (commandes.isEmpty) return const _EmptyState();
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => ref.invalidate(_eligibleCommandesProvider),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pagePaddingH,
          AppDimens.space12,
          AppDimens.pagePaddingH,
          AppDimens.space24,
        ),
        itemCount: commandes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _CarteCommande(
          commande: commandes[i],
          onDemander: () => _openConfirmation(commandes[i]),
        ),
      ),
    );
  }

  Future<void> _openConfirmation(CoopEligibleCommande commande) async {
    final confirme = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SheetConfirmation(commande: commande),
    );
    if (confirme != true || !mounted) return;
    await _envoyerDemande(commande);
  }

  Future<void> _envoyerDemande(CoopEligibleCommande commande) async {
    try {
      await ref
          .read(coopLogisticsServiceProvider)
          .requestTransport(commandeId: commande.id);
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        'Demande envoyée — les transporteurs ont été notifiés.',
      );
      ref.invalidate(_eligibleCommandesProvider);
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, 'Erreur réseau. Réessaie.');
    }
  }
}

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
                : context.go(RouteNames.cooperativeLogistiquePath),
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
              'Demander un transport',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.pagePaddingH,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: _kPrimarySoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.local_shipping_outlined,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune commande en attente de transport',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tes ventes payées sans transporteur apparaîtront ici "
              "dès qu'un acheteur règle une commande.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte par commande dans la liste : produit + acheteur + qté + adresse
/// + bouton « Demander un transport ».
class _CarteCommande extends StatelessWidget {
  const _CarteCommande({
    required this.commande,
    required this.onDemander,
  });

  final CoopEligibleCommande commande;
  final VoidCallback onDemander;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      commande.produitNom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Réf. ${commande.reference}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _LigneInfo(
            icon: Icons.person_outline,
            label: 'Acheteur',
            value: commande.buyerName,
          ),
          const SizedBox(height: 6),
          _LigneInfo(
            icon: Icons.scale_outlined,
            label: 'Quantité',
            value: '${_fmtKg(commande.quantiteKg)} kg',
          ),
          const SizedBox(height: 6),
          _LigneInfo(
            icon: Icons.location_on_outlined,
            label: 'Livraison',
            value:
                (commande.deliveryAddress ?? '—').replaceAll('\n', ' ').trim(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onDemander,
              icon: const Icon(Icons.local_shipping_outlined, size: 18),
              label: const Text('Demander un transport'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LigneInfo extends StatelessWidget {
  const _LigneInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }
}

/// Sheet de confirmation : récap de la commande + bouton final « Lancer ».
class _SheetConfirmation extends StatelessWidget {
  const _SheetConfirmation({required this.commande});

  final CoopEligibleCommande commande;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space12,
        AppDimens.pagePaddingH,
        MediaQuery.of(context).padding.bottom + AppDimens.space16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Confirmer la demande de transport',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Les transporteurs dont la route correspond seront notifiés. "
            "Le premier qui accepte prend la mission.",
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(AppDimens.space12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(_kCardRadius),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commande.produitNom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                _LigneInfo(
                  icon: Icons.person_outline,
                  label: 'Acheteur',
                  value: commande.buyerName,
                ),
                const SizedBox(height: 6),
                _LigneInfo(
                  icon: Icons.scale_outlined,
                  label: 'Quantité',
                  value: '${_fmtKg(commande.quantiteKg)} kg',
                ),
                const SizedBox(height: 6),
                _LigneInfo(
                  icon: Icons.location_on_outlined,
                  label: 'Livraison',
                  value: (commande.deliveryAddress ?? '—')
                      .replaceAll('\n', ' ')
                      .trim(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Annuler',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Lancer la demande',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _fmtKg(double kg) {
  if (kg == kg.roundToDouble()) return kg.toInt().toString();
  return kg.toStringAsFixed(2);
}
