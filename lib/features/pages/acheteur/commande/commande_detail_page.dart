import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/commande.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/snackbars.dart';

// ─── Constantes visuelles (calées sur la maquette HTML) ────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

const String _kHeroPhoto =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=800&h=400&fit=crop&auto=format';
const String _kVendorAvatar =
    'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=200&h=200&fit=crop&auto=format';

/// Tente de charger la commande backend pour personnaliser la référence.
/// Tombe sur les valeurs mock de la maquette en cas d'erreur.
final _commandeProvider = FutureProvider.autoDispose
    .family<Commande?, String>((ref, id) async {
  try {
    return await ref.watch(ordersServiceProvider).getOrder(id);
  } catch (_) {
    return null;
  }
});

/// Détail d'une commande — vue acheteur.
/// Calque sur `mockups/acheteur/commande_detail.html`.
class CommandeDetailAcheteurPage extends ConsumerWidget {
  const CommandeDetailAcheteurPage({required this.commandeId, super.key});

  final String commandeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_commandeProvider(commandeId));
    final ref0 = async.maybeWhen(
      data: (c) => c?.reference.isNotEmpty == true ? c!.reference : 'C-2026-0089',
      orElse: () => commandeId.startsWith('C-') ? commandeId : 'C-2026-0089',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(reference: ref0),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const _HeroPhoto(),
                  const _TitleCard(),
                  const _VendorSection(),
                  const _AmountsSection(),
                  const _SuiviSection(),
                  _QrSection(commandeId: commandeId),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            _StickyButtons(commandeId: commandeId),
          ],
        ),
      ),
    );
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
              'Commande #$reference',
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
  const _HeroPhoto();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 160,
      child: CachedNetworkImage(
        imageUrl: _kHeroPhoto,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
        errorWidget: (_, _, _) => Container(color: AppColors.surfaceSoft),
      ),
    );
  }
}

// ─── Title card (titre produit + sous-titre) ──────────────────────────

class _TitleCard extends StatelessWidget {
  const _TitleCard();

  @override
  Widget build(BuildContext context) {
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
            '500 kg Maïs blanc',
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Standard · Récolté le 8 mai · Yopougon',
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

// ─── Vendor section (avatar + nom tronqué + bouton « Message » SEUL) ──

class _VendorSection extends StatelessWidget {
  const _VendorSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Vendeur',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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
                  child: CachedNetworkImage(
                    imageUrl: _kVendorAvatar,
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
                      'Yao K.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Producteur · 4.8 ★ · 47 ventes',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Bouton « Message » SEUL (pas « Appeler » — anti-contournement).
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
          const SizedBox(height: 10),
          _SharedBadge(),
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
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
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

// ─── Amounts section (card primary-soft) ───────────────────────────────

class _AmountsSection extends StatelessWidget {
  const _AmountsSection();

  @override
  Widget build(BuildContext context) {
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
              child: const Icon(
                Icons.lock_outline,
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
                    'Total payé : 175 000 F',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bloqué en escrow · libéré à la livraison',
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

// ─── Suivi (timeline 5 étapes) ─────────────────────────────────────────

class _SuiviSection extends StatelessWidget {
  const _SuiviSection();

  @override
  Widget build(BuildContext context) {
    final steps = const [
      _Step(
        kind: _StepKind.done,
        titre: 'Commande passée',
        sousTitre: '10 mai · 14h22',
      ),
      _Step(
        kind: _StepKind.done,
        titre: 'Paiement bloqué en escrow',
        sousTitre: '10 mai · 14h24',
      ),
      _Step(
        kind: _StepKind.done,
        titre: 'Producteur a marqué expédié',
        sousTitre: '14 mai · 09h10',
      ),
      _Step(
        kind: _StepKind.wait,
        titre: 'Transporteur en route',
        sousTitre: 'ETA 16 mai · 14h',
      ),
      _Step(
        kind: _StepKind.wait,
        titre: 'Livraison + scan de mon QR',
        sousTitre: 'En attente',
      ),
    ];

    return _Section(
      title: 'Suivi',
      child: Column(
        children: List.generate(steps.length, (i) {
          return _TimelineStep(step: steps[i], isLast: i == steps.length - 1);
        }),
      ),
    );
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
                    child: Container(
                      width: 2,
                      color: AppColors.border,
                    ),
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
      child: const Text('⏳', style: TextStyle(fontSize: 11)),
    );
  }
}

// ─── QR section (bouton vers livraison_qr_page) ────────────────────────

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

// ─── Section générique (titre + child) ────────────────────────────────

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

// ─── Sticky buttons (2 boutons verticaux) ──────────────────────────────

class _StickyButtons extends StatelessWidget {
  const _StickyButtons({required this.commandeId});

  final String commandeId;

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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () => context.push(
                RouteNames.acheteurLivraisonQrPathFor(commandeId),
              ),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary,
                    width: AppDimens.borderThin,
                  ),
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
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () => Snackbars.showInfo(
                context,
                'Ouvrir la conversation — à venir',
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
                  'Voir la conversation',
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
      ),
    );
  }
}

