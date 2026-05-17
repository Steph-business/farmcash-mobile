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

// ─── Constantes visuelles (calées sur la maquette HTML) ────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const String _kRecapPhoto =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=600&h=300&fit=crop&auto=format';

const String _kFallbackCommandeId = 'C-2026-0089';

// ─── Modes ──────────────────────────────────────────────────────────────

enum _DeliveryMode { auto, choisir }

enum _PaymentMethod { wallet, om, mtn, carte }

class _MethodSpec {
  const _MethodSpec({
    required this.method,
    required this.short,
    required this.name,
    required this.color,
    this.subtitle,
    this.badge,
    this.dark = false,
  });
  final _PaymentMethod method;
  final String short;
  final String name;
  final Color color;
  final String? subtitle;
  final String? badge;
  final bool dark;
}

const List<_MethodSpec> _kMethods = [
  _MethodSpec(
    method: _PaymentMethod.wallet,
    short: 'FC',
    name: 'Solde wallet',
    color: AppColors.primary,
    badge: '245 800 F dispo',
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
    subtitle: '+ Ajouter',
    dark: true,
  ),
  _MethodSpec(
    method: _PaymentMethod.carte,
    short: 'CB',
    name: 'Carte bancaire',
    color: AppColors.text,
    subtitle: 'Visa / MC',
  ),
];

// ─── Page ──────────────────────────────────────────────────────────────

/// Paiement d'une commande (acheteur, depuis une annonce ferme).
/// Calque sur `mockups/acheteur/paiement_commande.html`.
class PaiementCommandePage extends ConsumerStatefulWidget {
  const PaiementCommandePage({required this.annonceId, super.key});

  final String annonceId;

  @override
  ConsumerState<PaiementCommandePage> createState() =>
      _PaiementCommandePageState();
}

class _PaiementCommandePageState extends ConsumerState<PaiementCommandePage> {
  _PaymentMethod _method = _PaymentMethod.wallet;
  _DeliveryMode _delivery = _DeliveryMode.auto;
  final TextEditingController _noteCtrl = TextEditingController();

