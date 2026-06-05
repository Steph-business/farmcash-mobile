import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/producteur/commandes/contenu_reservations_recues.dart';

/// Page autonome « Réservations reçues » — accessible depuis le bandeau
/// au-dessus de l'onglet Prévisions de « Mes publications ». Cette
/// page existe pour les producteurs qui arrivent par un deep-link ou
/// le bandeau ; la même donnée est aussi visible dans l'onglet
/// « Réservations » de la page Commandes (top-level).
class MesReservationsRecuesPage extends ConsumerWidget {
  const MesReservationsRecuesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(reservationsRecuesProducteurProvider);
    final count = async.maybeWhen(
      data: (l) => l.length,
      orElse: () => 0,
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(count: count),
            const Expanded(child: ContenuReservationsRecues()),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.text),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Réservations reçues',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  count == 0
                      ? 'Sur tes prévisions de récolte'
                      : '$count réservation${count > 1 ? "s" : ""} en cours',
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
