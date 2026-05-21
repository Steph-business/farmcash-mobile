import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/commande.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Provider ────────────────────────────────────────────────────────

final _commandeSuccesProvider = FutureProvider.autoDispose
    .family<Commande, String>((ref, id) async {
  return ref.read(ordersServiceProvider).getOrder(id);
});

/// Confirmation de commande après paiement réussi. Charge la commande
/// depuis l'API pour afficher la référence et les montants réels.
class CommandeSuccesPage extends ConsumerWidget {
  const CommandeSuccesPage({required this.commandeId, super.key});

  final String commandeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_commandeSuccesProvider(commandeId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => Column(
            children: [
              _Header(onClose: () => context.go(RouteNames.accueilAcheteurPath)),
              const Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              _Header(onClose: () => context.go(RouteNames.accueilAcheteurPath)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la commande. $e',
                    onRetry: () =>
                        ref.invalidate(_commandeSuccesProvider(commandeId)),
                  ),
                ),
              ),
            ],
          ),
          data: (cmd) => _build(context, cmd),
        ),
      ),
    );
  }

  Widget _build(BuildContext context, Commande cmd) {
    return Column(
      children: [
        _Header(onClose: () => context.go(RouteNames.accueilAcheteurPath)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            children: [
              const _Hero(),
              const SizedBox(height: 4),
              _RecapCard(commande: cmd),
              const SizedBox(height: 18),
              Text(
                'Et maintenant ?',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              const _StepsList(),
            ],
          ),
        ),
        _StickyButtons(commandeId: cmd.id),
      ],
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
              color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          const SizedBox(width: 40),
          Expanded(
            child: Center(
              child: Text(
                'Commande confirmée',
                style: AppTextStyles.titleSmall.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: onClose,
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

// ─── Hero ─────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 18),
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
            child: const Icon(Icons.check, size: 44, color: Colors.white),
          ),
          const SizedBox(height: 14),
          Text(
            'Commande passée !',
            style: AppTextStyles.headlineLarge.copyWith(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Le vendeur a été notifié. Tu seras alerté à chaque étape.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recap card ───────────────────────────────────────────────────────

class _RecapCard extends StatelessWidget {
  const _RecapCard({required this.commande});
  final Commande commande;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMM y', 'fr_FR');
    final reference =
        commande.reference.isNotEmpty ? commande.reference : commande.id;
    final livraisonStr = commande.livraisonDate != null
        ? df.format(commande.livraisonDate!)
        : 'À planifier';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.border, width: AppDimens.borderThin),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          _RecapRow(label: 'N° commande', value: '#$reference'),
          _RecapRow(
            label: 'Quantité',
            value: '${_nf.format(commande.quantiteKg.round())} kg',
          ),
          _RecapRow(
            label: 'Montant',
            value: '${_nf.format(commande.montantTotal.round())} F',
            valueGreen: true,
          ),
          _RecapRow(
            label: 'Livraison estimée',
            value: livraisonStr,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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
              style: valueGreen
                  ? AppTextStyles.bodyMedium.copyWith(
                      fontFamily: 'Poppins',
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

// ─── Steps list ───────────────────────────────────────────────────────

class _StepsList extends StatelessWidget {
  const _StepsList();
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _StepTile(num: '1', text: 'Le vendeur prépare ton colis'),
        SizedBox(height: 10),
        _StepTile(
          num: '2',
          text:
              'Le transporteur prend le colis (paiement libéré au vendeur via escrow auto)',
        ),
        SizedBox(height: 10),
        _StepTile(
          num: '3',
          text: 'Tu reçois et tu montres ton QR pour valider la livraison',
        ),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.num, required this.text});
  final String num;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.border, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8F5E9),
            ),
            alignment: Alignment.center,
            child: Text(
              num,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                color: AppColors.text,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
              color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () => context.go(
                RouteNames.acheteurCommandeDetailPathFor(commandeId),
              ),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Suivre ma commande',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => context.go(RouteNames.acheteurMarchePath),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                'Retour au marché',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final _nf = NumberFormat('#,##0', 'fr_FR');
