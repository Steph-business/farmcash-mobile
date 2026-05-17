import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/snackbars.dart';

// ─── Couleurs / radius locaux alignés sur la maquette ─────────────────────
const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kPinArrival = Color(0xFF7F1D1D);
const Color _kStarYellow = Color(0xFFF59E0B);

const BorderRadius _kBrCard14 = BorderRadius.all(Radius.circular(14));
const BorderRadius _kBrCard12 = BorderRadius.all(Radius.circular(12));
const BorderRadius _kBrChip12 = BorderRadius.all(Radius.circular(12));
const BorderRadius _kBrChip10 = BorderRadius.all(Radius.circular(10));

// ─── Modèles mock ─────────────────────────────────────────────────────────

class _Transporteur {
  /// Initiales affichées dans l'avatar par défaut (sinon photo).
  final String initiales;
  final String? photo;
  final String nom;
  final double note;
  final String capacite;
  final String style;
  final String prix;
  final bool dispoToday;
  const _Transporteur({
    required this.initiales,
    this.photo,
    required this.nom,
    required this.note,
    required this.capacite,
    required this.style,
    required this.prix,
    this.dispoToday = false,
  });
}

const List<_Transporteur> _kTransporteurs = [
  _Transporteur(
    initiales: 'CV',
    nom: 'Camion Vert SARL',
    note: 4.8,
    capacite: 'Camion 8t',
    style: 'Bâché',
    prix: '22 000 F',
    dispoToday: true,
  ),
  _Transporteur(
    initiales: 'LP',
    nom: 'Logistique Plus',
    note: 4.6,
    capacite: 'Camion 3.5t',
    style: 'Frigorifique',
    prix: '19 500 F',
  ),
  _Transporteur(
    initiales: 'YT',
    photo:
        'https://images.unsplash.com/photo-1531123897727-8f129e1688ce'
        '?w=120&h=120&fit=crop&auto=format',
    nom: 'Yao Transport',
    note: 4.5,
    capacite: 'Camion 15t',
    style: 'Plateau',
    prix: '24 000 F',
  ),
  _Transporteur(
    initiales: 'AB',
    nom: 'ABC Trans',
    note: 4.2,
    capacite: 'Pick-up',
    style: 'Express',
    prix: '18 000 F',
  ),
];

/// Formulaire « Demander un transport » — étape 1/2.
/// Reproduction fidèle de `mockups/cooperative/transport_demande.html`.
class TransportDemandePage extends StatelessWidget {
  const TransportDemandePage({super.key});

  void _info(BuildContext context, String message) =>
      Snackbars.showInfo(context, message);

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
                  0,
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                ),
                children: [
                  // ── Section "Trajet" ──────────────────────────────────
                  const _SectionTitle('Trajet'),
                  AppDimens.vGap12,
                  _TripCard(
                    onDepart: () =>
                        _info(context, 'Choisir entrepôt départ — à venir'),
                    onArrivee: () =>
                        _info(context, 'Choisir entrepôt arrivée — à venir'),
                  ),
                  AppDimens.vGap24,

                  // ── Section "Marchandise à transporter" ───────────────
                  const _SectionTitle('Marchandise à transporter'),
                  AppDimens.vGap12,
                  const _FieldLabel('Lot / produit'),
                  const SizedBox(height: 6),
                  _SelectorRow(
                    icon: Icons.inventory_2_outlined,
                    title: 'LOT-2026-0142',
                    subtitle: 'Maïs blanc · 500 kg',
                    chevron: Icons.keyboard_arrow_down,
                    onTap: () => _info(context, 'Choisir un lot — à venir'),
                  ),
                  const SizedBox(height: 14),
                  const _FieldLabel('Date souhaitée'),
                  const SizedBox(height: 6),
                  _DateSelector(
                    onTap: () =>
                        _info(context, 'Choisir une date — à venir'),
                  ),
                  AppDimens.vGap24,

                  // ── Section "Estimation de prix" ──────────────────────
                  const _SectionTitle('Estimation de prix'),
                  AppDimens.vGap12,
                  const _PriceCard(),
                  AppDimens.vGap24,

                  // ── Section "Transporteurs disponibles" ───────────────
                  const _CountHead(
                    titre: 'Transporteurs disponibles près de toi',
                    count: '(4)',
                  ),
                  AppDimens.vGap12,
                  for (final t in _kTransporteurs)
                    _TransporteurCard(
                      transporteur: t,
                      onDemander: () => _info(
                        context,
                        'Demande envoyée à ${t.nom}',
                      ),
                    ),
                ],
              ),
            ),
            _StickyButton(
              onTap: () => Snackbars.showSucces(
                context,
                'Demande publiée à tous les transporteurs',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────

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
                : context.go(RouteNames.cooperativeLogistiquePath),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Demander un transport',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Trouve un transporteur disponible',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: _kBrChip12,
            ),
            child: Text(
              'Étape 1/2',
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

// ─── Section title / Field label ──────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelMedium.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _CountHead extends StatelessWidget {
  const _CountHead({required this.titre, required this.count});

  final String titre;
  final String count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            titre,
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          count,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─── Trip card (départ + dotted + arrivée + distance) ────────────────────

class _TripCard extends StatelessWidget {
  const _TripCard({required this.onDepart, required this.onArrivee});

  final VoidCallback onDepart;
  final VoidCallback onArrivee;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard14,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        children: [
          _TripRow(
            color: AppColors.primary,
            label: 'Départ',
            value: 'Entrepôt Abidjan-Treichville',
            onTap: onDepart,
          ),
          const _DottedConnector(),
          _TripRow(
            color: _kPinArrival,
            label: 'Arrivée',
            value: 'Entrepôt Bouaké',
            onTap: onArrivee,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.schedule,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Distance estimée : 235 km · 3h30',
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
        ],
      ),
    );
  }
}

