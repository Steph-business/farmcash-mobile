import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../models/annonce_vente.dart';
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

const String _kHeroPhotoFallback =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=800&h=450&fit=crop&auto=format';

// ─── Mock avis acheteurs ──────────────────────────────────────────────

class _MockAvis {
  const _MockAvis({
    required this.nom,
    required this.note,
    required this.commentaire,
    required this.avatarUrl,
  });
  final String nom;
  final int note;
  final String commentaire;
  final String avatarUrl;
}

const List<_MockAvis> _kAvis = [
  _MockAvis(
    nom: 'Marie Y.',
    note: 5,
    commentaire: 'Qualité top, livraison rapide, je recommande.',
    avatarUrl:
        'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200&h=200&fit=crop&auto=format',
  ),
  _MockAvis(
    nom: 'Restaurant Akwaba',
    note: 5,
    commentaire: 'Maïs très propre. Sera mon fournisseur régulier.',
    avatarUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop&auto=format',
  ),
  _MockAvis(
    nom: 'Coop Saveurs',
    note: 4,
    commentaire: 'Bon produit, juste un petit retard sur la livraison.',
    avatarUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop&auto=format',
  ),
];

const List<String> _kCaracs = [
  'Standard',
  'Bio',
  'Sans traitement',
  'Séché 5 jours',
];

// ─── Provider ────────────────────────────────────────────────────────

final _annonceAcheteurDetailProvider = FutureProvider.autoDispose
    .family<AnnonceVente?, String>((ref, id) async {
  try {
    return await ref.read(marketplaceServiceProvider).getAnnonceVente(id);
  } catch (_) {
    return null;
  }
});

/// Détail d'une annonce de vente côté ACHETEUR — hero + carousel dots,
/// titre/prix, vendeur (bouton Message seul), origine, caracs, avis,
/// sticky qty + commander.
class AnnonceDetailAcheteurPage extends ConsumerStatefulWidget {
  const AnnonceDetailAcheteurPage({required this.annonceId, super.key});

  final String annonceId;

  @override
  ConsumerState<AnnonceDetailAcheteurPage> createState() =>
      _AnnonceDetailAcheteurPageState();
}

