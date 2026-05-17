import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../models/commande.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Couleurs accent (escrow warn = #FFF3E0 / #FFCC80 / #E65100) ─────────

const Color _kEscrowBg = Color(0xFFFFF3E0);
const Color _kEscrowBorder = Color(0xFFFFCC80);
const Color _kEscrowFg = Color(0xFFE65100);
const Color _kWarnSoftStep = Color(0xFFFFF8E1);
const Color _kWarnStepFg = Color(0xFFB26A00);

const String _kHeroPhoto =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=300&h=300&fit=crop&auto=format';
const String _kBuyerAvatar =
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop&auto=format';

/// Détail d'une commande côté producteur — hero produit, acheteur, montants,
/// statut escrow (encart orange), timeline 5 étapes, sticky 2 boutons.
///
/// L'écran est conçu pour rester fidèle à la maquette HTML même sans
/// données backend : on charge la commande via `ordersService.getOrder(id)`
/// si possible, mais les valeurs visibles (qte, prix, montants, statuts
/// timeline) restent calées sur la commande C-2026-0089 du mock.
final _commandeProvider = FutureProvider.autoDispose
    .family<Commande?, String>((ref, id) async {
  try {
    return await ref.watch(ordersServiceProvider).getOrder(id);
  } catch (_) {
    // Mock fallback : on retourne null et l'UI tombe sur les valeurs
    // visuelles statiques de la maquette.
    return null;
  }
});

class CommandeDetailPage extends ConsumerWidget {
  const CommandeDetailPage({required this.commandeId, super.key});

  final String commandeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_commandeProvider(commandeId));

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(commandeId: commandeId),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => const _Body(commande: null),
                data: (commande) => _Body(commande: commande),
              ),
            ),
            const _StickyButtons(),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.commandeId});

  final String commandeId;

  @override
  Widget build(BuildContext context) {
    final ref = commandeId.startsWith('C-') ? commandeId : 'C-2026-0089';
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
              'Commande #$ref',
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

// ─── Body ───────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({required this.commande});

  final Commande? commande;

  @override
  Widget build(BuildContext context) {
    // Mock-first : on garde les valeurs visuelles de la maquette quand
    // l'API n'a pas répondu, ou quand certains champs ne sont pas remplis.
    final qte = commande != null && commande!.quantiteKg > 0
        ? commande!.quantiteKg
        : 500.0;
    final prixKg = commande != null && commande!.prixUnitaireKg > 0
        ? commande!.prixUnitaireKg
        : 350.0;
    final brut = qte * prixKg;
    final frais = (brut * 0.03).round().toDouble();
    final net = brut - frais;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      children: [
        const _HeroCard(),
        AppDimens.vGap12,
        const _BuyerSection(),
        AppDimens.vGap12,
        _AmountsSection(brut: brut, frais: frais, net: net, qte: qte, prixKg: prixKg),
        AppDimens.vGap16,
        _EscrowBanner(net: net),
        AppDimens.vGap16,
        _TimelineSection(net: net),
      ],
    );
  }
}

// ─── Hero card (photo + titre) ───────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 80,
              height: 80,
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
                imageUrl: _kHeroPhoto,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(color: AppColors.surfaceSoft),
                errorWidget: (_, _, _) =>
                    Container(color: AppColors.surfaceSoft),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '500 kg de Maïs grain blanc',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'qualité Standard',
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

// ─── Buyer section ───────────────────────────────────────────────────────

class _BuyerSection extends StatelessWidget {
  const _BuyerSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Acheteur',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: Container(
                  width: 48,
                  height: 48,
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
                    imageUrl: _kBuyerAvatar,
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
                      'Restaurant Le B.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Cocody',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _SharedBadge(),
                  ],
                ),
              ),
            ],
          ),
          AppDimens.vGap12,
          // Bouton « Message » seul (PAS d'« Appeler » — anti-contournement).
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () => Snackbars.showInfo(
                context,
                'Ouvrir la conversation — à venir',
              ),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary,
                    width: AppDimens.borderThin,
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Message',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SharedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Text(
        'Coordonnées partagées avec le transporteur uniquement',
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ─── Amounts ────────────────────────────────────────────────────────────

class _AmountsSection extends StatelessWidget {
  const _AmountsSection({
    required this.brut,
    required this.frais,
    required this.net,
    required this.qte,
    required this.prixKg,
  });

  final double brut;
  final double frais;
  final double net;
  final double qte;
  final double prixKg;

