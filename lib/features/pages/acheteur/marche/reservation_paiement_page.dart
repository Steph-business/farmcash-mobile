import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/snackbars.dart';

// ─── Constantes ───────────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const String _kRecapPhoto =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=600&h=300&fit=crop&auto=format';

enum _PaymentMethod { wallet, om, mtn, carte }

class _MethodSpec {
  const _MethodSpec({
    required this.method,
    required this.short,
    required this.name,
    required this.color,
    required this.subtitle,
    this.badge,
    this.dark = false,
  });
  final _PaymentMethod method;
  final String short;
  final String name;
  final Color color;
  final String? subtitle;
  final String? badge;
  final bool dark; // si true => texte du logo en noir (MTN jaune)
}

const List<_MethodSpec> _kMethods = [
  _MethodSpec(
    method: _PaymentMethod.wallet,
    short: 'FC',
    name: 'Solde wallet',
    color: AppColors.primary,
    subtitle: null,
    badge: 'Dispo 245 800 F',
  ),
  _MethodSpec(
    method: _PaymentMethod.om,
    short: 'OM',
    name: 'Orange Money',
    color: Color(0xFFFF6B00),
    subtitle: '07 09 88 30 51',
  ),
  _MethodSpec(
    method: _PaymentMethod.mtn,
    short: 'MTN',
    name: 'MTN MoMo',
    color: Color(0xFFFFCC00),
    subtitle: '05 ** ** ** 21',
    dark: true,
  ),
  _MethodSpec(
    method: _PaymentMethod.carte,
    short: 'CB',
    name: 'Carte bancaire',
    color: Color(0xFF1E40AF),
    subtitle: 'Visa / Mastercard',
  ),
];

// ─── Page ─────────────────────────────────────────────────────────────

/// Écran de confirmation de réservation (acompte 10% + reste à livraison).
/// Recap card hero, blocs acompte/reste, choix méthode, CGV, sticky bouton.
class ReservationPaiementPage extends ConsumerStatefulWidget {
  const ReservationPaiementPage({required this.previsionId, super.key});

  final String previsionId;

  @override
  ConsumerState<ReservationPaiementPage> createState() =>
      _ReservationPaiementPageState();
}

class _ReservationPaiementPageState
    extends ConsumerState<ReservationPaiementPage> {
  _PaymentMethod _method = _PaymentMethod.wallet;
  bool _cgvAccepted = true;

  // Valeurs de la maquette (200 kg · Maïs · 350 F/kg).
  static const int _qte = 200;
  static const int _prixUnitaire = 350;
  static const int _acompte = 7000; // 10%
  static const int _reste = 63000; // 90%

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(title: 'Confirmer la réservation'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  const _RecapCard(qte: _qte, prixUnitaire: _prixUnitaire),
                  const SizedBox(height: 18),
                  const _SectionTitle('Acompte à payer maintenant (10%)'),
                  const SizedBox(height: 8),
                  const _AcompteBox(montant: _acompte),
                  const SizedBox(height: 14),
                  const _SectionTitle('Reste à payer à la livraison (90%)'),
                  const SizedBox(height: 8),
                  const _ResteBox(montant: _reste, libelle: 'Le 15 juin'),
                  const SizedBox(height: 18),
                  const _SectionTitle('Méthode de paiement'),
                  const SizedBox(height: 10),
                  _MethodsGrid(
                    selected: _method,
                    onSelect: (m) => setState(() => _method = m),
                  ),
                  const SizedBox(height: 16),
                  _CgvRow(
                    accepted: _cgvAccepted,
                    onToggle: () =>
                        setState(() => _cgvAccepted = !_cgvAccepted),
                  ),
                ],
              ),
            ),
            _StickyBottom(
              acompte: _acompte,
              enabled: _cgvAccepted,
              onPay: _onPay,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onPay() async {
    if (!_cgvAccepted) {
      Snackbars.showErreur(context, 'Tu dois accepter les CGV.');
      return;
    }
    Snackbars.showSucces(
      context,
      'Réservation confirmée — acompte ${_nf.format(_acompte)} F payé',
    );
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    context.go(RouteNames.acheteurMesReservationsPath);
  }
}

// ─── Recap card ───────────────────────────────────────────────────────

class _RecapCard extends StatelessWidget {
  const _RecapCard({required this.qte, required this.prixUnitaire});

  final int qte;
  final int prixUnitaire;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 100,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: _kRecapPhoto,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
                errorWidget: (_, _, _) =>
                    Container(color: AppColors.surfaceSoft),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'RÉCAPITULATIF',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _kvRow('Produit', 'Maïs blanc'),
          _kvRow('Quantité', '$qte kg'),
          _kvRow('Prix unitaire', '$prixUnitaire F/kg'),
          _kvRow('Livraison estimée', '15 juin'),
        ],
      ),
    );
  }

  Widget _kvRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            k,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            v,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 4),
      child: Text(
        text,
        style: AppTextStyles.titleSmall.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
    );
  }
}

class _AcompteBox extends StatelessWidget {
  const _AcompteBox({required this.montant});

  final int montant;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary, width: AppDimens.borderThin),
      ),
      child: Column(
        children: [
          Text(
            'Tu paies aujourd\'hui',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_nf.format(montant)} F',
            style: AppTextStyles.displayLarge.copyWith(
              fontFamily: 'Poppins',
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResteBox extends StatelessWidget {
  const _ResteBox({required this.montant, required this.libelle});

  final int montant;
  final String libelle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            libelle,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '${_nf.format(montant)} F',
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Grille méthodes paiement ─────────────────────────────────────────

class _MethodsGrid extends StatelessWidget {
  const _MethodsGrid({required this.selected, required this.onSelect});

  final _PaymentMethod selected;
  final ValueChanged<_PaymentMethod> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 96,
      ),
      itemCount: _kMethods.length,
      itemBuilder: (context, i) {
        final spec = _kMethods[i];
        final active = spec.method == selected;
        return InkWell(
          onTap: () => onSelect(spec.method),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: active ? _kPrimarySoft : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? AppColors.primary : AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: spec.color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        spec.short,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: spec.dark ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        spec.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (spec.badge != null)
                  Text(
                    spec.badge!,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else if (spec.subtitle != null)
                  Text(
                    spec.subtitle!,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── CGV row ──────────────────────────────────────────────────────────

class _CgvRow extends StatelessWidget {
  const _CgvRow({required this.accepted, required this.onToggle});

  final bool accepted;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 18,
              height: 18,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: accepted ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: AppColors.primary,
                  width: AppDimens.borderThin,
                ),
              ),
              alignment: Alignment.center,
              child: accepted
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.text,
                  ),
                  children: [
                    const TextSpan(text: 'J\'accepte les '),
                    TextSpan(
                      text: 'CGV de réservation',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const TextSpan(
                      text:
                          '. L\'acompte n\'est pas remboursable en cas d\'annulation après J-3.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sticky bottom ────────────────────────────────────────────────────

class _StickyBottom extends StatelessWidget {
  const _StickyBottom({
    required this.acompte,
    required this.enabled,
    required this.onPay,
  });

  final int acompte;
  final bool enabled;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: enabled ? onPay : null,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: enabled
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Payer ${_nf.format(acompte)} F et réserver',
              style: AppTextStyles.button.copyWith(
                fontSize: 14,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
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
              title,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────

final _nf = NumberFormat('#,##0', 'fr_FR');
