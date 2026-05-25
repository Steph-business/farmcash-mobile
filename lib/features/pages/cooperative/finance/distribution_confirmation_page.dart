import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/cooperative/finance/carte_recap_distribution.dart';
import '../../../widgets/cooperative/finance/entete_distribution_confirmation.dart';
import '../../../widgets/cooperative/finance/hero_distribution_effectuee.dart';
import '../../../widgets/cooperative/finance/section_actions_distribution.dart';

// ─── Photos contributeurs (Unsplash — portraits neutres) ────────────────

const String _kPhotoYao =
    'https://images.unsplash.com/photo-1531123897727-8f129e1688ce'
    '?w=200&h=200&fit=crop&auto=format';
const String _kPhotoAya =
    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2'
    '?w=200&h=200&fit=crop&auto=format';
const String _kPhotoKouassi =
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e'
    '?w=200&h=200&fit=crop&auto=format';
const String _kPhotoAdjoua =
    'https://images.unsplash.com/photo-1488459716781-31db52582fe9'
    '?w=200&h=200&fit=crop&auto=format';

const List<LigneRecapDistribution> _kRecap = [
  LigneRecapDistribution(
    photo: _kPhotoYao,
    label: 'Yao Konan · 145 kg',
    montant: '50 750 F',
  ),
  LigneRecapDistribution(
    photo: _kPhotoAya,
    label: "Aya N'Guessan · 130 kg",
    montant: '45 500 F',
  ),
  LigneRecapDistribution(
    photo: _kPhotoKouassi,
    label: 'Kouassi Bamba · 120 kg',
    montant: '42 000 F',
  ),
  LigneRecapDistribution(
    photo: _kPhotoAdjoua,
    label: 'Adjoua Koffi · 105 kg',
    montant: '36 750 F',
  ),
];

/// Page de confirmation après distribution effectuée — hero check vert,
/// récap des contributeurs crédités et 3 actions verticales.
/// Reproduction fidèle de
/// `mockups/cooperative/distribution_confirmation.html`.
class DistributionConfirmationPage extends StatelessWidget {
  const DistributionConfirmationPage({super.key, required this.payoutId});

  /// Identifiant du payout (pour future API
  /// `financeService.getPayout(id)`).
  final String payoutId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EnteteDistributionConfirmation(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  8,
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                ),
                children: const [
                  HeroDistributionEffectuee(
                    montantLabel: '175 000 F distribués',
                    contributeursLabel: '4 contributeurs ont été crédités',
                  ),
                  AppDimens.vGap16,
                  CarteRecapDistribution(
                    titre: 'Publication Maïs blanc · 500 kg',
                    items: _kRecap,
                    totalLabel: 'Total distribué',
                    totalValue: '175 000 F',
                  ),
                  SectionActionsDistribution(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
