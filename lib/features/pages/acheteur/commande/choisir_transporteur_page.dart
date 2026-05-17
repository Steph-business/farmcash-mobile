import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/snackbars.dart';

// ─── Constantes ────────────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarnSoft = Color(0xFFFEF3C7);
const Color _kWarn = Color(0xFFB45309);

// ─── Mock transporteurs ────────────────────────────────────────────────

enum _Badge { meilleurPrix, plusRapide, none }

class _MockTransporteur {
  const _MockTransporteur({
    required this.id,
    required this.nom,
    required this.photoUrl,
    required this.rating,
    required this.livraisons,
    required this.capacite,
    required this.prix,
    required this.eta,
    required this.badge,
  });
  final String id;
  final String nom;
  final String photoUrl;
  final double rating;
  final int livraisons;
  final String capacite;
  final int prix;
  final String eta;
  final _Badge badge;
}

const List<_MockTransporteur> _kTransporteurs = [
  _MockTransporteur(
    id: 't-1',
    nom: 'Trans-Eburnie',
    photoUrl:
        'https://images.unsplash.com/photo-1599045118108-bf9954418b76?w=200&h=200&fit=crop&auto=format',
    rating: 4.8,
    livraisons: 142,
    capacite: 'Camion 3.5t · suffisant pour 500 kg',
    prix: 11800,
    eta: 'ETA 2h',
    badge: _Badge.meilleurPrix,
  ),
  _MockTransporteur(
    id: 't-2',
    nom: 'Logi-Plus CI',
    photoUrl:
        'https://images.unsplash.com/photo-1574484284002-952d92456975?w=200&h=200&fit=crop&auto=format',
    rating: 4.6,
    livraisons: 89,
    capacite: 'Camion 3.5t · suffisant pour 500 kg',
    prix: 12500,
    eta: 'ETA 3h',
    badge: _Badge.none,
  ),
  _MockTransporteur(
    id: 't-3',
    nom: 'Express Lagunes',
    photoUrl:
        'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=200&h=200&fit=crop&auto=format',
    rating: 4.9,
    livraisons: 215,
    capacite: 'Camion 5t · suffisant pour 500 kg',
    prix: 14000,
    eta: 'ETA aujourd\'hui 14h',
    badge: _Badge.plusRapide,
  ),
  _MockTransporteur(
    id: 't-4',
    nom: 'Premium Cargo',
    photoUrl:
        'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=200&h=200&fit=crop&auto=format',
    rating: 4.7,
    livraisons: 67,
    capacite: 'Camion 8t · suffisant pour 500 kg',
    prix: 18000,
    eta: 'ETA demain matin',
    badge: _Badge.none,
  ),
];

const List<String> _kFiltres = [
  'Prix bas',
  'Note ★',
  'Plus rapide',
  'Disponible aujourd\'hui',
];

/// Choix du transporteur depuis le flow de paiement acheteur.
/// Calque sur `mockups/acheteur/choisir_transporteur.html`.
class ChoisirTransporteurPage extends StatefulWidget {
  const ChoisirTransporteurPage({super.key});

  @override
  State<ChoisirTransporteurPage> createState() =>
      _ChoisirTransporteurPageState();
}

class _ChoisirTransporteurPageState extends State<ChoisirTransporteurPage> {
  int _filtreActif = 0;

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
                  const _InfoTrip(),
                  const SizedBox(height: 14),
                  _Filters(
                    active: _filtreActif,
                    onChange: (i) => setState(() => _filtreActif = i),
                  ),
                  const SizedBox(height: 14),
                  for (final t in _kTransporteurs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TransporteurCard(transporteur: t),
                    ),
                ],
              ),
            ),
            const _StickyAutoLink(),
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
              'Choisir mon transporteur',
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

// ─── Bandeau info trajet ───────────────────────────────────────────────

class _InfoTrip extends StatelessWidget {
  const _InfoTrip();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.local_shipping_outlined,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Trajet : Yopougon → Cocody · 12 km · 500 kg Maïs blanc',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
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

// ─── Chips filtres horizontaux ─────────────────────────────────────────

class _Filters extends StatelessWidget {
  const _Filters({required this.active, required this.onChange});
  final int active;
  final ValueChanged<int> onChange;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _kFiltres.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isActive = i == active;
          return InkWell(
            onTap: () => onChange(i),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _kFiltres[i],
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.text,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Card transporteur ─────────────────────────────────────────────────

class _TransporteurCard extends StatelessWidget {
  const _TransporteurCard({required this.transporteur});
  final _MockTransporteur transporteur;

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
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo camion 60×60
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.hardEdge,
              child: CachedNetworkImage(
                imageUrl: transporteur.photoUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(color: AppColors.surfaceSoft),
                errorWidget: (_, _, _) =>
                    Container(color: AppColors.surfaceSoft),
              ),
            ),
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
                      transporteur.nom,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (transporteur.badge != _Badge.none)
                      _BadgeChip(badge: transporteur.badge),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${transporteur.rating.toStringAsFixed(1)} ★ · ${transporteur.livraisons} livraisons',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transporteur.capacite,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_nf.format(transporteur.prix)} F',
                            style: AppTextStyles.titleSmall.copyWith(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            transporteur.eta,
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => Snackbars.showSucces(
                        context,
                        '${transporteur.nom} sélectionné.',
                      ),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primary,
                            width: AppDimens.borderThin,
                          ),
                        ),
                        child: Text(
                          'Choisir',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.badge});
  final _Badge badge;
  @override
  Widget build(BuildContext context) {
    final isBest = badge == _Badge.meilleurPrix;
    final bg = isBest ? _kPrimarySoft : _kWarnSoft;
    final fg = isBest ? AppColors.primary : _kWarn;
    final label = isBest ? '🟢 Meilleur prix' : '⚡ Plus rapide';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

// ─── Sticky lien auto ──────────────────────────────────────────────────

class _StickyAutoLink extends StatelessWidget {
  const _StickyAutoLink();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      alignment: Alignment.center,
      child: InkWell(
        onTap: () => Snackbars.showInfo(
          context,
          'Mode automatique FarmCash — à venir.',
        ),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            'Préférer le mode automatique FarmCash',
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.borderStrong,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ───────────────────────────────────────────────────────────

final _nf = NumberFormat('#,##0', 'fr_FR');