  // Valeurs maquette (500 kg × 350 F/kg).
  static const int _sousTotal = 175000;
  static const int _frais = 2625;
  static const int _livraison = 4500;
  static const int _total = _sousTotal + _frais + _livraison;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

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
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                children: [
                  const _RecapCard(),
                  const SizedBox(height: 18),
                  const _SectionTitle('Mode de livraison'),
                  const SizedBox(height: 10),
                  _DeliveryOptions(
                    selected: _delivery,
                    onChange: (mode) {
                      setState(() => _delivery = mode);
                      if (mode == _DeliveryMode.choisir) {
                        context.push(
                          RouteNames.acheteurChoisirTransporteurPath,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle('Montants'),
                  const SizedBox(height: 10),
                  const _AmountsCard(
                    sousTotal: _sousTotal,
                    frais: _frais,
                    livraison: _livraison,
                    total: _total,
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle('Méthode de paiement'),
                  const SizedBox(height: 10),
                  _MethodsGrid(
                    selected: _method,
                    onSelect: (m) => setState(() => _method = m),
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle('Adresse de livraison'),
                  const SizedBox(height: 10),
                  _AddressCard(
                    onEdit: () => Snackbars.showInfo(
                      context,
                      'Édition de l\'adresse — à venir',
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle('Note pour le vendeur (optionnel)'),
                  const SizedBox(height: 10),
                  _NoteField(controller: _noteCtrl),
                ],
              ),
            ),
            _StickyBottom(total: _total, onPay: _onPay),
          ],
        ),
      ),
    );
  }

  Future<void> _onPay() async {
    Snackbars.showSucces(
      context,
      'Paiement de ${_nf.format(_total)} F · escrow activé',
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    context.push(
      RouteNames.acheteurCommandeSuccesPathFor(_kFallbackCommandeId),
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
              'Paiement commande',
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

// ─── Recap card (hero photo 110px + 3 lignes) ───────────────────────────

class _RecapCard extends StatelessWidget {
  const _RecapCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: double.infinity,
              height: 110,
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
            '500 kg Maïs blanc',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '350 F/kg · Yao K.',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Livraison estimée : 23 mai',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section title (bold 14px, conforme maquette) ───────────────────────

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

// ─── Delivery options (radios) ─────────────────────────────────────────

class _DeliveryOptions extends StatelessWidget {
  const _DeliveryOptions({required this.selected, required this.onChange});

  final _DeliveryMode selected;
  final ValueChanged<_DeliveryMode> onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DOption(
          isSelected: selected == _DeliveryMode.auto,
          title: '🤝 Trouvé automatiquement par FarmCash',
          badge: 'Recommandé',
          subtitle:
              'Prix fixe · 12 500 F · ETA 1-2j · Le 1er transporteur dispo prend',
          onTap: () => onChange(_DeliveryMode.auto),
        ),
        const SizedBox(height: 8),
        _DOption(
          isSelected: selected == _DeliveryMode.choisir,
          title: '🚛 Choisir mon transporteur',
          badge: null,
          subtitle:
              'À partir de 11 800 F · Compare 4 transporteurs dispos dans ta zone',
          onTap: () => onChange(_DeliveryMode.choisir),
        ),
      ],
    );
  }
}

class _DOption extends StatelessWidget {
  const _DOption({
    required this.isSelected,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final bool isSelected;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? _kPrimarySoft : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderStrong,
            width: isSelected ? 1.5 : AppDimens.borderThin,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected ? AppColors.primary : AppColors.borderStrong,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge!,
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.4,
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

// ─── Amounts card ─────────────────────────────────────────────────────

class _AmountsCard extends StatelessWidget {
  const _AmountsCard({
    required this.sousTotal,
    required this.frais,
    required this.livraison,
    required this.total,
  });

  final int sousTotal;
  final int frais;
  final int livraison;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        children: [
          _amRow('Sous-total', '${_nf.format(sousTotal)} F'),
          _amRow('Frais service', '${_nf.format(frais)} F'),
          _amRow('Livraison estimée', '${_nf.format(livraison)} F'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Total à payer',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  '${_nf.format(total)} F',
                  style: AppTextStyles.displayLarge.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _amRow(String l, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l,
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

// ─── Methods grid (2×2) ───────────────────────────────────────────────

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
        mainAxisExtent: 100,
      ),
      itemCount: _kMethods.length,
      itemBuilder: (context, i) {
        final spec = _kMethods[i];
        final active = spec.method == selected;
        return InkWell(
          onTap: () => onSelect(spec.method),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: active ? _kPrimarySoft : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? AppColors.primary : AppColors.border,
                width: active ? 1.5 : AppDimens.borderThin,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  spec.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (spec.badge != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    spec.badge!,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else if (spec.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    spec.subtitle!,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Adresse card ──────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.location_on_outlined,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Restaurant Le B.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Cocody · 22 Av X',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 4,
              ),
              child: Text(
                'Modifier',
                style: AppTextStyles.link.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Note vendeur ──────────────────────────────────────────────────────

class _NoteField extends StatelessWidget {
  const _NoteField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 3,
      minLines: 3,
      style: AppTextStyles.bodyMedium.copyWith(
        fontSize: 13,
        color: AppColors.text,
      ),
      decoration: InputDecoration(
        hintText: 'Ex : livrer après 14h, contacter à l\'arrivée...',
        hintStyle: AppTextStyles.bodySmall.copyWith(
          fontSize: 13,
          color: AppColors.textSubtle,
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

// ─── Sticky bottom (bouton plein vert) ─────────────────────────────────

class _StickyBottom extends StatelessWidget {
  const _StickyBottom({required this.total, required this.onPay});

  final int total;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: InkWell(
        onTap: onPay,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary,
              width: AppDimens.borderThin,
            ),
          ),
          child: Text(
            'Payer ${_nf.format(total)} F · escrow sécurisé',
            style: AppTextStyles.button.copyWith(
              fontSize: 14,
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────

final _nf = NumberFormat('#,##0', 'fr_FR');