  @override
  Widget build(BuildContext context) {
    final qteLabel = qte.toStringAsFixed(0);
    final prixLabel = prixKg.toStringAsFixed(0);
    return _Section(
      title: 'Montants',
      child: Column(
        children: [
          _Row(
            l: 'Quantité × Prix : $qteLabel kg × $prixLabel F',
            v: '${_fmt(brut)} F',
            isLast: false,
          ),
          _Row(
            l: 'Frais plateforme (3%)',
            v: '-${_fmt(frais)} F',
            isLast: false,
          ),
          _Row(
            l: 'Total net à recevoir',
            v: '${_fmt(net)} F',
            isLast: true,
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.l,
    required this.v,
    required this.isLast,
    this.isTotal = false,
  });

  final String l;
  final String v;
  final bool isLast;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: isTotal ? 14 : 10, bottom: 10),
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
          Expanded(
            child: Text(
              l,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: isTotal ? AppColors.text : AppColors.textSecondary,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            v,
            style: isTotal
                ? AppTextStyles.displayLarge.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: -0.2,
                  )
                : AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Encart escrow ───────────────────────────────────────────────────────

class _EscrowBanner extends StatelessWidget {
  const _EscrowBanner({required this.net});

  final double net;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kEscrowBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kEscrowBorder, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: _kEscrowFg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.lock_outline,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_fmt(net)} F en escrow',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kEscrowFg,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Le paiement est bloqué chez FarmCash. Tu seras crédité '
                  'automatiquement dès que le transporteur prendra le colis.',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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

// ─── Timeline ────────────────────────────────────────────────────────────

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.net});

  final double net;

  @override
  Widget build(BuildContext context) {
    final steps = <_Step>[
      _Step(
        kind: _StepKind.done,
        label: '1',
        titre: 'Commande passée',
        sousTitre: 'Restaurant Le B. · 10 mai',
      ),
      _Step(
        kind: _StepKind.done,
        label: '2',
        titre: 'Paiement bloqué en escrow',
        sousTitre: '175 000 F sécurisés · 10 mai',
      ),
      _Step(
        kind: _StepKind.pending,
        label: '3',
        titre: 'Préparation du colis',
        sousTitre: 'À ton tour — marque expédié quand prêt',
      ),
      _Step(
        kind: _StepKind.todo,
        label: '4',
        titre: 'Enlèvement par le transporteur',
        sousTitre: '→ Tu recevras ${_fmt(net)} F à cette étape',
        highlightSousTitre: true,
      ),
      _Step(
        kind: _StepKind.todo,
        label: '5',
        titre: 'Livraison à l\'acheteur',
        sousTitre: 'Le transporteur reçoit alors sa commission',
      ),
    ];
    return _Section(
      title: 'Suivi de la commande',
      child: Column(
        children: List.generate(steps.length, (i) {
          return _TimelineStep(step: steps[i], isLast: i == steps.length - 1);
        }),
      ),
    );
  }
}

enum _StepKind { done, pending, todo }

class _Step {
  final _StepKind kind;
  final String label;
  final String titre;
  final String sousTitre;
  final bool highlightSousTitre;

  const _Step({
    required this.kind,
    required this.label,
    required this.titre,
    required this.sousTitre,
    // ignore: unused_element_parameter
    this.highlightSousTitre = false,
  });
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.step, required this.isLast});

  final _Step step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
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
                    child: Container(
                      width: 1,
                      color: AppColors.border,
                    ),
                  ),
                _Dot(kind: step.kind, label: step.label),
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
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.sousTitre,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: step.highlightSousTitre
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: step.highlightSousTitre
                          ? FontWeight.w600
                          : FontWeight.w400,
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
  const _Dot({required this.kind, required this.label});

  final _StepKind kind;
  final String label;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color border;
    late final Color fg;
    Widget? content;
    switch (kind) {
      case _StepKind.done:
        bg = AppColors.primary;
        border = AppColors.primary;
        fg = Colors.white;
        content = const Icon(Icons.check, size: 12, color: Colors.white);
      case _StepKind.pending:
        bg = _kWarnSoftStep;
        border = _kWarnSoftStep;
        fg = _kWarnStepFg;
      case _StepKind.todo:
        bg = AppColors.surfaceSoft;
        border = AppColors.border;
        fg = AppColors.textSubtle;
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: AppDimens.borderThin),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: content ??
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
    );
  }
}

// ─── Section générique ──────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ─── Sticky 2 boutons ────────────────────────────────────────────────────

class _StickyButtons extends StatelessWidget {
  const _StickyButtons();

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
              onTap: () => Snackbars.showInfo(
                context,
                'Ouvrir la conversation — à venir',
              ),
              borderRadius: AppDimens.brButton,
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppDimens.brButton,
                  border: Border.all(
                    color: AppColors.primary,
                    width: AppDimens.borderThin,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Voir la conversation',
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
              onTap: () => Snackbars.showInfo(
                context,
                'Marquer comme expédiée — à venir',
              ),
              borderRadius: AppDimens.brButton,
              child: Container(
                height: 46,
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
                  'Marquer comme expédiée',
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
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────

String _fmt(double v) => NumberFormat('#,##0', 'fr_FR').format(v);

// Conserve l'import pour usage futur si on veut afficher un état d'erreur
// dédié plutôt que tomber sur les mocks.
@visibleForTesting
Widget commandeErrorView(VoidCallback onRetry) => Padding(
      padding: const EdgeInsets.all(AppDimens.pagePaddingH),
      child: VueErreur(
        message: 'Impossible de charger la commande.',
        onRetry: onRetry,
      ),
    );