class _AnnonceDetailAcheteurPageState
    extends ConsumerState<AnnonceDetailAcheteurPage> {
  int _qte = 500;
  final int _prixUnitaire = 350;

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
                    message: 'Impossible de charger l\'annonce.',
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

  Widget _buildContent(AnnonceVente? annonce) {
    final nom = annonce?.titre ?? 'Maïs blanc';
    final qteDispo = annonce?.quantiteKg.round() ?? 500;
    final prix =
        annonce?.prixParKg.round() ?? _prixUnitaire;
    final photo = (annonce?.photos.isNotEmpty ?? false)
        ? annonce!.photos.first
        : _kHeroPhotoFallback;
    final titreHeader = '$nom · ${_formatKg(qteDispo.toDouble())}';
    final montant = _qte * prix;

    return Column(
      children: [
        _Header(title: titreHeader),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              _Hero(photoUrl: photo),
              _TitleCard(nom: nom, prixParKg: prix, qteDispo: qteDispo),
              const _SectionVendeur(),
              const _SectionOrigine(),
              const _SectionCaracteristiques(),
              const _SectionAvis(),
            ],
          ),
        ),
        _StickyBottom(
          qte: _qte,
          montant: montant,
          maxQte: qteDispo,
          onMinus: () {
            if (_qte > 1) setState(() => _qte--);
          },
          onPlus: () {
            if (_qte < qteDispo) setState(() => _qte++);
          },
          onCommander: () {
            Snackbars.showInfo(
              context,
              'Commande à payer — ${_formatF(montant)}',
            );
            Navigator.of(context).maybePop();
          },
        ),
      ],
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
      decoration: const BoxDecoration(
        color: AppColors.background,
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

// ─── Hero photo + carousel dots ───────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.photoUrl});

  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: CachedNetworkImage(
            imageUrl: photoUrl,
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
              '1/3',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 3; i++) ...[
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == 0
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Title card ───────────────────────────────────────────────────────

class _TitleCard extends StatelessWidget {
  const _TitleCard({
    required this.nom,
    required this.prixParKg,
    required this.qteDispo,
  });

  final String nom;
  final int prixParKg;
  final int qteDispo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: AppDimens.borderThin),
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
                  'Standard',
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

// ─── Section vendeur (Yao K. + chip Coop + rating + bouton Message) ───

class _SectionVendeur extends StatelessWidget {
  const _SectionVendeur();

  @override
  Widget build(BuildContext context) {
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
            child: CachedNetworkImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=200&h=200&fit=crop&auto=format',
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
              errorWidget: (_, _, _) =>
                  Container(color: AppColors.surfaceSoft),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Yao K.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _kPrimarySoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Coop',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      '★',
                      style: TextStyle(color: _kWarn, fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '4.8 · 47 ventes',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () =>
                Snackbars.showInfo(context, 'Messagerie — à venir'),
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
                'Message',
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

// ─── Section origine ──────────────────────────────────────────────────

class _SectionOrigine extends StatelessWidget {
  const _SectionOrigine();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Origine',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      'Parcelle Yopougon',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Maïs blanc · Récolté le 8 mai',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Voir sur la carte',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
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

// ─── Section caractéristiques ─────────────────────────────────────────

class _SectionCaracteristiques extends StatelessWidget {
  const _SectionCaracteristiques();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Caractéristiques',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final c in _kCaracs)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Text(
                c,
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Section avis ─────────────────────────────────────────────────────

class _SectionAvis extends StatelessWidget {
  const _SectionAvis();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Avis (47)',
      child: Column(
        children: [
          for (var i = 0; i < _kAvis.length; i++)
            _AvisRow(avis: _kAvis[i], isLast: i == _kAvis.length - 1),
        ],
      ),
    );
  }
}

class _AvisRow extends StatelessWidget {
  const _AvisRow({required this.avis, required this.isLast});

  final _MockAvis avis;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            clipBehavior: Clip.hardEdge,
            child: CachedNetworkImage(
              imageUrl: avis.avatarUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
              errorWidget: (_, _, _) =>
                  Container(color: AppColors.surfaceSoft),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        avis.nom,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '★' * avis.note + '☆' * (5 - avis.note),
                      style: TextStyle(color: _kWarn, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  avis.commentaire,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    height: 1.4,
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

// ─── Sticky bottom (qty + commander) ──────────────────────────────────

class _StickyBottom extends StatelessWidget {
  const _StickyBottom({
    required this.qte,
    required this.montant,
    required this.maxQte,
    required this.onMinus,
    required this.onPlus,
    required this.onCommander,
  });

  final int qte;
  final int montant;
  final int maxQte;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onCommander;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  InkWell(
                    onTap: onMinus,
                    child: Container(
                      width: 36,
                      height: 44,
                      color: AppColors.surfaceSoft,
                      alignment: Alignment.center,
                      child: const Text(
                        '−',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 54,
                    height: 44,
                    alignment: Alignment.center,
                    child: Text(
                      '$qte',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onPlus,
                    child: Container(
                      width: 36,
                      height: 44,
                      color: AppColors.surfaceSoft,
                      alignment: Alignment.center,
                      child: const Text(
                        '+',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ),
                ],
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
                    'Commander (${_formatF(montant)})',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 14,
                      color: AppColors.onPrimary,
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
          bottom: BorderSide(color: AppColors.border, width: AppDimens.borderThin),
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

// ─── Helpers ───────────────────────────────────────────────────────────

final _nf = NumberFormat('#,##0', 'fr_FR');

String _formatKg(double kg) => '${_nf.format(kg.round())} kg';

String _formatF(int n) => '${_nf.format(n)} F';
