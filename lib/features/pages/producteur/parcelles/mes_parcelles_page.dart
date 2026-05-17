import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/parcelle.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/bouton_principal.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';

/// Liste des parcelles enregistrées par le farmer connecté.
///
/// Point d'entrée depuis le profil producteur ("Mes parcelles & cultures"),
/// indépendant du flow Publier. Empty state proactif si aucune parcelle.
final _mesParcellesProvider = FutureProvider.autoDispose<List<Parcelle>>(
  (ref) => ref.watch(marketplaceServiceProvider).listParcelles(),
);

class MesParcellesPage extends ConsumerStatefulWidget {
  const MesParcellesPage({super.key});

  @override
  ConsumerState<MesParcellesPage> createState() => _MesParcellesPageState();
}

class _MesParcellesPageState extends ConsumerState<MesParcellesPage> {
  Future<void> _ajouterParcelle() async {
    await context.push(RouteNames.producteurCreerParcellePath);
    if (!mounted) return;
    // Au retour du formulaire (créée ou annulée), on rafraîchit la liste.
    ref.invalidate(_mesParcellesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_mesParcellesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: AppDimens.iconL),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Mes parcelles',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: async.when(
          loading: () => const Padding(
            padding: EdgeInsets.only(top: AppDimens.space32),
            child: Chargement(size: 22),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(AppDimens.pagePaddingH),
            child: VueErreur(
              message: 'Impossible de charger tes parcelles.',
              onRetry: () => ref.invalidate(_mesParcellesProvider),
            ),
          ),
          data: (parcelles) => _Body(
            parcelles: parcelles,
            onAjouter: _ajouterParcelle,
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.parcelles, required this.onAjouter});

  final List<Parcelle> parcelles;
  final VoidCallback onAjouter;

  @override
  Widget build(BuildContext context) {
    if (parcelles.isEmpty) {
      return _EmptyState(onAjouter: onAjouter);
    }
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.pagePaddingH,
              AppDimens.space16,
              AppDimens.pagePaddingH,
              AppDimens.space16,
            ),
            itemCount: parcelles.length,
            separatorBuilder: (_, _) => AppDimens.vGap12,
            itemBuilder: (_, i) => _ParcelleCard(parcelle: parcelles[i]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.pagePaddingH,
            AppDimens.space8,
            AppDimens.pagePaddingH,
            AppDimens.space16,
          ),
          child: BoutonPrincipal(
            label: '+ Ajouter une parcelle',
            onPressed: onAjouter,
          ),
        ),
      ],
    );
  }
}

// ─── État vide ─────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAjouter});

  final VoidCallback onAjouter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.pagePaddingH),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.landscape_outlined,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            AppDimens.vGap16,
            Text(
              'Aucune parcelle enregistrée',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            AppDimens.vGap8,
            Text(
              'Ajoute ton premier champ pour pouvoir publier des annonces.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            AppDimens.vGap24,
            BoutonPrincipal(
              label: 'Ajouter une parcelle',
              onPressed: onAjouter,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Carte parcelle ────────────────────────────────────────────────────

class _ParcelleCard extends StatelessWidget {
  const _ParcelleCard({required this.parcelle});

  final Parcelle parcelle;

  @override
  Widget build(BuildContext context) {
    final ha = parcelle.superficieHa;
    final superficieTexte = ha != null
        ? '${ha.toStringAsFixed(1)} ha'
        : '? ha';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  parcelle.nom,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppDimens.hGap8,
              Text(
                superficieTexte,
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (parcelle.createdAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Créée le ${_formatDate(parcelle.createdAt!)}',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

/// Formate une date en `DD/MM/YYYY` (pas de dépendance locale requise).
String _formatDate(DateTime d) {
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  return '$dd/$mm/${d.year}';
}
