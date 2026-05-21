import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/annonce_vente.dart';
import '../../../../models/enums.dart';
import '../../../../models/negociation.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Couleurs accent (conformes au mockup) ───────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

const String _kHeroPhotoFallback =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=600&h=400&fit=crop&auto=format';

/// Provider familial : récupère une annonce de vente par id.
final _annonceDetailProvider = FutureProvider.autoDispose
    .family<AnnonceVente, String>((ref, id) async {
  return ref.watch(marketplaceServiceProvider).getAnnonceVente(id);
});

/// Provider familial : candidatures reçues sur l'annonce (filtre côté
/// client sur `annonceId` car l'endpoint backend retourne toutes les
/// candidatures incoming du farmer connecté).
final _candidaturesProvider = FutureProvider.autoDispose
    .family<List<Candidature>, String>((ref, annonceId) async {
  final svc = ref.watch(negotiationServiceProvider);
  final all = await svc.listCandidatures(direction: 'incoming');
  return all.where((c) => c.annonceId == annonceId).toList(growable: false);
});

/// Détail d'une annonce de vente côté producteur — hero, KPIs, caracs,
/// acheteurs intéressés, sticky bouton.
class AnnonceDetailPage extends ConsumerWidget {
  const AnnonceDetailPage({required this.annonceId, super.key});

  final String annonceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_annonceDetailProvider(annonceId));

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              _Header(),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const _Header(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger l\'annonce.',
                    onRetry: () =>
                        ref.invalidate(_annonceDetailProvider(annonceId)),
                  ),
                ),
              ),
            ],
          ),
          data: (annonce) => _Content(annonce: annonce),
        ),
      ),
    );
  }
}

// ─── Actions sur l'annonce ───────────────────────────────────────────────

Future<void> _confirmAndPause(
  BuildContext context,
  WidgetRef ref,
  AnnonceVente annonce,
) async {
  final paused = annonce.status == ProductStatus.paused;
  final newStatus = paused ? ProductStatus.active : ProductStatus.paused;
  final label = paused ? 'Réactiver' : 'Mettre en pause';
  try {
    await ref
        .read(marketplaceServiceProvider)
        .updateAnnonceVente(annonce.id, status: newStatus);
    if (!context.mounted) return;
    ref.invalidate(_annonceDetailProvider(annonce.id));
    Snackbars.showSucces(
      context,
      paused ? 'Annonce réactivée.' : 'Annonce mise en pause.',
    );
  } on ApiException catch (e) {
    if (!context.mounted) return;
    Snackbars.showErreur(context, e.message);
  } catch (_) {
    if (!context.mounted) return;
    Snackbars.showErreur(context, 'Impossible de $label cette annonce.');
  }
}

