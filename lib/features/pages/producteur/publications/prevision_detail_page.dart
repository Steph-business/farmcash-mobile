import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/enums.dart';
import '../../../../models/prevision.dart';
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
const Color _kWarnSoft = Color(0xFFFFF8E1);
const Color _kWarn = Color(0xFFB26A00);

const String _kHeroPhotoFallback =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=600&h=400&fit=crop&auto=format';

/// Provider familial. Comme `MarketplaceService.getPrevision(id)` n'existe
/// pas dans la version actuelle du service, on liste tout puis on filtre
/// côté client.
final _previsionDetailProvider = FutureProvider.autoDispose
    .family<Prevision?, String>((ref, id) async {
  final list = await ref.read(marketplaceServiceProvider).listPrevisions();
  return list.where((e) => e.id == id).firstOrNull;
});

/// Détail d'une prévision producteur — hero, info card, progression
/// réservations, liste réservants, actions, sticky bouton désactivé.
class PrevisionDetailPage extends ConsumerWidget {
  const PrevisionDetailPage({required this.previsionId, super.key});

  final String previsionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_previsionDetailProvider(previsionId));

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
          error: (_, _) => Column(
            children: [
              const _Header(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la prévision.',
                    onRetry: () =>
                        ref.invalidate(_previsionDetailProvider(previsionId)),
                  ),
                ),
              ),
            ],
          ),
          data: (prevision) {
            if (prevision == null) {
              return Column(
                children: [
                  const _Header(),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                        child: Text(
                          'Cette prévision n\'existe plus.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return _Content(prevision: prevision);
          },
        ),
      ),
    );
  }
}

// ─── Header (fond blanc, border-bottom) ──────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

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
              'Ma prévision',
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

// ─── Contenu ─────────────────────────────────────────────────────────────

class _Content extends ConsumerWidget {
  const _Content({required this.prevision});

  final Prevision prevision;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convertible = _isConvertible(prevision);
    final reasonNonConvertible = _whyNotConvertible(prevision);
    return Column(
      children: [
        const _Header(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 130),
            children: [
              _Hero(prevision: prevision),
              const _InfoCard(),
              _SectionActions(
                disabled: prevision.status != PrevisionStatus.open,
                onModifierDate: () => Snackbars.showInfo(
                  context,
                  'Modifier la date — à venir',
                ),
                onAnnuler: () => Snackbars.showInfo(
                  context,
                  'Annulation — à venir',
                ),
              ),
            ],
          ),
        ),
        _StickyConvertir(
          enabled: convertible,
          subtitle: reasonNonConvertible,
          onConvertir: () => _convertirPrevision(context, ref, prevision),
        ),
      ],
    );
  }
}

bool _isConvertible(Prevision p) {
  if (p.status != PrevisionStatus.open) return false;
  final date = p.dateRecoltePrev;
  if (date == null) return true; // pas de date → on autorise tout de suite
  // On considère convertible à partir de 5 jours avant la date prévue.
  final threshold = date.subtract(const Duration(days: 5));
  return DateTime.now().isAfter(threshold);
}

String? _whyNotConvertible(Prevision p) {
  if (p.status == PrevisionStatus.converted) {
    return 'Déjà convertie en annonce';
  }
  if (p.status == PrevisionStatus.cancelled) return 'Prévision annulée';
  if (p.status == PrevisionStatus.expired) return 'Prévision expirée';
  final date = p.dateRecoltePrev;
  if (date == null) return null;
  final threshold = date.subtract(const Duration(days: 5));
  if (DateTime.now().isBefore(threshold)) {
    return 'Disponible à partir du '
        '${DateFormat('d MMM', 'fr_FR').format(threshold)}';
  }
  return null;
}

