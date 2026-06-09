import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/annonce_vente.dart';
import '../../../../models/enums.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/cooperative/publications/bouton_sticky_publication.dart';
import '../../../widgets/cooperative/publications/champ_grand_publication.dart';
import '../../../widgets/cooperative/publications/champ_multiligne_publication.dart';
import '../../../widgets/cooperative/publications/chip_qualite_publication.dart';
import '../../../widgets/cooperative/publications/entete_publication_creer.dart';
import '../../../widgets/cooperative/publications/libelle_section_publication.dart';

/// Provider : annonces VALIDATED de la coop, prêtes à être agrégées en
/// publication. Filtre côté backend via `?status=VALIDATED`.
final _annoncesValideesProvider =
    FutureProvider.autoDispose<List<AnnonceVente>>((ref) async {
  return ref.read(cooperativesServiceProvider).listAssignedAnnoncesVente(
        coopStatus: CoopAnnonceStatus.validated,
      );
});

/// Création d'une publication coopérative — refonte 2026-06-06 alignée
/// sur le vrai workflow métier :
///
///   1. **Choix du produit** : la coop voit ses annonces VALIDATED
///      groupées par culture (= lots collectés disponibles)
///   2. **Sélection des annonces** du lot à publier (toutes par défaut,
///      sélection partielle possible)
///   3. **Confirmation** : qté/qualité pré-remplies depuis pesée + prix
///      + intervalle de récolte calculé + description optionnelle
///
/// Backend : `aggregatePublication(annonce_ids, prix, qualité, ...)`.
/// Avant cette refonte, le form demandait de saisir tout à la main
/// (produit, qté, qualité) sans lien avec les annonces collectées →
/// la traçabilité contributions ↔ publication était cassée.
class PublicationCreerPage extends ConsumerStatefulWidget {
  const PublicationCreerPage({super.key});

  @override
  ConsumerState<PublicationCreerPage> createState() =>
      _PublicationCreerPageState();
}

class _PublicationCreerPageState extends ConsumerState<PublicationCreerPage> {
  final _prixCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();

  /// Lot sélectionné (clé = produitId, valeur = liste des annonces).
  /// Construit après sélection du produit ; user peut cocher/décocher
  /// individuellement avant d'aller au step 2.
  String? _produitChoisiId;
  String? _produitChoisiNom;
  final Set<String> _annonceIdsSelectionnees = {};
  ProductQuality _qualiteOverride = ProductQuality.standard;
  bool _qualiteEditee = false;
  bool _busy = false;
  int _step = 1;

  static const _qualites = [
    ProductQuality.standard,
    ProductQuality.premium,
    ProductQuality.bio,
    ProductQuality.equitable,
  ];

