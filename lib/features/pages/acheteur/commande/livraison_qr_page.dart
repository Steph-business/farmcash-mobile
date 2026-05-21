import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../models/commande.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Constantes visuelles ──────────────────────────────────────────────

const Color _kWarnSoft = Color(0xFFFEF3C7);
const Color _kWarn = Color(0xFFB45309);

// ─── Provider ─────────────────────────────────────────────────────────

class _LivraisonBundle {
  const _LivraisonBundle({required this.commande, this.annonce});
  final Commande commande;
  final AnnonceVente? annonce;
}

final _livraisonBundleProvider = FutureProvider.autoDispose
    .family<_LivraisonBundle, String>((ref, id) async {
  final cmd = await ref.read(ordersServiceProvider).getOrder(id);
  AnnonceVente? annonce;
  try {
    annonce =
        await ref.read(marketplaceServiceProvider).getAnnonceVente(cmd.annonceId);
  } catch (_) {}
  return _LivraisonBundle(commande: cmd, annonce: annonce);
});

/// QR de réception acheteur — à montrer au transporteur quand il arrive.
///
/// Le QR encode l'ID de commande + référence. Côté back, il n'existe pas
/// encore d'endpoint dédié au "scan livraison" (le transporteur déclenche
/// la livraison via `POST /logistics/shipments/:id/deliver`). L'écran sert
/// donc surtout d'aide visuelle pour identifier la commande à la livraison.
class LivraisonQrPage extends ConsumerWidget {
  const LivraisonQrPage({required this.commandeId, super.key});

  final String commandeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_livraisonBundleProvider(commandeId));
    return Scaffold(
      backgroundColor: AppColors.background,
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
                    message: 'Impossible de charger la commande. $e',
                    onRetry: () =>
                        ref.invalidate(_livraisonBundleProvider(commandeId)),
                  ),
                ),
              ),
            ],
          ),
          data: (bundle) => _build(context, bundle),
        ),
      ),
    );
  }

  Widget _build(BuildContext context, _LivraisonBundle bundle) {
    final c = bundle.commande;
    final reference = c.reference.isNotEmpty
        ? c.reference
        : c.id.substring(0, 8).toUpperCase();
    // Payload QR : ID commande + référence. Côté transporteur c'est ce qui
    // permettra de localiser la commande dans son app.
    final qrPayload = 'farmcash://commande/${c.id}?ref=$reference';

    return Column(
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
                commandeRef: reference,
              ),
              const SizedBox(height: 14),
              _MiniRecap(commande: c, annonce: bundle.annonce),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kWarnSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFDE68A),
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: _kWarn),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Montre ce QR au transporteur à la livraison. Le scan déclenche la confirmation et libère le paiement au vendeur.',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
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

// ─── QR card ──────────────────────────────────────────────────────────

class _QrCard extends StatelessWidget {
  const _QrCard({required this.payload, required this.commandeRef});

  final String payload;
  final String commandeRef;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: payload,
              size: 220,
              backgroundColor: Colors.white,
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Commande #$commandeRef',
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mini recap ───────────────────────────────────────────────────────

class _MiniRecap extends StatelessWidget {
  const _MiniRecap({required this.commande, required this.annonce});
  final Commande commande;
  final AnnonceVente? annonce;

  @override
  Widget build(BuildContext context) {
    final nom = annonce?.produitLabel ?? 'Commande';
    final qte = _nf.format(commande.quantiteKg.round());
    final montant = _nf.format(commande.montantTotal.round());
    final df = DateFormat('d MMM', 'fr_FR');
    final livraison = commande.livraisonDate != null
        ? df.format(commande.livraisonDate!)
        : '—';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('Produit', '$qte kg $nom'),
          const SizedBox(height: 6),
          _row('Montant', '$montant F'),
          const SizedBox(height: 6),
          _row('Livraison prévue', livraison),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
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
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}

// ─── Signaler ─────────────────────────────────────────────────────────

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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            'Signaler un problème',
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ),
      ),
    );
  }
}

final _nf = NumberFormat('#,##0', 'fr_FR');
