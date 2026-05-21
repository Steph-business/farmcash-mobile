import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/annonce_vente.dart';
import '../../../../models/commande.dart';
import '../../../../models/enums.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Constantes visuelles ─────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

// ─── Provider ─────────────────────────────────────────────────────────

/// Bundle commande + annonce associée pour avoir le nom du produit, la
/// photo et le vendeur sans dépendre d'un payload "dénormalisé" côté back.
class _CommandeBundle {
  const _CommandeBundle({required this.commande, this.annonce});
  final Commande commande;
  final AnnonceVente? annonce;
}

final _commandeBundleProvider = FutureProvider.autoDispose
    .family<_CommandeBundle, String>((ref, id) async {
  final orders = ref.read(ordersServiceProvider);
  final market = ref.read(marketplaceServiceProvider);
  final cmd = await orders.getOrder(id);
  AnnonceVente? annonce;
  try {
    annonce = await market.getAnnonceVente(cmd.annonceId);
  } catch (_) {
    // L'annonce peut avoir été dépubliée — on garde la commande seule.
  }
  return _CommandeBundle(commande: cmd, annonce: annonce);
});

/// Traçabilité publique du lot lié à la commande. `null` si le backend
/// renvoie 404 (commande non rattachée à un lot tracé). On distingue
/// "non disponible" de "vide" pour pouvoir afficher un message honnête.
final _commandeTracabiliteProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, lotId) async {
  try {
    return await ref.read(aiServiceProvider).getLotTraceability(lotId);
  } on ApiException catch (e) {
    if (e.type == ApiExceptionType.notFound) return null;
    rethrow;
  }
});

/// Détail d'une commande — vue acheteur. Charge la commande + l'annonce
/// associée et reconstruit le suivi à partir du statut backend.
class CommandeDetailAcheteurPage extends ConsumerStatefulWidget {
  const CommandeDetailAcheteurPage({required this.commandeId, super.key});

  final String commandeId;

  @override
  ConsumerState<CommandeDetailAcheteurPage> createState() =>
      _CommandeDetailAcheteurPageState();
}

class _CommandeDetailAcheteurPageState
    extends ConsumerState<CommandeDetailAcheteurPage> {
  bool _confirmingDelivery = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_commandeBundleProvider(widget.commandeId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              _Header(reference: ''),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const _Header(reference: ''),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la commande. $e',
                    onRetry: () => ref.invalidate(
                      _commandeBundleProvider(widget.commandeId),
                    ),
                  ),
                ),
              ),
            ],
          ),
          data: (bundle) => _build(bundle),
        ),
      ),
    );
  }

  Widget _build(_CommandeBundle bundle) {
    final c = bundle.commande;
    final ref0 = c.reference.isNotEmpty
        ? c.reference
        : c.id.substring(0, 8).toUpperCase();

    return Column(
      children: [
        _Header(reference: ref0),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _HeroPhoto(annonce: bundle.annonce),
              _TitleCard(commande: c, annonce: bundle.annonce),
              _VendorSection(annonce: bundle.annonce),
              _AmountsSection(commande: c),
              _SuiviSection(commande: c),
              // Section "Parcours du produit" — affichée seulement quand la
              // livraison a eu lieu (sinon l'event DELIVERED n'existe pas
              // encore dans la traçabilité backend).
              if (_parcoursVisible(c))
                _ParcoursSection(commande: c, annonce: bundle.annonce),
              _QrSection(commandeId: c.id),
              const SizedBox(height: 8),
            ],
          ),
        ),
        _StickyButtons(
          commande: c,
          busy: _confirmingDelivery,
          onConfirmerReception: () => _confirmerReception(c),
        ),
      ],
    );
  }

  Future<void> _confirmerReception(Commande c) async {
    if (_confirmingDelivery) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la réception ?'),
        content: const Text(
          'En confirmant, le paiement est libéré au vendeur. '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!mounted) return;
    setState(() => _confirmingDelivery = true);
    try {
      await ref.read(financeServiceProvider).confirmDelivery(commandeId: c.id);
      ref.invalidate(_commandeBundleProvider(widget.commandeId));
      if (!mounted) return;
      Snackbars.showSucces(context, 'Réception confirmée · escrow libéré');
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _confirmingDelivery = false);
    }
  }
}