Future<void> _confirmAndDelete(
  BuildContext context,
  WidgetRef ref,
  AnnonceVente annonce,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Supprimer cette annonce ?'),
      content: const Text(
        'Cette action est définitive. Les acheteurs ne pourront plus la voir.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            'Supprimer',
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  try {
    await ref
        .read(marketplaceServiceProvider)
        .deleteAnnonceVente(annonce.id);
    if (!context.mounted) return;
    Snackbars.showSucces(context, 'Annonce supprimée.');
    Navigator.of(context).pop(true);
  } on ApiException catch (e) {
    if (!context.mounted) return;
    Snackbars.showErreur(context, e.message);
  } catch (_) {
    if (!context.mounted) return;
    Snackbars.showErreur(context, 'Impossible de supprimer l\'annonce.');
  }
}

// ─── Header (fond blanc, border-bottom) ──────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    this.onEdit,
    this.editIcon = Icons.edit_outlined,
    this.editTooltip,
  });

  final VoidCallback? onEdit;
  final IconData editIcon;
  final String? editTooltip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
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
              'Mon annonce',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onEdit != null)
            Tooltip(
              message: editTooltip ?? 'Action',
              child: InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    editIcon,
                    size: 20,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Contenu ─────────────────────────────────────────────────────────────

class _Content extends ConsumerWidget {
  const _Content({required this.annonce});

  final AnnonceVente annonce;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidaturesAsync =
        ref.watch(_candidaturesProvider(annonce.id));
    final candidatures = candidaturesAsync.maybeWhen(
      data: (list) => list,
      orElse: () => const <Candidature>[],
    );

    return Column(
      children: [
        _Header(
          onEdit: () => _confirmAndDelete(context, ref, annonce),
          editIcon: Icons.delete_outline,
          editTooltip: 'Supprimer',
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              _Hero(annonce: annonce),
              _KpiRow(
                vues: annonce.viewsCount,
                messages: candidatures.length,
                commandes: candidatures
                    .where((c) => c.status == NegotiationStatus.accepted)
                    .length,
              ),
              _SectionCaracteristiques(annonce: annonce),
              _SectionAcheteursInteresses(
                async: candidaturesAsync,
                onRetry: () =>
                    ref.invalidate(_candidaturesProvider(annonce.id)),
                onRepondre: (c) =>
                    context.push(RouteNames.producteurMessagesPath),
              ),
            ],
          ),
        ),
        _StickyButtons(
          paused: annonce.status == ProductStatus.paused,
          onPause: () => _confirmAndPause(context, ref, annonce),
          onModifier: () => Snackbars.showInfo(
            context,
            'Édition — à venir',
          ),
        ),
      ],
    );
  }
}

// ─── Hero ────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.annonce});

  final AnnonceVente annonce;

  @override
  Widget build(BuildContext context) {
    final photoUrl = annonce.photos.isNotEmpty
        ? annonce.photos.first
        : _kHeroPhotoFallback;
    final titreComplet = _titreComplet(annonce);

    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
              errorWidget: (_, _, _) =>
                  Container(color: AppColors.surfaceSoft),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titreComplet,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                _ChipStatut(status: annonce.status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _titreComplet(AnnonceVente a) {
    final qualite = _qualiteLabel(a.qualite);
    if (qualite == null) return a.titre;
    if (a.titre.toLowerCase().contains(qualite.toLowerCase())) return a.titre;
    return '${a.titre} — qualité $qualite';
  }
}

class _ChipStatut extends StatelessWidget {
  const _ChipStatut({required this.status});

  final ProductStatus status;

  @override
  Widget build(BuildContext context) {
    final label = _statusLabel(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── KPI row 3 colonnes ──────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  const _KpiRow({
    required this.vues,
    required this.messages,
    required this.commandes,
  });

  final int vues;
  final int messages;
  final int commandes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
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
          Expanded(child: _KpiCol(value: vues.toString(), label: 'Vues')),
          const _Divider(),
          Expanded(child: _KpiCol(value: messages.toString(), label: 'Messages')),
          const _Divider(),
          Expanded(
            child: _KpiCol(value: commandes.toString(), label: 'Commandes'),
          ),
        ],
      ),
    );
  }
}

class _KpiCol extends StatelessWidget {
  const _KpiCol({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimens.borderThin,
      height: 32,
      color: AppColors.border,
    );
  }
}

// ─── Section caractéristiques ────────────────────────────────────────────

class _SectionCaracteristiques extends StatelessWidget {
  const _SectionCaracteristiques({required this.annonce});

  final AnnonceVente annonce;

  @override
  Widget build(BuildContext context) {
    final qte = NumberFormat('#,##0', 'fr_FR').format(annonce.quantiteKg);
    final prix = NumberFormat('#,##0', 'fr_FR').format(annonce.prixParKg);
    final dispoDate = annonce.disponibleJusqu;
    final dispoTexte = dispoDate == null
        ? 'Immédiate'
        : 'Jusqu\'au ${DateFormat('d MMM y', 'fr_FR').format(dispoDate)}';

    return _SectionCard(
      title: 'Caractéristiques',
      children: [
        _Feat(label: 'Produit', value: annonce.titre),
        _Feat(label: 'Qualité', value: _qualiteLabel(annonce.qualite) ?? '—'),
        _Feat(label: 'Quantité', value: '$qte kg'),
        _Feat(label: 'Prix', value: '$prix F/kg'),
        _Feat(label: 'Date dispo', value: dispoTexte),
        _Feat(label: 'Parcelle source', value: 'Parcelle Nord (4 ha)'),
      ],
    );
  }
}

