import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../models/pickup_qr_token.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/snackbars.dart';

// ─── Couleurs accent (conformes au mockup) ───────────────────────────────

const Color _kWarnSoft = Color(0xFFFEF3C7);
const Color _kWarnSoftBorder = Color(0xFFFDE68A);
const Color _kWarn = Color(0xFFB45309);
const Color _kPrimarySoft = Color(0xFFE8F5E9);

const String _kFallbackToken = 'lot89-mb500';

/// Provider familial : tente de récupérer un PickupQrToken pour ce shipment.
/// Si l'endpoint répond en erreur (ou si le shipment n'est pas en ACCEPTED),
/// on retombe sur le token visuel de la maquette.
final _qrTokenProvider = FutureProvider.autoDispose
    .family<PickupQrToken?, String>((ref, shipmentId) async {
  try {
    return await ref.watch(logisticsServiceProvider).generatePickupQrToken(shipmentId);
  } catch (_) {
    return null;
  }
});

/// Bordereau d'enlèvement QR — montré au transporteur pour confirmer
/// l'enlèvement (déclenche l'auto-release de l'escrow PRODUCT).
class EnlevementQrPage extends ConsumerWidget {
  const EnlevementQrPage({required this.commandeId, super.key});

  final String commandeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // L'identifiant qu'on encode dans le QR : token backend si dispo,
    // sinon le slug visuel de la maquette ; dans tous les cas on prefixe
    // par l'URL de tracking afin que l'app transporteur puisse parser.
    final asyncToken = ref.watch(_qrTokenProvider(commandeId));
    final token = asyncToken.maybeWhen(
      data: (t) => t?.token ?? _kFallbackToken,
      orElse: () => _kFallbackToken,
    );
    final qrPayload = 'farmcash.ci/e/$token';

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
                  const _TopInfo(),
                  AppDimens.vGap16,
                  _QrCard(payload: qrPayload, token: token),
                  AppDimens.vGap16,
                  const _MiniRecap(),
                  AppDimens.vGap8,
                  const _TransporterCard(),
                ],
              ),
            ),
            const _StickyLink(),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────

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
              'Bordereau d\'enlèvement',
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

// ─── Top info (warn-soft) ────────────────────────────────────────────────

class _TopInfo extends StatelessWidget {
  const _TopInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kWarnSoft,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: _kWarnSoftBorder, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: _kWarn,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.info_outline,
              size: 16,
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
                  'Montre ce code au transporteur',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kWarn,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Il doit le scanner pour confirmer l\'enlèvement. C\'est '
                  'ce qui déclenche le versement des 169 750 F sur ton wallet.',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5,
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

// ─── QR card ─────────────────────────────────────────────────────────────

class _QrCard extends StatelessWidget {
  const _QrCard({required this.payload, required this.token});

  final String payload;
  final String token;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          Container(
            width: 240,
            height: 240,
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
              size: 216,
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
          AppDimens.vGap16,
          Text(
            'Bordereau LOT-2026-0089',
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: AppTextStyles.displayLarge.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            payload,
            style: AppTextStyles.labelSmall.copyWith(
              fontFamily: AppTextStyles.displayLarge.fontFamily,
              fontSize: 11,
              color: AppColors.primary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mini recap ──────────────────────────────────────────────────────────

class _MiniRecap extends StatelessWidget {
  const _MiniRecap();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _RecapRow(label: 'Produit', value: 'Maïs grain blanc'),
          _RecapRow(label: 'Quantité', value: '500 kg'),
          _RecapRow(
            label: 'Destination',
            value: 'Restaurant Le Baoulé · Cocody',
          ),
          _RecapRow(
            label: 'À recevoir à l\'enlèvement',
            value: '169 750 F',
            valueColor: AppColors.primary,
            usePoppins: true,
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
    this.valueColor,
    // ignore: unused_element_parameter
    this.usePoppins = false,
    // ignore: unused_element_parameter
    this.isLast = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool usePoppins;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 6),
      child: Row(
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
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: usePoppins
                  ? AppTextStyles.displayLarge.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: valueColor ?? AppColors.text,
                    )
                  : AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? AppColors.text,
                    ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card transporteur ──────────────────────────────────────────────────

class _TransporterCard extends StatelessWidget {
  const _TransporterCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: _kPrimarySoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'CV',
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
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
                  'Camion Vert SARL',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Toyota Hilux · 2345 AB 01 · arrive ~14h',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'En route',
              style: AppTextStyles.labelSmall.copyWith(
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

// ─── Sticky lien ─────────────────────────────────────────────────────────

class _StickyLink extends StatelessWidget {
  const _StickyLink();

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
      child: Center(
        child: InkWell(
          onTap: () => Snackbars.showInfo(
            context,
            'Signaler un problème — à venir',
          ),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            child: Text(
              'Pas de transporteur ? Signaler un problème',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