  @override
  void dispose() {
    _prixCtrl.dispose();
    _descriptionCtrl.dispose();
    _adresseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePublicationCreer(),
            Expanded(child: _step == 1 ? _step1ChoixLot() : _step2Confirm()),
          ],
        ),
      ),
    );
  }

  // ─── STEP 1 : choix du lot (produit + annonces) ──────────────────

  Widget _step1ChoixLot() {
    final async = ref.watch(_annoncesValideesProvider);
    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          color: AppColors.primary,
        ),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Impossible de charger les annonces validées.\n$e',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
      data: (annonces) {
        if (annonces.isEmpty) return const _EtatAucunLot();
        // Groupe par produit : Map<produitId, (nom, liste)>
        final Map<String, List<AnnonceVente>> parProduit = {};
        for (final a in annonces) {
          parProduit.putIfAbsent(a.produitId, () => <AnnonceVente>[]).add(a);
        }
        final lots = parProduit.entries.toList()
          ..sort((a, b) => b.value.length.compareTo(a.value.length));

        // Si un produit a été choisi : montre ses annonces avec cases
        if (_produitChoisiId != null) {
          final annoncesLot = parProduit[_produitChoisiId] ?? [];
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.pagePaddingH,
                    AppDimens.space12,
                    AppDimens.pagePaddingH,
                    AppDimens.space16,
                  ),
                  children: [
                    _BandeauProduitChoisi(
                      nom: _produitChoisiNom ?? 'Produit',
                      onChange: () => setState(() {
                        _produitChoisiId = null;
                        _produitChoisiNom = null;
                        _annonceIdsSelectionnees.clear();
                      }),
                    ),
                    AppDimens.vGap16,
                    const LibelleSectionPublication(
                      label: 'Annonces à inclure dans le lot',
                    ),
                    AppDimens.vGap8,
                    for (final a in annoncesLot)
                      _CarteAnnonceCheckbox(
                        annonce: a,
                        coche: _annonceIdsSelectionnees.contains(a.id),
                        onTap: () => setState(() {
                          if (_annonceIdsSelectionnees.contains(a.id)) {
                            _annonceIdsSelectionnees.remove(a.id);
                          } else {
                            _annonceIdsSelectionnees.add(a.id);
                          }
                        }),
                      ),
                  ],
                ),
              ),
              BoutonStickyPublication(
                busy: false,
                onTap: _annonceIdsSelectionnees.isEmpty
                    ? () => Snackbars.showInfo(
                          context,
                          'Sélectionne au moins une annonce.',
                        )
                    : _passerAuStep2,
                label: _annonceIdsSelectionnees.isEmpty
                    ? 'Sélectionne au moins 1 annonce'
                    : 'Suivant · ${_annonceIdsSelectionnees.length} annonce(s)',
              ),
            ],
          );
        }

        // Sinon : liste des lots disponibles (1 carte par produit)
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.pagePaddingH,
            AppDimens.space12,
            AppDimens.pagePaddingH,
            AppDimens.space16,
          ),
          children: [
            const LibelleSectionPublication(
              label: 'Lots collectés prêts à publier',
            ),
            AppDimens.vGap8,
            Text(
              'Choisis le produit que tu veux mettre sur le marché. '
              'Tu pourras ajuster la sélection à l\'étape suivante.',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            AppDimens.vGap12,
            for (final entry in lots) ...[
              _CarteLotProduit(
                nom: entry.value.first.produitNom ?? 'Produit',
                nbAnnonces: entry.value.length,
                qteTotaleKg: _sommeValidee(entry.value),
                onTap: () => setState(() {
                  _produitChoisiId = entry.key;
                  _produitChoisiNom = entry.value.first.produitNom;
                  // Pré-coche TOUTES par défaut (cas le plus courant).
                  _annonceIdsSelectionnees
                    ..clear()
                    ..addAll(entry.value.map((a) => a.id));
                }),
              ),
              AppDimens.vGap12,
            ],
          ],
        );
      },
    );
  }

  // ─── STEP 2 : confirmation + prix + agrégation ────────────────────

  Widget _step2Confirm() {
    final async = ref.watch(_annoncesValideesProvider);
    final all = async.value ?? const <AnnonceVente>[];
    final lot = all
        .where((a) => _annonceIdsSelectionnees.contains(a.id))
        .toList(growable: false);
    final qte = _sommeValidee(lot);
    final qualiteAuto = _qualiteMajoritaire(lot);
    final qualiteActive = _qualiteEditee ? _qualiteOverride : qualiteAuto;
    final intervalle = _intervalleRecolte(lot);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.pagePaddingH,
              AppDimens.space12,
              AppDimens.pagePaddingH,
              AppDimens.space16,
            ),
            children: [
              _RecapLot(
                produitNom: _produitChoisiNom ?? 'Produit',
                nbAnnonces: lot.length,
                qteKg: qte,
                intervalleRecolte: intervalle,
                onRetour: () => setState(() => _step = 1),
              ),
              AppDimens.vGap24,
              const LibelleSectionPublication(label: 'Prix de vente par kg'),
              AppDimens.vGap8,
              ChampGrandPublication(
                controller: _prixCtrl,
                suffix: 'F CFA / kg',
                hint: 'Ex : 380',
                enabled: !_busy,
              ),
              AppDimens.vGap24,
              LibelleSectionPublication(
                label: _qualiteEditee
                    ? 'Qualité (modifiée)'
                    : 'Qualité (depuis la pesée)',
              ),
              AppDimens.vGap8,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_qualites.length, (i) {
                  final q = _qualites[i];
                  return ChipQualitePublication(
                    label: _qualiteLabel(q),
                    selected: qualiteActive == q,
                    onTap: () => setState(() {
                      _qualiteOverride = q;
                      _qualiteEditee = true;
                    }),
                  );
                }),
              ),
              AppDimens.vGap24,
              const LibelleSectionPublication(
                label: 'Adresse précise (optionnel)',
              ),
              AppDimens.vGap8,
              ChampGrandPublication(
                controller: _adresseCtrl,
                hint: 'Ex : Entrepôt principal Bouaké',
                suffix: '',
                enabled: !_busy,
              ),
              AppDimens.vGap24,
              const LibelleSectionPublication(
                label: 'Description (optionnel)',
              ),
              AppDimens.vGap8,
              ChampMultilignePublication(
                controller: _descriptionCtrl,
                enabled: !_busy,
                placeholder:
                    'Conditions de stockage, notes, etc.',
              ),
            ],
          ),
        ),
        BoutonStickyPublication(
          busy: _busy,
          onTap: () => _publier(lot, qualiteActive),
          label: 'Publier sur le marché',
        ),
      ],
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────

  void _passerAuStep2() {
    final async = ref.read(_annoncesValideesProvider).value;
    final lot = (async ?? [])
        .where((a) => _annonceIdsSelectionnees.contains(a.id))
        .toList(growable: false);
    setState(() {
      _qualiteOverride = _qualiteMajoritaire(lot);
      _qualiteEditee = false;
      _step = 2;
    });
  }

  Future<void> _publier(
    List<AnnonceVente> lot,
    ProductQuality qualite,
  ) async {
    if (_busy) return;
    final prix = double.tryParse(_prixCtrl.text.replaceAll(',', '.'));
    if (prix == null || prix <= 0) {
      Snackbars.showErreur(context, 'Prix au kg invalide.');
      return;
    }
    if (lot.isEmpty) {
      Snackbars.showErreur(context, 'Aucune annonce sélectionnée.');
      return;
    }
    // On hérite de la région/ville de la première annonce — la coop
    // ne peut publier que dans sa zone (vérifié backend de toute façon).
    final premier = lot.first;
    setState(() => _busy = true);
    try {
      await ref.read(cooperativesServiceProvider).aggregatePublication(
            annonceIds: lot.map((a) => a.id).toList(),
            prixParKg: prix,
            qualite: qualite,
            regionId: premier.regionId,
            villeId: premier.villeId,
            adresseDetail: _adresseCtrl.text.trim().isEmpty
                ? null
                : _adresseCtrl.text.trim(),
          );
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        'Publication créée — ${lot.length} annonce(s) agrégée(s).',
      );
      if (context.canPop()) {
        context.pop(true);
      }
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Somme des quantités validées du lot (kg). Fallback sur quantité
  /// déclarée si validée absente (cas pathologique : validation manuelle
  /// sans saisie qté réelle).
  double _sommeValidee(List<AnnonceVente> lot) {
    return lot.fold<double>(
      0,
      (sum, a) => sum + (a.quantiteKgValidee ?? a.quantiteKg),
    );
  }

  /// Qualité « majoritaire » du lot (la plus représentée). Si égalité,
  /// premier rencontré — c'est juste un défaut, la coop peut modifier.
  ProductQuality _qualiteMajoritaire(List<AnnonceVente> lot) {
    if (lot.isEmpty) return ProductQuality.standard;
    final counts = <ProductQuality, int>{};
    for (final a in lot) {
      final q = a.qualiteValidee ?? a.qualite;
      counts[q] = (counts[q] ?? 0) + 1;
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.first.key;
  }

  /// Intervalle de récolte du lot : (date min, date max) en string fr.
  /// Retourne null si aucune annonce n'a `dateRecolte`.
  String? _intervalleRecolte(List<AnnonceVente> lot) {
    final dates = lot
        .map((a) => a.dateRecolte)
        .whereType<DateTime>()
        .toList(growable: false);
    if (dates.isEmpty) return null;
    dates.sort();
    final fmt = DateFormat('d MMM', 'fr_FR');
    if (dates.first.difference(dates.last).inDays.abs() < 1) {
      return 'récolté le ${fmt.format(dates.first)}';
    }
    return 'récolté entre le ${fmt.format(dates.first)} '
        'et le ${fmt.format(dates.last)}';
  }
}

// ─── Widgets internes ────────────────────────────────────────────────

class _EtatAucunLot extends StatelessWidget {
  const _EtatAucunLot();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Aucun lot prêt à publier',
              style: AppTextStyles.titleLarge.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Pour publier, valide d\'abord les annonces de tes membres '
              'depuis l\'onglet « Stock → Réception ».',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CarteLotProduit extends StatelessWidget {
  const _CarteLotProduit({
    required this.nom,
    required this.nbAnnonces,
    required this.qteTotaleKg,
    required this.onTap,
  });

  final String nom;
  final int nbAnnonces;
  final double qteTotaleKg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.eco_outlined,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      nom,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$nbAnnonces annonce(s) · ${nf.format(qteTotaleKg.round())} kg disponibles',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSubtle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BandeauProduitChoisi extends StatelessWidget {
  const _BandeauProduitChoisi({required this.nom, required this.onChange});
  final String nom;
  final VoidCallback onChange;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.30),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      child: Row(
        children: [
          const Icon(Icons.eco_rounded, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              nom,
              style: AppTextStyles.bodyMedium.copyWith(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
          ),
          TextButton(
            onPressed: onChange,
            child: Text(
              'Changer',
              style: AppTextStyles.button.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarteAnnonceCheckbox extends StatelessWidget {
  const _CarteAnnonceCheckbox({
    required this.annonce,
    required this.coche,
    required this.onTap,
  });
  final AnnonceVente annonce;
  final bool coche;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    final qte = annonce.quantiteKgValidee ?? annonce.quantiteKg;
    final nomFarmer = annonce.vendeur?.fullName ?? 'Producteur';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: coche ? AppColors.primary.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: coche
                  ? AppColors.primary.withValues(alpha: 0.06)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: coche ? AppColors.primary : AppColors.border,
                width: coche ? 1.5 : 1,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              children: [
                Icon(
                  coche
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color:
                      coche ? AppColors.primary : AppColors.textSubtle,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        nomFarmer,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontFamily: 'Poppins',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${nf.format(qte.round())} kg pesés',
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
          ),
        ),
      ),
    );
  }
}

class _RecapLot extends StatelessWidget {
  const _RecapLot({
    required this.produitNom,
    required this.nbAnnonces,
    required this.qteKg,
    required this.intervalleRecolte,
    required this.onRetour,
  });
  final String produitNom;
  final int nbAnnonces;
  final double qteKg;
  final String? intervalleRecolte;
  final VoidCallback onRetour;
  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.10),
            AppColors.primary.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.30),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.inventory_2_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  produitNom,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ),
              TextButton(
                onPressed: onRetour,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                ),
                child: Text(
                  'Modifier',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${nf.format(qteKg.round())} kg agrégés · '
            '$nbAnnonces producteur(s)',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          if (intervalleRecolte != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.event_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  intervalleRecolte!,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

String _qualiteLabel(ProductQuality q) {
  switch (q) {
    case ProductQuality.premium:
      return 'Premium';
    case ProductQuality.bio:
      return 'Bio';
    case ProductQuality.equitable:
      return 'Équitable';
    case ProductQuality.standard:
    case ProductQuality.unknown:
      return 'Standard';
  }
}
