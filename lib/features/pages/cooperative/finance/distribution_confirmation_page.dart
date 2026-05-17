import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

// ─── Couleurs & photos (alignées maquette HTML) ─────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

// Photos contributeurs (Unsplash — portraits neutres).
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

/// Ligne récap d'un contributeur crédité.
class _RecapLine {
  final String photo;
  final String label; // FULL — coop voit ses membres en clair
  final String montant;
  const _RecapLine({
    required this.photo,
    required this.label,
    required this.montant,
  });
}

const List<_RecapLine> _kRecap = [
  _RecapLine(
    photo: _kPhotoYao,
    label: 'Yao Konan · 145 kg',
    montant: '50 750 F',
  ),
  _RecapLine(
    photo: _kPhotoAya,
    label: "Aya N'Guessan · 130 kg",
    montant: '45 500 F',
  ),
  _RecapLine(
    photo: _kPhotoKouassi,
    label: 'Kouassi Bamba · 120 kg',
    montant: '42 000 F',
  ),
  _RecapLine(
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
            const _Header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  8,
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                ),
                children: const [
                  _Hero(),
                  AppDimens.vGap16,
                  _RecapCard(items: _kRecap),
                  _ActionsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header (pas de back — titre centré + X à droite) ────────────────────

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
      child: Row(
        children: [
          const SizedBox(width: 32),
          Expanded(
            child: Center(
              child: Text(
                'Distribution effectuée',
                style: AppTextStyles.titleSmall.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () => context.canPop()
                ? context.pop()
                : context.go(RouteNames.accueilCooperativePath),
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.close,
                size: 22,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero centré (check vert + montant + sous-titre) ────────────────────

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 20),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '175 000 F distribués',
            style: AppTextStyles.headlineLarge.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '4 contributeurs ont été crédités',
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

// ─── Card récap (titre + 4 lignes + total) ──────────────────────────────

class _RecapCard extends StatelessWidget {
  const _RecapCard({required this.items});

  final List<_RecapLine> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Publication Maïs blanc · 500 kg',
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          for (final l in items) _RecapRow(line: l),
          const SizedBox(height: 6),
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Total distribué',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '175 000 F',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontFamily: AppTextStyles.displayLarge.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
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

class _RecapRow extends StatelessWidget {
  const _RecapRow({required this.line});

  final _RecapLine line;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: CachedNetworkImage(
              imageUrl: line.photo,
              fit: BoxFit.cover,
              placeholder: (_, _) => const ColoredBox(color: _kPrimarySoft),
              errorWidget: (_, _, _) => Center(
                child: Text(
                  _initiales(line.label),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              line.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            line.montant,
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: AppTextStyles.displayLarge.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section "Que veux-tu faire ?" + 3 boutons verticaux ────────────────

class _ActionsSection extends StatelessWidget {
  const _ActionsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Que veux-tu faire ?',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _ALink(
            label: 'Voir le récap dans Wallet',
            onTap: () => context.push(RouteNames.cooperativeWalletPath),
          ),
          const SizedBox(height: 10),
          _ASecondary(
            label: 'Distribuer une autre publication',
            onTap: () => context.go(RouteNames.cooperativePayoutsPath),
          ),
          const SizedBox(height: 10),
          _APrimary(
            label: "Retour à l'accueil",
            onTap: () => context.go(RouteNames.accueilCooperativePath),
          ),
        ],
      ),
    );
  }
}

class _ALink extends StatelessWidget {
  const _ALink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.link.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ASecondary extends StatelessWidget {
  const _ASecondary({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary,
            width: AppDimens.borderThin,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _APrimary extends StatelessWidget {
  const _APrimary({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary,
            width: AppDimens.borderThin,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.onPrimary,
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────

String _initiales(String s) {
  final t = s.trim();
  if (t.isEmpty) return '?';
  final parts = t.split(RegExp(r'[\s\-_]+'))..removeWhere((p) => p.isEmpty);
  if (parts.length >= 2) {
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
  if (t.length == 1) return t.toUpperCase();
  return t.substring(0, 2).toUpperCase();
}