Future<void> _convertirPrevision(
  BuildContext context,
  WidgetRef ref,
  Prevision prevision,
) async {
  final ctrl = TextEditingController(
    text: prevision.prixCibleKg != null
        ? prevision.prixCibleKg!.toStringAsFixed(0)
        : '',
  );
  final prix = await showDialog<double>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Convertir en annonce'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Indique le prix de vente définitif. '
            'L\'annonce passera ACTIVE immédiatement.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
            decoration: const InputDecoration(
              hintText: 'Ex: 800',
              suffixText: 'F/kg',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            final v = double.tryParse(ctrl.text.trim());
            Navigator.of(ctx).pop(v);
          },
          child: const Text('Convertir'),
        ),
      ],
    ),
  );
  if (prix == null || prix <= 0 || !context.mounted) return;

  try {
    final annonce = await ref
        .read(marketplaceServiceProvider)
        .convertPrevision(prevision.id, prixParKg: prix);
    if (!context.mounted) return;
    Snackbars.showSucces(context, 'Prévision convertie en annonce.');
    ref.invalidate(_previsionDetailProvider(prevision.id));
    context.push(
      RouteNames.producteurAnnonceDetailPathFor(annonce.id),
    );
  } on ApiException catch (e) {
    if (!context.mounted) return;
    Snackbars.showErreur(context, e.message);
  } catch (_) {
    if (!context.mounted) return;
    Snackbars.showErreur(context, 'Impossible de convertir la prévision.');
  }
}

// ─── Hero ────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.prevision});

  final Prevision prevision;

  @override
  Widget build(BuildContext context) {
    final qte = NumberFormat('#,##0', 'fr_FR').format(prevision.quantitePrevKg);
    final date = prevision.dateRecoltePrev != null
        ? DateFormat('d MMM y', 'fr_FR').format(prevision.dateRecoltePrev!)
        : null;
    final titre = date != null
        ? 'Récolte prévue · $qte kg · $date'
        : 'Récolte prévue · $qte kg';

    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl: _kHeroPhotoFallback,
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
                  titre,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                _ChipPrevision(prevision: prevision),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipPrevision extends StatelessWidget {
  const _ChipPrevision({required this.prevision});

  final Prevision prevision;

  @override
  Widget build(BuildContext context) {
    final date = prevision.dateRecoltePrev;
    String label = 'Prévision';
    if (date != null) {
      final diff = date.difference(DateTime.now()).inDays;
      if (diff > 0) {
        label = 'Prévision · J-$diff';
      } else if (diff == 0) {
        label = 'Prévision · Aujourd\'hui';
      } else {
        label = 'Prévision · échue';
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _kWarnSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _kWarn,
        ),
      ),
    );
  }
}

// ─── Info card (notif "Tu seras notifié …") ──────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.info_outline,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tu seras notifié 5 jours avant la date prévue. '
              'Tu pourras alors convertir cette prévision en annonce de vente '
              'au prix de ton choix.',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.text,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Actions (boutons outline plein largeur) ─────────────────────

class _SectionActions extends StatelessWidget {
  const _SectionActions({
    required this.disabled,
    required this.onModifierDate,
    required this.onAnnuler,
  });

  final bool disabled;
  final VoidCallback onModifierDate;
  final VoidCallback onAnnuler;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Actions',
      children: [
        Opacity(
          opacity: disabled ? 0.4 : 1,
          child: _ActionButton(
            icon: Icons.calendar_today_outlined,
            label: 'Modifier la date de récolte',
            variant: _ActionVariant.outlineGreen,
            onTap: disabled ? () {} : onModifierDate,
          ),
        ),
        const SizedBox(height: 10),
        Opacity(
          opacity: disabled ? 0.4 : 1,
          child: _ActionButton(
            icon: Icons.cancel_outlined,
            label: 'Annuler la prévision (remboursement automatique)',
            variant: _ActionVariant.outlineGrey,
            onTap: disabled ? () {} : onAnnuler,
          ),
        ),
      ],
    );
  }
}

enum _ActionVariant { outlineGreen, outlineGrey }

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.variant,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final _ActionVariant variant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isGreen = variant == _ActionVariant.outlineGreen;
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.brButton,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppDimens.brButton,
          border: Border.all(
            color: isGreen ? AppColors.primary : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppDimens.iconM,
              color: isGreen ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.button.copyWith(
                  fontSize: 14,
                  color: isGreen ? AppColors.primary : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sticky bottom : bouton désactivé "Convertir maintenant" ─────────────

class _StickyConvertir extends StatelessWidget {
  const _StickyConvertir({
    required this.enabled,
    required this.onConvertir,
    this.subtitle,
  });

  final bool enabled;
  final VoidCallback onConvertir;
  final String? subtitle;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: enabled ? 1 : 0.5,
            child: InkWell(
              onTap: enabled ? onConvertir : null,
              borderRadius: AppDimens.brButton,
              child: Container(
                width: double.infinity,
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
                  'Convertir maintenant',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 14,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Carte section générique ─────────────────────────────────────────────

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
