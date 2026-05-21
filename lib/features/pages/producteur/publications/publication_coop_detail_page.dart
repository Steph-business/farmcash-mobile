import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

// ─── COULEURS & RADIUS LOCAUX ───────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarnSoft = Color(0xFFFFF8E1);
const Color _kWarn = Color(0xFFB26A00);
const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));

// ─── Statut d'une publication coop ──────────────────────────────────────

enum _PubStatus { enCours, publie, vendu }

/// Détail d'une publication coopérative — vue côté producteur membre.
///
/// Indique l'agrégat coop, la quote-part du membre, le prix unitaire, le
/// statut et la contribution propre. Mock data en attendant que
/// `cooperativesService.getPublication(id)` soit branché.
class PublicationCoopDetailPage extends ConsumerWidget {
  const PublicationCoopDetailPage({super.key, required this.id});

  /// Identifiant de la publication coop — conservé pour brancher l'API
  /// `cooperativesService.getPublication(id)` ultérieurement.
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock-first : valeurs figées sur une publication de maïs blanc.
    const titre = 'Maïs grain blanc — récolte mai 2026';
    const coopNom = 'COOP-AGRI Lagunes';
    const datePublication = 'Publié le 10 mai 2026';
    const dateLimite = 'Clôture le 30 mai 2026';
    const quantiteAggregee = '4 500 kg';
    const quantiteMembre = '500 kg';
    const prixUnitaire = '350 F/kg';
    const totalMembre = '175 000 F';
    const status = _PubStatus.enCours;
    const qualite = 'Standard';

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
                  0,
                  AppDimens.pagePaddingH,
                  AppDimens.space24,
                ),
                children: [
                  _HeaderCard(
                    titre: titre,
                    coop: coopNom,
                    datePub: datePublication,
                    dateLimite: dateLimite,
                  ),
                  AppDimens.vGap16,
                  const _SectionTitle('Quantité agrégée'),
                  AppDimens.vGap12,
                  const _QuantiteCard(
                    agregee: quantiteAggregee,
                    maPart: quantiteMembre,
                  ),
                  AppDimens.vGap16,
                  const _SectionTitle('Prix'),
                  AppDimens.vGap12,
                  const _PrixCard(
                    prixUnitaire: prixUnitaire,
                    totalMembre: totalMembre,
                  ),
                  AppDimens.vGap16,
                  const _SectionTitle('Statut'),
                  AppDimens.vGap12,
                  const _StatusCard(status: status),
                  AppDimens.vGap16,
                  const _SectionTitle('Ma contribution'),
                  AppDimens.vGap12,
                  const _ContributionCard(
                    quantite: quantiteMembre,
                    qualite: qualite,
                    statut: 'Engagé · en attente de livraison',
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

// ─── Header ──────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.canPop()
                ? context.pop()
                : context.go(RouteNames.producteurCooperativePath),
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
              'Publication coop',
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

// ─── Header card (titre + coop + dates) ─────────────────────────────────

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.titre,
    required this.coop,
    required this.datePub,
    required this.dateLimite,
  });

  final String titre;
  final String coop;
  final String datePub;
  final String dateLimite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titre,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.business_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  coop,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          AppDimens.vGap12,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.space12,
              vertical: AppDimens.space8,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MiniRow(label: datePub, icon: Icons.event_outlined),
                const SizedBox(height: 4),
                _MiniRow(label: dateLimite, icon: Icons.timer_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniRow extends StatelessWidget {
  const _MiniRow({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Section title ──────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.titre);

  final String titre;

  @override
  Widget build(BuildContext context) {
    return Text(
      titre,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ─── Quantité ────────────────────────────────────────────────────────────

class _QuantiteCard extends StatelessWidget {
  const _QuantiteCard({required this.agregee, required this.maPart});

  final String agregee;
  final String maPart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        children: [
          _LabelValueRow(
            label: 'Quantité totale',
            value: agregee,
            highlight: false,
          ),
          AppDimens.vGap12,
          Container(
            height: 1,
            color: AppColors.border,
          ),
          AppDimens.vGap12,
          _LabelValueRow(
            label: 'Dont ma part',
            value: maPart,
            highlight: true,
          ),
        ],
      ),
    );
  }
}

// ─── Prix ────────────────────────────────────────────────────────────────

class _PrixCard extends StatelessWidget {
  const _PrixCard({required this.prixUnitaire, required this.totalMembre});

  final String prixUnitaire;
  final String totalMembre;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        children: [
          _LabelValueRow(
            label: 'Prix unitaire',
            value: prixUnitaire,
            highlight: false,
          ),
          AppDimens.vGap12,
          Container(
            height: 1,
            color: AppColors.border,
          ),
          AppDimens.vGap12,
          _LabelValueRow(
            label: 'Total estimé pour ma part',
            value: totalMembre,
            highlight: true,
          ),
        ],
      ),
    );
  }
}

class _LabelValueRow extends StatelessWidget {
  const _LabelValueRow({
    required this.label,
    required this.value,
    required this.highlight,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              color: highlight ? AppColors.text : AppColors.textSecondary,
              fontWeight: highlight ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: highlight
              ? AppTextStyles.titleLarge.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -0.2,
                )
              : AppTextStyles.titleSmall.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
        ),
      ],
    );
  }
}

// ─── Statut ──────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});

  final _PubStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label, icon) = switch (status) {
      _PubStatus.enCours => (
          _kWarnSoft,
          _kWarn,
          'En cours',
          Icons.schedule_outlined,
        ),
      _PubStatus.publie => (
          _kPrimarySoft,
          AppColors.primary,
          'Publié',
          Icons.campaign_outlined,
        ),
      _PubStatus.vendu => (
          _kPrimarySoft,
          AppColors.primary,
          'Vendu',
          Icons.check_circle_outline,
        ),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: fg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _sousTitreFor(status),
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

  String _sousTitreFor(_PubStatus s) {
    switch (s) {
      case _PubStatus.enCours:
        return 'Les contributions des membres se rassemblent';
      case _PubStatus.publie:
        return 'L\'annonce est visible sur le marché';
      case _PubStatus.vendu:
        return 'Lot vendu, payout en préparation';
    }
  }
}

// ─── Ma contribution ────────────────────────────────────────────────────

class _ContributionCard extends StatelessWidget {
  const _ContributionCard({
    required this.quantite,
    required this.qualite,
    required this.statut,
  });

  final String quantite;
  final String qualite;
  final String statut;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        children: [
          _SimpleRow(label: 'Quantité', value: quantite),
          AppDimens.vGap8,
          _SimpleRow(label: 'Qualité', value: qualite),
          AppDimens.vGap8,
          _SimpleRow(label: 'Statut', value: statut),
        ],
      ),
    );
  }
}

class _SimpleRow extends StatelessWidget {
  const _SimpleRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