// ─── Header ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.reference});
  final String reference;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
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
              reference.isEmpty ? 'Commande' : 'Commande #$reference',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero photo ───────────────────────────────────────────────────────

class _HeroPhoto extends StatelessWidget {
  const _HeroPhoto({required this.annonce});
  final AnnonceVente? annonce;

  @override
  Widget build(BuildContext context) {
    final photo = (annonce?.photos.isNotEmpty == true)
        ? annonce!.photos.first
        : null;
    return SizedBox(
      width: double.infinity,
      height: 160,
      child: photo != null
          ? CachedNetworkImage(
              imageUrl: photo,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
              errorWidget: (_, _, _) => Container(color: AppColors.surfaceSoft),
            )
          : Container(
              color: AppColors.surfaceSoft,
              alignment: Alignment.center,
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 48,
                color: AppColors.textSubtle,
              ),
            ),
    );
  }
}

// ─── Title card ───────────────────────────────────────────────────────

class _TitleCard extends StatelessWidget {
  const _TitleCard({required this.commande, required this.annonce});
  final Commande commande;
  final AnnonceVente? annonce;

  @override
  Widget build(BuildContext context) {
    final nom = annonce?.produitLabel ?? 'Commande';
    final qte = _nf.format(commande.quantiteKg.round());
    final loc = annonce?.localisationLabel;
    final df = DateFormat('d MMM', 'fr_FR');
    final passe = commande.createdAt != null
        ? 'Passée le ${df.format(commande.createdAt!)}'
        : null;
    final sousTitre = [
      if (loc != null) loc,
      if (passe != null) passe,
    ].join(' · ');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$qte kg $nom',
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          if (sousTitre.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              sousTitre,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Section vendeur ──────────────────────────────────────────────────

class _VendorSection extends StatelessWidget {
  const _VendorSection({required this.annonce});
  final AnnonceVente? annonce;

  @override
  Widget build(BuildContext context) {
    final nom = annonce?.vendeurNom ?? 'Vendeur';
    final rating = annonce?.vendeur?.rating;
    final photo = annonce?.vendeur?.photoUrl;
    return _Section(
      title: 'Vendeur',
      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
                shape: BoxShape.circle,
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
                        size: 22,
                        color: AppColors.primary,
                      ),
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
                  const SizedBox(height: 2),
                  Text(
                    '★ ${rating.toStringAsFixed(1)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          InkWell(
            onTap: () => Snackbars.showInfo(
              context,
              'Ouvrir la conversation — à venir',
            ),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary,
                  width: AppDimens.borderThin,
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section montants ─────────────────────────────────────────────────

class _AmountsSection extends StatelessWidget {
  const _AmountsSection({required this.commande});
  final Commande commande;

  @override
  Widget build(BuildContext context) {
    final total = _nf.format(commande.montantTotal.round());
    final qte = _nf.format(commande.quantiteKg.round());
    final prixUnit = _nf.format(commande.prixUnitaireKg.round());
    final statut = commande.escrowReleased
        ? 'Libéré au vendeur'
        : 'Bloqué en escrow · libéré à la confirmation de réception';
    return _Section(
      title: 'Montants',
      child: Container(
        decoration: BoxDecoration(
          color: _kPrimarySoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                commande.escrowReleased
                    ? Icons.lock_open_outlined
                    : Icons.lock_outline,
                size: 16,
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
                    'Total : $total F',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$qte kg × $prixUnit F/kg',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statut,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.text,
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

// ─── Suivi (timeline dérivée du statut) ─────────────────────────────

class _SuiviSection extends StatelessWidget {
  const _SuiviSection({required this.commande});
  final Commande commande;

  @override
  Widget build(BuildContext context) {
    final steps = _stepsFor(commande);
    return _Section(
      title: 'Suivi',
      child: Column(
        children: List.generate(steps.length, (i) {
          return _TimelineStep(step: steps[i], isLast: i == steps.length - 1);
        }),
      ),
    );
  }

  List<_Step> _stepsFor(Commande c) {
    // Position courante dans la séquence canonique.
    int currentIndex;
    switch (c.status) {
      case OrderStatus.sent:
        currentIndex = 1;
        break;
      case OrderStatus.accepted:
        currentIndex = 2;
        break;
      case OrderStatus.inProgress:
        currentIndex = 3;
        break;
      case OrderStatus.delivered:
        currentIndex = 4;
        break;
      case OrderStatus.completed:
        currentIndex = 5;
        break;
      case OrderStatus.cancelled:
      case OrderStatus.rejected:
      case OrderStatus.disputed:
      case OrderStatus.unknown:
        currentIndex = 1;
        break;
    }
    final df = DateFormat('d MMM · HH\'h\'mm', 'fr_FR');
    final createdLabel = c.createdAt != null ? df.format(c.createdAt!) : '—';
    final livraisonLabel = c.livraisonDate != null
        ? 'Prévu ${DateFormat('d MMM', 'fr_FR').format(c.livraisonDate!)}'
        : 'À planifier';
    final titles = [
      ('Commande passée', createdLabel),
      ('Paiement bloqué en escrow', createdLabel),
      ('Vendeur prépare l\'envoi', '—'),
      ('Transporteur en route', livraisonLabel),
      ('Livraison + scan de mon QR', 'En attente'),
      ('Réception confirmée', 'Escrow libéré'),
    ];
    return List.generate(titles.length, (i) {
      final kind = i < currentIndex ? _StepKind.done : _StepKind.wait;
      return _Step(
        kind: kind,
        titre: titles[i].$1,
        sousTitre: titles[i].$2,
      );
    });
  }
}

enum _StepKind { done, wait }

class _Step {
  const _Step({
    required this.kind,
    required this.titre,
    required this.sousTitre,
  });
  final _StepKind kind;
  final String titre;
  final String sousTitre;
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.step, required this.isLast});
  final _Step step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isWait = step.kind == _StepKind.wait;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!isLast)
                  Positioned(
                    top: 24,
                    bottom: -16,
                    child: Container(width: 2, color: AppColors.border),
                  ),
                _Dot(kind: step.kind),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    step.titre,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isWait ? AppColors.textSecondary : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    step.sousTitre,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
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

class _Dot extends StatelessWidget {
  const _Dot({required this.kind});
  final _StepKind kind;

  @override
  Widget build(BuildContext context) {
    if (kind == _StepKind.done) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.check, size: 12, color: Colors.white),
      );
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.schedule,
        size: 12,
        color: AppColors.textSecondary,
      ),
    );
  }
}

// ─── QR section ────────────────────────────────────────────────────

class _QrSection extends StatelessWidget {
  const _QrSection({required this.commandeId});
  final String commandeId;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Mon QR de réception',
      child: InkWell(
        onTap: () => context.push(
          RouteNames.acheteurLivraisonQrPathFor(commandeId),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _kPrimarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.qr_code_2,
                  size: 22,
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
                      'Afficher mon QR',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'À montrer au transporteur',
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
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section générique ────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ─── Sticky buttons ──────────────────────────────────────────────

class _StickyButtons extends StatelessWidget {
  const _StickyButtons({
    required this.commande,
    required this.busy,
    required this.onConfirmerReception,
  });

  final Commande commande;
  final bool busy;
  final VoidCallback onConfirmerReception;

  @override
  Widget build(BuildContext context) {
    // Le bouton "Confirmer réception" n'apparaît qu'en phase delivery/transit
    // et tant que l'escrow n'a pas été libéré.
    final showConfirm = !commande.escrowReleased &&
        (commande.status == OrderStatus.delivered ||
            commande.status == OrderStatus.inProgress);
    // "Évaluer le transport" : commande livrée OU complétée.
    final showEvaluation = commande.status == OrderStatus.delivered ||
        commande.status == OrderStatus.completed;
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        children: [
          if (showConfirm)
            SizedBox(
              width: double.infinity,
              child: InkWell(
                onTap: busy ? null : onConfirmerReception,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Confirmer la réception · libérer le paiement',
                          style: AppTextStyles.button.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onPrimary,
                          ),
                        ),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: InkWell(
                onTap: () => context.push(
                  RouteNames.acheteurLivraisonQrPathFor(commande.id),
                ),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Voir mon QR de réception',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          if (showEvaluation) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: InkWell(
                onTap: () => context.push(
                  RouteNames.acheteurCommandeEvaluationPathFor(commande.id),
                ),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primary,
                      width: AppDimens.borderThin,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Évaluer le transport',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

final _nf = NumberFormat('#,##0', 'fr_FR');

/// Visibilité de la section "Parcours du produit".
///
/// On l'affiche uniquement à partir de la livraison parce que c'est à ce
/// moment-là que la timeline backend contient assez d'événements pour être
/// intéressante (`HARVESTED`, `PICKED_UP`, `DELIVERED`). Avant, on tomberait
/// sur un parcours quasi-vide qui donnerait l'impression que c'est cassé.
bool _parcoursVisible(Commande c) =>
    c.status == OrderStatus.delivered || c.status == OrderStatus.completed;

// ─── Section "Parcours du produit" (traçabilité) ─────────────────────

/// Affiche le parcours complet du lot lié à la commande : du champ
/// (HARVESTED) jusqu'à la livraison (DELIVERED), via coop et transporteur.
/// Source : `GET /ai/traceability/:lotId` (public, scan QR friendly).
class _ParcoursSection extends ConsumerWidget {
  const _ParcoursSection({required this.commande, required this.annonce});
  final Commande commande;
  final AnnonceVente? annonce;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotId = commande.lotId;
    // Pas de fallback "annonce comme lot" : un lot_id absent veut dire que
    // la commande n'a pas été liée à un lot tracé → on l'écrit honnêtement.
    if (lotId == null || lotId.isEmpty) {
      return const _Section(
        title: 'Parcours du produit',
        child: _EmptyTracabilite(
          message: 'Traçabilité non disponible pour cette commande.',
        ),
      );
    }

    final async = ref.watch(_commandeTracabiliteProvider(lotId));
    return async.when(
      loading: () => const _Section(
        title: 'Parcours du produit',
        child: SizedBox(
          height: 60,
          child: Center(child: Chargement(size: 18)),
        ),
      ),
      error: (e, _) => _Section(
        title: 'Parcours du produit',
        child: _EmptyTracabilite(
          message: 'Impossible de charger la traçabilité. $e',
        ),
      ),
      data: (payload) {
        if (payload == null || payload.isEmpty) {
          return const _Section(
            title: 'Parcours du produit',
            child: _EmptyTracabilite(
              message: 'Traçabilité non disponible pour cette commande.',
            ),
          );
        }
        return _Section(
          title: 'Parcours du produit',
          child: _ParcoursContent(payload: payload, annonce: annonce),
        );
      },
    );
  }
}

class _EmptyTracabilite extends StatelessWidget {
  const _EmptyTracabilite({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
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
            Icons.info_outline,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParcoursContent extends StatelessWidget {
  const _ParcoursContent({required this.payload, required this.annonce});
  final Map<String, dynamic> payload;
  final AnnonceVente? annonce;

  @override
  Widget build(BuildContext context) {
    final lot = payload['lot'];
    final events = payload['events'];
    final eventsList = events is List ? events : const <dynamic>[];

    // En-tête : photo + nom farmer + lot_code + parcelle (région/ville)
    final lotCode = (lot is Map ? lot['lot_code'] : null) as String?;
    final produit = (lot is Map ? lot['produit'] : null) as String?;
    final farmerNom = annonce?.vendeurNom;
    final farmerPhoto = annonce?.vendeur?.photoUrl;
    final loc = annonce?.localisationLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête (carte légère, sobre)
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
            children: [
              ClipOval(
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: farmerPhoto != null && farmerPhoto.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: farmerPhoto,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(color: Colors.white),
                          errorWidget: (_, _, _) =>
                              Container(color: Colors.white),
                        )
                      : Container(
                          color: Colors.white,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.person_outline,
                            size: 20,
                            color: AppColors.primary,
                          ),
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
                      farmerNom ?? produit ?? 'Producteur',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (lotCode != null && lotCode.isNotEmpty)
                          'Lot $lotCode',
                        if (loc != null) loc,
                      ].join(' · '),
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Timeline verticale
        if (eventsList.isEmpty)
          const _EmptyTracabilite(
            message: 'Aucun événement enregistré pour ce lot.',
          )
        else
          Column(
            children: [
              for (var i = 0; i < eventsList.length; i++)
                _ParcoursStep(
                  raw: eventsList[i],
                  isLast: i == eventsList.length - 1,
                ),
            ],
          ),
      ],
    );
  }
}

class _ParcoursStep extends StatelessWidget {
  const _ParcoursStep({required this.raw, required this.isLast});
  final dynamic raw;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final m = raw is Map ? raw.cast<String, dynamic>() : const <String, dynamic>{};
    final type = m['type'] as String?;
    final dateStr = m['date'] as String?;
    final metadata = m['metadata'];
    final note = metadata is Map ? metadata['note'] as String? : null;
    final warehouse = metadata is Map ? metadata['warehouse'] as String? : null;
    final transporter =
        metadata is Map ? metadata['transporter'] as String? : null;

    final df = DateFormat('d MMM y · HH\'h\'mm', 'fr_FR');
    final dateLabel =
        (dateStr != null && dateStr.isNotEmpty)
            ? df.format(DateTime.parse(dateStr).toLocal())
            : '—';

    final title = _eventTitle(type);
    final icon = _eventIcon(type);
    final detail = [
      if (note != null && note.trim().isNotEmpty) note,
      if (warehouse != null && warehouse.trim().isNotEmpty) warehouse,
      if (transporter != null && transporter.trim().isNotEmpty)
        'Transporteur · $transporter',
    ].join(' · ');

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!isLast)
                  Positioned(
                    top: 24,
                    bottom: -14,
                    child: Container(width: 2, color: AppColors.border),
                  ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 12, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (detail.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _eventTitle(String? type) {
    switch (type) {
      case 'HARVESTED':
        return 'Récolte au champ';
      case 'DEPOSITED_AT_COOP':
        return 'Dépôt à la coopérative';
      case 'PICKED_UP':
        return 'Pris en charge par le transporteur';
      case 'IN_TRANSIT':
        return 'En cours d\'acheminement';
      case 'DELIVERED':
        return 'Livré à l\'acheteur';
      case 'CREATED':
        return 'Lot créé';
      default:
        // Fallback honnête : on affiche le type brut plutôt qu'un libellé
        // bidon. Permet de débugger les nouveaux event_type côté back.
        return type ?? 'Événement';
    }
  }

  IconData _eventIcon(String? type) {
    switch (type) {
      case 'HARVESTED':
        return Icons.agriculture_outlined;
      case 'DEPOSITED_AT_COOP':
        return Icons.warehouse_outlined;
      case 'PICKED_UP':
      case 'IN_TRANSIT':
        return Icons.local_shipping_outlined;
      case 'DELIVERED':
        return Icons.check;
      case 'CREATED':
        return Icons.qr_code_2;
      default:
        return Icons.circle;
    }
  }
}
