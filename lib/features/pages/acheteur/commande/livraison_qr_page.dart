import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/snackbars.dart';

// ─── Constantes visuelles (calées sur la maquette HTML) ────────────────

const Color _kWarnSoft = Color(0xFFFEF3C7);
const Color _kWarn = Color(0xFFB45309);

const String _kFallbackCommandeRef = 'C-2026-0089';
const String _kReceptionSlug = 'cmd89-recept';

/// QR de réception acheteur — à montrer au transporteur quand il arrive.
/// Calque sur `mockups/acheteur/livraison_qr.html`.
class LivraisonQrPage extends ConsumerWidget {
  const LivraisonQrPage({required this.commandeId, super.key});

  final String commandeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ref0 = commandeId.startsWith('C-')
        ? commandeId
        : _kFallbackCommandeRef;
    final traceUrl = 'farmcash.ci/d/$_kReceptionSlug';
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                children: [
                  const _TopInfoWarn(),
                  const SizedBox(height: 18),
                  _QrCard(
                    payload: qrPayload,
                    commandeRef: ref0,
                    traceUrl: traceUrl,
                  ),
                  const SizedBox(height: 14),
                  const _MiniRecap(),
                  const SizedBox(height: 8),
                  _SignalerLink(
                    onTap: () => Snackbars.showInfo(
                      context,
                      'Signaler un problème — à venir',
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

// ─── Header ────────────────────────────────────────────────────────────

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
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
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
              'Mon QR de réception',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Top info warn ─────────────────────────────────────────────────────

class _TopInfoWarn extends StatelessWidget {
  const _TopInfoWarn();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kWarnSoft,
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
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.warning_amber_rounded,
              size: 16,
              color: _kWarn,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Montre ce QR au transporteur quand il arrive. C\'est ce qui '
              'confirme la livraison et libère son paiement.',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.text,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── QR card (240×240 + meta) ─────────────────────────────────────────

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
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Text(
            'QR DE RÉCEPTION · À SCANNER',
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
          const SizedBox(height: 14),
          Text(
            'Réception commande #$commandeRef',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            traceUrl,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              fontFamily: 'Poppins',
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

// ─── Mini recap (3 lignes) ────────────────────────────────────────────

class _MiniRecap extends StatelessWidget {
  const _MiniRecap();

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
        children: const [
          _RecapRow(
            label: 'Produit',
            value: 'Maïs grain blanc · 500 kg',
          ),
          _RecapRow(
            label: 'Vendeur',
            value: 'Yao K. (anonymisé)',
          ),
          _RecapRow(
            label: 'Transporteur attendu',
            value: 'Camion Vert SARL · ETA 14h',
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
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              style: AppTextStyles.bodySmall.copyWith(
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

// ─── Lien signaler problème ────────────────────────────────────────────

class _SignalerLink extends StatelessWidget {
  const _SignalerLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(8),
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
    );
  }
}