class _TripRow extends StatelessWidget {
  const _TripRow({
    required this.color,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final Color color;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 18,
            color: AppColors.textSubtle,
          ),
        ],
      ),
    );
  }
}

class _DottedConnector extends StatelessWidget {
  const _DottedConnector();

  @override
  Widget build(BuildContext context) {
    // Trait vertical pointillé 24px de hauteur, aligné sur le centre des pins.
    return SizedBox(
      height: 24,
      child: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            6,
            (i) => Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 1.5,
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  color: i.isEven
                      ? AppColors.borderStrong
                      : Colors.transparent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Selectors ────────────────────────────────────────────────────────────

class _SelectorRow extends StatelessWidget {
  const _SelectorRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.chevron,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final IconData chevron;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: _kBrCard12,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: _kBrCard12,
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
              decoration: const BoxDecoration(
                color: _kPrimarySoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(chevron, size: 18, color: AppColors.textSubtle),
          ],
        ),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SelectorRow(
      icon: Icons.calendar_today_outlined,
      title: 'Vendredi 18/05',
      subtitle: 'Créneau matinée',
      chevron: Icons.keyboard_arrow_down,
      onTap: onTap,
    );
  }
}

// ─── Price card ───────────────────────────────────────────────────────────

class _PriceCard extends StatelessWidget {
  const _PriceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: _kBrCard14,
        border: Border.all(color: _kPrimarySoft, width: AppDimens.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fourchette indicative',
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '18 000 – 25 000 F',
            style: AppTextStyles.titleLarge.copyWith(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Basé sur le tarif moyen Abidjan-Bouaké pour 500 kg',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Transporteur card ────────────────────────────────────────────────────

class _TransporteurCard extends StatelessWidget {
  const _TransporteurCard({
    required this.transporteur,
    required this.onDemander,
  });

  final _Transporteur transporteur;
  final VoidCallback onDemander;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: _kBrCard14,
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            _Avatar(t: transporteur),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          transporteur.nom,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleSmall.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.star,
                        size: 11,
                        color: _kStarYellow,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        transporteur.note.toString(),
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          transporteur.capacite,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: AppColors.textSubtle,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          transporteur.style,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (transporteur.dispoToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: const BoxDecoration(
                      color: _kPrimarySoft,
                      borderRadius: _kBrChip10,
                    ),
                    child: Text(
                      'Disponible',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                if (transporteur.dispoToday) const SizedBox(height: 6),
                Text(
                  transporteur.prix,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                _MiniButton(label: 'Demander', onTap: onDemander),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.t});

  final _Transporteur t;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: t.photo != null
          ? CachedNetworkImage(
              imageUrl: t.photo!,
              fit: BoxFit.cover,
              placeholder: (_, __) => const ColoredBox(color: _kPrimarySoft),
              errorWidget: (_, __, ___) => _AvatarText(label: t.initiales),
            )
          : _AvatarText(label: t.initiales),
    );
  }
}

class _AvatarText extends StatelessWidget {
  const _AvatarText({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: AppTextStyles.titleSmall.copyWith(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: _kBrChip10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: _kBrChip10,
          border: Border.all(
            color: AppColors.primary,
            width: AppDimens.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

// ─── Sticky bouton ────────────────────────────────────────────────────────

class _StickyButton extends StatelessWidget {
  const _StickyButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        14,
        AppDimens.pagePaddingH,
        12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.primary,
            side: const BorderSide(
              color: AppColors.primary,
              width: AppDimens.borderThin,
            ),
            shape: const RoundedRectangleBorder(borderRadius: _kBrCard12),
          ),
          child: Text(
            'Publier ma demande à tous',
            style: AppTextStyles.labelLarge.copyWith(
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

