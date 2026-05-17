import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../models/commande.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/snackbars.dart';

// ─── Couleurs accent (conformes au mockup) ───────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

const String _kFallbackTraceSlug = 'c89-mb500';
const String _kFallbackCommandeRef = 'C-2026-0089';
const String _kHeroPhoto =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=600&h=300&fit=crop&auto=format';

/// Provider familial : essaie de charger la commande pour personnaliser
/// le slug/ref affichés. Tombe sur les valeurs mock si l'API renvoie une
/// erreur — l'écran reste fidèle à la maquette dans tous les cas.
final _commandeProvider = FutureProvider.autoDispose
    .family<Commande?, String>((ref, id) async {
  try {
    return await ref.watch(ordersServiceProvider).getOrder(id);
  } catch (_) {
    return null;
  }
});

/// Écran final d'une commande livrée — confirmation hero + QR de
/// traçabilité produit (scanné par tout acheteur/revendeur/contrôleur).
class CommandeTermineePage extends ConsumerWidget {
  const CommandeTermineePage({required this.commandeId, super.key});

  final String commandeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCommande = ref.watch(_commandeProvider(commandeId));
    final commandeRef = asyncCommande.maybeWhen(
      data: (c) => c?.reference.isNotEmpty == true
          ? c!.reference
          : _kFallbackCommandeRef,
      orElse: () => _kFallbackCommandeRef,
    );
    final traceUrl = 'farmcash.ci/t/$_kFallbackTraceSlug';
    final qrPayload = 'https://$traceUrl';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                children: [
                  const _Hero(),
                  AppDimens.vGap16,
                  _QrCard(
                    payload: qrPayload,
                    commandeRef: commandeRef,
                    traceUrl: traceUrl,
                  ),
                  AppDimens.vGap16,
                  const _TraceCard(),
                  AppDimens.vGap16,
                  const _RecapCard(),
                ],
              ),
            ),
            _StickyActions(commandeId: commandeId),
          ],
        ),
      ),
    );
  }
}

// ─── Header : pas de back arrow, X à droite ──────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space16,
        AppDimens.space8,
        AppDimens.space16,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          const SizedBox(width: 40),
          Expanded(
            child: Center(
              child: Text(
                'Commande livrée',
                style: AppTextStyles.titleSmall.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.close,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero (check vert + titres) ──────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 20),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check,
              size: 44,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Livraison confirmée',
            style: AppTextStyles.headlineLarge.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Restaurant Le B. · 16 mai à 14h28',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── QR card ─────────────────────────────────────────────────────────────

class _QrCard extends StatelessWidget {
  const _QrCard({
    required this.payload,
    required this.commandeRef,
    required this.traceUrl,
  });

  final String payload;
  final String commandeRef;
  final String traceUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'TRAÇABILITÉ PRODUIT · SCANNER CE CODE',
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: QrImageView(
              data: payload,
              version: QrVersions.auto,
              size: 196,
              backgroundColor: Colors.white,
              gapless: true,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.text,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Commande #$commandeRef',
            textAlign: TextAlign.center,
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            traceUrl,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              fontFamily: AppTextStyles.displayLarge.fontFamily,
              fontSize: 11,
              color: AppColors.primary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _QrActionButton(
                  icon: Icons.download_outlined,
                  label: 'Télécharger',
                  onTap: () => Snackbars.showInfo(
                    context,
                    'Téléchargement du QR — à venir',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QrActionButton(
                  icon: Icons.share_outlined,
                  label: 'Partager',
                  onTap: () => Snackbars.showInfo(
                    context,
                    'Partage du QR — à venir',
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

class _QrActionButton extends StatelessWidget {
  const _QrActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.text),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Trace card (primary-soft) ───────────────────────────────────────────

class _TraceCard extends StatelessWidget {
  const _TraceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
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
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.shield_outlined,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12,
                  color: AppColors.text,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: 'Traçabilité signée. ',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(
                    text:
                        'Tout acheteur, revendeur ou contrôleur peut scanner '
                        'ce QR pour vérifier l\'origine du produit, sa '
                        'qualité, la date de récolte et les traitements '
                        'appliqués.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recap card (6 lignes + hero photo) ──────────────────────────────────

class _RecapCard extends StatelessWidget {
  const _RecapCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Hero photo
          SizedBox(
            height: 110,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: _kHeroPhoto,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
              errorWidget: (_, _, _) =>
                  Container(color: AppColors.surfaceSoft),
            ),
          ),
          const Divider(
            height: 1,
            thickness: AppDimens.borderThin,
            color: AppColors.border,
          ),
          const _RecapRow(
            label: 'Produit',
            value: 'Maïs grain blanc · 500 kg',
          ),
          const _RecapRow(
            label: 'Parcelle d\'origine',
            value: 'Champ derrière la maison · Yopougon',
          ),
          const _RecapRow(label: 'Récolté le', value: '8 mai 2026'),
          const _RecapRow(label: 'Transporteur', value: 'Camion Vert SARL'),
          const _RecapRow(label: 'Acheteur', value: 'Restaurant Le B.'),
          const _RecapRow(
            label: 'Montant crédité',
            value: '+ 169 750 F',
            valueGreen: true,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _RecapRow extends StatelessWidget {
  const _RecapRow({
    required this.label,
    required this.value,
    this.valueGreen = false,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool valueGreen;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: valueGreen
                  ? AppTextStyles.displayLarge.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    )
                  : AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sticky actions ──────────────────────────────────────────────────────

class _StickyActions extends StatelessWidget {
  const _StickyActions({required this.commandeId});

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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () => context.pushReplacement(
                RouteNames.producteurCommandeDetailPathFor(commandeId),
              ),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
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
                  'Voir tous les détails',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              child: Text(
                'Retour à mes commandes',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
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