class _Feat extends StatelessWidget {
  const _Feat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section "Mes propositions" (candidatures incoming) ──────────────────

class _SectionAcheteursInteresses extends StatelessWidget {
  const _SectionAcheteursInteresses({
    required this.async,
    required this.onRetry,
    required this.onRepondre,
  });

  final AsyncValue<List<Candidature>> async;
  final VoidCallback onRetry;
  final ValueChanged<Candidature> onRepondre;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Mes propositions',
      children: [
        async.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Chargement(size: 18),
          ),
          error: (_, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Impossible de charger les propositions.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onRetry,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
          data: (list) {
            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Aucune proposition pour l\'instant.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (var i = 0; i < list.length; i++)
                  _BuyerRow(
                    candidature: list[i],
                    isLast: i == list.length - 1,
                    onRepondre: () => onRepondre(list[i]),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _BuyerRow extends StatelessWidget {
  const _BuyerRow({
    required this.candidature,
    required this.isLast,
    required this.onRepondre,
  });

  final Candidature candidature;
  final bool isLast;
  final VoidCallback onRepondre;

  @override
  Widget build(BuildContext context) {
    final qte =
        NumberFormat('#,##0', 'fr_FR').format(candidature.quantiteKg);
    final prix =
        NumberFormat('#,##0', 'fr_FR').format(candidature.prixProposeKg);
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
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.person_outline,
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
                  'Acheteur ${_short(candidature.buyerId)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$qte kg · $prix F/kg · ${_statusLabelNeg(candidature.status)}',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onRepondre,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Text(
                'Répondre',
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

  String _short(String uuid) =>
      uuid.length >= 6 ? uuid.substring(0, 6) : uuid;
}

String _statusLabelNeg(NegotiationStatus s) {
  switch (s) {
    case NegotiationStatus.pending:
      return 'En attente';
    case NegotiationStatus.accepted:
      return 'Accepté';
    case NegotiationStatus.rejected:
      return 'Refusé';
    case NegotiationStatus.counterOffered:
      return 'Contre-offre';
    case NegotiationStatus.cancelled:
      return 'Annulé';
    case NegotiationStatus.unknown:
      return '—';
  }
}

// ─── Sticky bouttons ─────────────────────────────────────────────────────

class _StickyButtons extends StatelessWidget {
  const _StickyButtons({
    required this.paused,
    required this.onPause,
    required this.onModifier,
  });

  final bool paused;
  final VoidCallback onPause;
  final VoidCallback onModifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onPause,
              borderRadius: AppDimens.brButton,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppDimens.brButton,
                  border: Border.all(
                    color: AppColors.border,
                    width: AppDimens.borderThin,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  paused ? 'Réactiver' : 'Mettre en pause',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 14,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: onModifier,
              borderRadius: AppDimens.brButton,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppDimens.brButton,
                  border: Border.all(
                    color: AppColors.primary,
                    width: AppDimens.borderThin,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Modifier',
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
    );
  }
}

// ─── Carte section générique (titre uppercase + children) ────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              title.toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────

String _statusLabel(ProductStatus s) {
  switch (s) {
    case ProductStatus.active:
      return 'Active';
    case ProductStatus.paused:
      return 'En pause';
    case ProductStatus.sold:
      return 'Vendue';
    case ProductStatus.draft:
      return 'Brouillon';
    case ProductStatus.expired:
      return 'Expirée';
    case ProductStatus.unknown:
      return 'Active';
  }
}

String? _qualiteLabel(ProductQuality q) {
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
      return null;
  }
}
