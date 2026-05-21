import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/annonce_vente.dart';
import '../../../../models/enums.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Constantes ───────────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarn = Color(0xFFF9A825);

// ─── Provider ────────────────────────────────────────────────────────

final _annonceAcheteurDetailProvider = FutureProvider.autoDispose
    .family<AnnonceVente, String>((ref, id) async {
  return ref.read(marketplaceServiceProvider).getAnnonceVente(id);
});

/// Détail d'une annonce de vente côté ACHETEUR. Toutes les données
/// proviennent de `GET /marketplace/annonces/vente/:id`.
class AnnonceDetailAcheteurPage extends ConsumerStatefulWidget {
  const AnnonceDetailAcheteurPage({required this.annonceId, super.key});

  final String annonceId;

  @override
  ConsumerState<AnnonceDetailAcheteurPage> createState() =>
      _AnnonceDetailAcheteurPageState();
}

class _AnnonceDetailAcheteurPageState
    extends ConsumerState<AnnonceDetailAcheteurPage> {
  /// Quantité courante. Initialisée à la quantité minimale (ou à 1 si pas
  /// défini) à la première reception du détail.
  int? _qte;

  /// État du bouton "Ajouter au panier".
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_annonceAcheteurDetailProvider(widget.annonceId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              _Header(title: 'Chargement…'),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const _Header(title: 'Annonce'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger l\'annonce. $e',
                    onRetry: () => ref.invalidate(
                      _annonceAcheteurDetailProvider(widget.annonceId),
                    ),
                  ),
                ),
              ),
            ],
          ),
          data: (annonce) => _buildContent(annonce),
        ),
      ),
    );
  }

  Widget _buildContent(AnnonceVente annonce) {
    final qteDispo = annonce.quantiteKg.round();
    final qteMin = (annonce.quantiteMinKg ?? 1).round().clamp(1, qteDispo);
    _qte ??= qteMin;
    final qte = _qte!.clamp(qteMin, qteDispo);
    final prix = annonce.prixParKg.round();
    final montant = qte * prix;

    final nom = annonce.produitLabel;
    final titreHeader = '$nom · ${_formatKg(qteDispo.toDouble())}';

    return Column(
      children: [
        _Header(title: titreHeader),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              _Hero(photos: annonce.photos),
              _TitleCard(
                nom: nom,
                prixParKg: prix,
                qteDispo: qteDispo,
                qualite: annonce.qualite,
              ),
              _SectionVendeur(annonce: annonce),
              _SectionOrigine(annonce: annonce),
              // Section traçabilité : argument premium "from-farm-to-fork".
              // Affichée systématiquement — y compris quand aucun traitement
              // n'est déclaré (= signal positif "production naturelle").
              _SectionTracabilite(traitements: annonce.traitements),
              if (annonce.description != null &&
                  annonce.description!.trim().isNotEmpty)
                _SectionDescription(description: annonce.description!),
              _SectionInfos(annonce: annonce, qteMinKg: qteMin),
              if (annonce.certifications.isNotEmpty)
                _SectionCertifications(certifications: annonce.certifications),
            ],
          ),
        ),
        _StickyBottom(
          qte: qte,
          montant: montant,
          maxQte: qteDispo,
          minQte: qteMin,
          busy: _busy,
          onMinus: () => setState(() {
            if (_qte != null && _qte! > qteMin) _qte = _qte! - 1;
          }),
          onPlus: () => setState(() {
            if (_qte != null && _qte! < qteDispo) _qte = _qte! + 1;
          }),
          onAjouterPanier: () => _ajouterAuPanier(annonce, qte),
          onCommander: () => _commander(annonce, qte),
        ),
      ],
    );
  }

  Future<void> _ajouterAuPanier(AnnonceVente annonce, int qte) async {
    if (_busy) return;
    setState(() => _busy = true);
    final svc = ref.read(marketplaceServiceProvider);
    try {
      await svc.addToPanier(
        annonceId: annonce.id,
        quantiteKg: qte.toDouble(),
      );
      if (!mounted) return;
      Snackbars.showSucces(context, '$qte kg ajouté au panier');
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _commander(AnnonceVente annonce, int qte) async {
    // Le paiement reprend l'annonce + la quantité courante via le contexte
    // de la page paiement (qui re-fetch l'annonce + recalcule). Pour cette
    // V1, on passe par `acheteurPaiementCommandePathFor(annonceId)` et la
    // page paiement saura quoi faire.
    context.push(
      RouteNames.acheteurPaiementCommandePathFor(annonce.id),
      extra: {'quantiteKg': qte},
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
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: const BoxDecoration(color: AppColors.background),
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
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              Icons.favorite_border,
              size: 22,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero photo + carrousel ───────────────────────────────────────────

class _Hero extends StatefulWidget {
  const _Hero({required this.photos});
  final List<String> photos;

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> {
  final _pageCtrl = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    if (photos.isEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: AppColors.surfaceSoft,
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_outlined,
            size: 48,
            color: AppColors.textSubtle,
          ),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageCtrl,
            itemCount: photos.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => CachedNetworkImage(
              imageUrl: photos[i],
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
              errorWidget: (_, _, _) => Container(color: AppColors.surfaceSoft),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${_index + 1}/${photos.length}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (photos.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < photos.length; i++)
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
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

// ─── Title card ───────────────────────────────────────────────────────

class _TitleCard extends StatelessWidget {
  const _TitleCard({
    required this.nom,
    required this.prixParKg,
    required this.qteDispo,
    required this.qualite,
  });

  final String nom;
  final int prixParKg;
  final int qteDispo;
  final ProductQuality qualite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nom,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _kPrimarySoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kPrimarySoft),
                ),
                child: Text(
                  _qualiteLabel(qualite),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_nf.format(prixParKg)} F/kg',
            style: AppTextStyles.displaySmall.copyWith(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${_nf.format(qteDispo)} kg disponibles',
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

// ─── Section vendeur ────────────────────────────────────────────────

class _SectionVendeur extends StatelessWidget {
  const _SectionVendeur({required this.annonce});
  final AnnonceVente annonce;

  @override
  Widget build(BuildContext context) {
    final nom = annonce.vendeurNom ?? 'Vendeur';
    final rating = annonce.vendeur?.rating;
    final photo = annonce.vendeur?.photoUrl;
    final farmerId = annonce.vendeur?.id ?? annonce.farmerId;

    return _Section(
      title: 'Vendeur',
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: photo != null && photo.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: photo,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: AppColors.surfaceSoft),
                    errorWidget: (_, _, _) =>
                        Container(color: AppColors.surfaceSoft),
                  )
                : Container(
                    color: _kPrimarySoft,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.person_outline,
                      size: 24,
                      color: AppColors.primary,
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
                  nom,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (rating != null) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Text(
                        '★',
                        style: TextStyle(color: _kWarn, fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => context.push(
                RouteNames.acheteurVendeurDetailPathFor(farmerId)),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Text(
                'Voir profil',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
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

// ─── Section origine (localisation) ─────────────────────────────────

class _SectionOrigine extends StatelessWidget {
  const _SectionOrigine({required this.annonce});
  final AnnonceVente annonce;

  @override
  Widget build(BuildContext context) {
    final loc = annonce.localisationLabel ?? 'Localisation non précisée';
    final adresse = annonce.adresseDetail;

    return _Section(
      title: 'Origine',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.location_on_outlined,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (adresse != null && adresse.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    adresse,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section traçabilité (origine + traitements) ────────────────────

/// Liste les traitements phytosanitaires déclarés par le producteur.
/// Toujours visible : si la liste est vide, on affiche un message positif
/// "Aucun traitement déclaré — production naturelle" (signal pour l'acheteur).
class _SectionTracabilite extends StatelessWidget {
  const _SectionTracabilite({required this.traitements});
  final List<AnnonceTraitement> traitements;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Traçabilité',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Origine et traitements appliqués',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          if (traitements.isEmpty)
            // Empty state honnête : pas de mock, pas de bla-bla. Le manque
            // d'info devient une info en soi pour l'acheteur.
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _kPrimarySoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.eco_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Aucun traitement déclaré — production naturelle',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                for (var i = 0; i < traitements.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i == traitements.length - 1 ? 0 : 10,
                    ),
                    child: _TraitementTile(t: traitements[i]),
                  ),
              ],
            ),
          const SizedBox(height: 10),
          Text(
            'Données fournies par le producteur',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              color: AppColors.textSubtle,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tuile pour un traitement : icône selon type, nom, méta (type · dosage ·
/// date) et chip "Délai carence" si respecté.
class _TraitementTile extends StatelessWidget {
  const _TraitementTile({required this.t});
  final AnnonceTraitement t;

  @override
  Widget build(BuildContext context) {
    final isBio = _isBio(t.type);
    final df = DateFormat('d MMM y', 'fr_FR');
    final nom = t.produitTraitementNom?.trim().isNotEmpty == true
        ? t.produitTraitementNom!
        : 'Traitement';

    // Métadonnées concaténées par "·" (omises si vides) pour rester sobre.
    final metaParts = <String>[
      if (t.type != null && t.type!.trim().isNotEmpty) _typeLabel(t.type!),
      if (t.dosageUtilise != null && t.dosageUtilise!.trim().isNotEmpty)
        t.dosageUtilise!,
      if (t.dateApplication != null) df.format(t.dateApplication!),
    ];
    final meta = metaParts.join(' · ');

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(
              isBio ? Icons.eco_outlined : Icons.science_outlined,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nom,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (t.delaiCarenceRespecte == true) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _kPrimarySoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Délai carence respecté',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isBio(String? type) {
    if (type == null) return false;
    final t = type.toUpperCase();
    return t == 'BIO' || t == 'NATUREL' || t == 'ORGANIC';
  }

  String _typeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'BIO':
        return 'Bio';
      case 'CHIMIQUE':
        return 'Chimique';
      case 'NATUREL':
        return 'Naturel';
      case 'ORGANIQUE':
      case 'ORGANIC':
        return 'Organique';
      default:
        return type;
    }
  }
}

// ─── Section description ─────────────────────────────────────────────

class _SectionDescription extends StatelessWidget {
  const _SectionDescription({required this.description});
  final String description;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Description',
      child: Text(
        description,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 13,
          color: AppColors.text,
          height: 1.5,
        ),
      ),
    );
  }
}

// ─── Section infos (dates, quantités) ───────────────────────────────

class _SectionInfos extends StatelessWidget {
  const _SectionInfos({required this.annonce, required this.qteMinKg});
  final AnnonceVente annonce;
  final int qteMinKg;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMMM y', 'fr_FR');
    final publie = annonce.createdAt;
    final dispo = annonce.disponibleJusqu;

    return _Section(
      title: 'Informations',
      child: Column(
        children: [
          _InfoRow(
            label: 'Quantité min. à commander',
            value: '${_nf.format(qteMinKg)} kg',
          ),
          if (publie != null)
            _InfoRow(
              label: 'Publié le',
              value: df.format(publie),
            ),
          if (dispo != null)
            _InfoRow(
              label: 'Disponible jusqu\'au',
              value: df.format(dispo),
            ),
          _InfoRow(
            label: 'Vues',
            value: '${annonce.viewsCount}',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section certifications ─────────────────────────────────────────

class _SectionCertifications extends StatelessWidget {
  const _SectionCertifications({required this.certifications});
  final List<String> certifications;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Certifications',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final c in certifications)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _kPrimarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                c,
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Wrapper section ──────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              title.toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: AppColors.text,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

// ─── Sticky bottom : quantité + ajouter / commander ───────────────────

class _StickyBottom extends StatelessWidget {
  const _StickyBottom({
    required this.qte,
    required this.montant,
    required this.maxQte,
    required this.minQte,
    required this.busy,
    required this.onMinus,
    required this.onPlus,
    required this.onAjouterPanier,
    required this.onCommander,
  });

  final int qte;
  final int montant;
  final int maxQte;
  final int minQte;
  final bool busy;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onAjouterPanier;
  final VoidCallback onCommander;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Quantité : ',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.border,
                      width: AppDimens.borderThin,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      _StepBtn(
                          label: '−', onTap: qte > minQte ? onMinus : null),
                      Container(
                        width: 60,
                        alignment: Alignment.center,
                        child: Text(
                          '$qte kg',
                          style: AppTextStyles.titleSmall.copyWith(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _StepBtn(
                          label: '+', onTap: qte < maxQte ? onPlus : null),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${_nf.format(montant)} F',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: busy ? null : onAjouterPanier,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primary,
                          width: AppDimens.borderThin,
                        ),
                      ),
                      child: busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : Text(
                              'Ajouter au panier',
                              style: AppTextStyles.button.copyWith(
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: onCommander,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Commander',
                        style: AppTextStyles.button.copyWith(
                          fontSize: 13,
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        color: AppColors.surfaceSoft,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: enabled ? AppColors.text : AppColors.textSubtle,
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ───────────────────────────────────────────────────────────

final _nf = NumberFormat('#,##0', 'fr_FR');

String _formatKg(double kg) => '${_nf.format(kg.round())} kg';

String _qualiteLabel(ProductQuality q) {
  switch (q) {
    case ProductQuality.standard:
      return 'Standard';
    case ProductQuality.premium:
      return 'Premium';
    case ProductQuality.bio:
      return 'Bio';
    case ProductQuality.equitable:
      return 'Équitable';
    case ProductQuality.unknown:
      return '—';
  }
}
