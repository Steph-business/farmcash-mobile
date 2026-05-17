import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/snackbars.dart';

// ─── COULEURS LOCALES (alignées sur la maquette) ────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

// Chips type émetteur — strictement conformes au mockup HTML.
const Color _kChipFarmerBg = Color(0xFFFFF7E6);
const Color _kChipFarmerFg = Color(0xFF92400E);
const Color _kChipBuyerBg = Color(0xFFEFF6FF);
const Color _kChipBuyerFg = Color(0xFF1E40AF);

// Radius des cards (14 — comme la maquette).
const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(14));

/// Type d'émetteur — pilote la couleur du chip dans le header de la card.
enum _EmetteurType { coop, farmer, buyer }

/// Modèle local pour une demande mock — calqué sur la maquette HTML.
class _MockDemande {
  final String id;
  final String avatarUrl;
  final String nom;
  final _EmetteurType type;
  final String trajet;
  final String km;
  final String photoCargoUrl;
  final String marchandiseTitre;
  final String marchandiseDetail;
  final String prix;
  final String dateDemandee;

  const _MockDemande({
    required this.id,
    required this.avatarUrl,
    required this.nom,
    required this.type,
    required this.trajet,
    required this.km,
    required this.photoCargoUrl,
    required this.marchandiseTitre,
    required this.marchandiseDetail,
    required this.prix,
    required this.dateDemandee,
  });
}

/// 4 cards mock alignées 1:1 sur `mockups/transporteur/demandes_entrantes.html`.
const List<_MockDemande> _kMockDemandes = [
  _MockDemande(
    id: 'demande-coop',
    avatarUrl:
        'https://images.unsplash.com/photo-1488459716781-31db52582fe9'
        '?w=200&h=200&fit=crop&auto=format',
    nom: 'COOP Yopougon',
    type: _EmetteurType.coop,
    trajet: 'Yopougon → Cocody',
    km: '12 km',
    photoCargoUrl:
        'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716'
        '?w=200&h=200&fit=crop&auto=format',
    marchandiseTitre: '500 kg Maïs',
    marchandiseDetail: 'charge 2.5 t requise',
    prix: '+18 500 F',
    dateDemandee: "Aujourd'hui 14h",
  ),
  _MockDemande(
    id: 'demande-aya',
    avatarUrl:
        'https://images.unsplash.com/photo-1531123897727-8f129e1688ce'
        '?w=200&h=200&fit=crop&auto=format',
    nom: "Aya N'Guessan",
    type: _EmetteurType.farmer,
    trajet: 'Bingerville → Adjamé',
    km: '22 km',
    photoCargoUrl:
        'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31'
        '?w=200&h=200&fit=crop&auto=format',
    marchandiseTitre: '120 kg Tomate',
    marchandiseDetail: 'charge 500 kg requise',
    prix: '+8 200 F',
    dateDemandee: "Aujourd'hui 16h",
  ),
  _MockDemande(
    id: 'demande-industries',
    avatarUrl:
        'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2'
        '?w=200&h=200&fit=crop&auto=format',
    nom: 'Industries Agricoles SARL',
    type: _EmetteurType.buyer,
    trajet: 'Sassandra → Treichville',
    km: '235 km',
    photoCargoUrl:
        'https://images.unsplash.com/photo-1574484284002-952d92456975'
        '?w=200&h=200&fit=crop&auto=format',
    marchandiseTitre: '800 kg Manioc',
    marchandiseDetail: 'charge 3 t requise',
    prix: '+42 000 F',
    dateDemandee: 'Demain 7h',
  ),
  _MockDemande(
    id: 'demande-marie',
    avatarUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80'
        '?w=200&h=200&fit=crop&auto=format',
    nom: 'Marie Yao',
    type: _EmetteurType.buyer,
    trajet: 'Yamoussoukro → Abidjan',
    km: '240 km',
    photoCargoUrl:
        'https://images.unsplash.com/photo-1574484284002-952d92456975'
        '?w=200&h=200&fit=crop&auto=format',
    marchandiseTitre: '300 kg Igname',
    marchandiseDetail: 'charge 1 t requise',
    prix: '+24 000 F',
    dateDemandee: 'Demain 9h',
  ),
];

/// Page "Demandes de transport" — liste des demandes entrantes reçues par
/// un transporteur. Reproduction fidèle de
/// `mockups/transporteur/demandes_entrantes.html`.
///
/// Mock-first : aucun endpoint dédié côté backend pour V1. La liste vit
/// statiquement et chaque action (Accepter / Refuser) déclenche un
/// snackbar discret.
class DemandesEntrantesPage extends ConsumerStatefulWidget {
  const DemandesEntrantesPage({super.key});

  @override
  ConsumerState<DemandesEntrantesPage> createState() =>
      _DemandesEntrantesPageState();
}

class _DemandesEntrantesPageState
    extends ConsumerState<DemandesEntrantesPage> {
  late List<_MockDemande> _demandes;

  @override
  void initState() {
    super.initState();
    _demandes = List<_MockDemande>.from(_kMockDemandes);
  }

  void _accepter(_MockDemande d) {
    setState(() => _demandes.removeWhere((x) => x.id == d.id));
    Snackbars.showSucces(context, 'Demande de ${d.nom} acceptée');
  }

  void _refuser(_MockDemande d) {
    setState(() => _demandes.removeWhere((x) => x.id == d.id));
    Snackbars.showInfo(context, 'Demande de ${d.nom} refusée');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(count: _demandes.length),
            if (_demandes.isNotEmpty) const _Counter(),
            Expanded(
              child: _demandes.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.pagePaddingH - 4,
                        0,
                        AppDimens.pagePaddingH - 4,
                        AppDimens.space16,
                      ),
                      itemCount: _demandes.length,
                      itemBuilder: (_, i) => _DemandeCard(
                        demande: _demandes[i],
                        onAccepter: () => _accepter(_demandes[i]),
                        onRefuser: () => _refuser(_demandes[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header (back + titre + compteur) ───────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space16,
        AppDimens.space8,
        AppDimens.space16,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.canPop()
                ? context.pop()
                : context.go(RouteNames.transporteurMissionsPath),
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
              'Demandes de transport ($count)',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Compteur primary-soft ──────────────────────────────────────────────

class _Counter extends StatelessWidget {
  const _Counter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH - 4,
        14,
        AppDimens.pagePaddingH - 4,
        AppDimens.space12,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _kPrimarySoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kPrimarySoft, width: AppDimens.borderThin),
        ),
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
                Icons.place_outlined,
                size: 16,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '4 demandes près de toi',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'zone Abidjan-Yamoussoukro',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
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

// ─── Demande card ───────────────────────────────────────────────────────

class _DemandeCard extends StatelessWidget {
  const _DemandeCard({
    required this.demande,
    required this.onAccepter,
    required this.onRefuser,
  });

  final _MockDemande demande;
  final VoidCallback onAccepter;
  final VoidCallback onRefuser;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header — avatar + nom + chip type
          Row(
            children: [
              _Avatar(url: demande.avatarUrl, nom: demande.nom),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  demande.nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _ChipType(type: demande.type),
            ],
          ),
          const SizedBox(height: 10),

          // 2. Trajet
          _TrajetBox(trajet: demande.trajet, km: demande.km),
          const SizedBox(height: 10),

          // 3. Cargo (vignette 50×50 + texte)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _kPrimarySoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.border,
                    width: AppDimens.borderThin,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: demande.photoCargoUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      const ColoredBox(color: _kPrimarySoft),
                  errorWidget: (_, _, _) =>
                      const ColoredBox(color: _kPrimarySoft),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      demande.marchandiseTitre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      demande.marchandiseDetail,
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
            ],
          ),
          const SizedBox(height: 10),

          // 4. Prix + date demandée (séparateur top)
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        demande.prix,
                        style: AppTextStyles.titleLarge.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Négociable',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'DATE DEMANDÉE',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      demande.dateDemandee,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 5. Actions
          Row(
            children: [
              Expanded(
                flex: 10,
                child: _BtnRefuse(onTap: onRefuser),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 14,
                child: _BtnAccept(onTap: onAccepter),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Avatar ─────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.nom});

  final String url;
  final String nom;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
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
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, _) => const ColoredBox(color: _kPrimarySoft),
        errorWidget: (_, _, _) => Center(
          child: Text(
            _initiales(nom),
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Chip type émetteur ─────────────────────────────────────────────────

class _ChipType extends StatelessWidget {
  const _ChipType({required this.type});

  final _EmetteurType type;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (type) {
      _EmetteurType.coop => ('Coop', _kPrimarySoft, AppColors.primary),
      _EmetteurType.farmer => ('Farmer', _kChipFarmerBg, _kChipFarmerFg),
      _EmetteurType.buyer => ('Buyer', _kChipBuyerBg, _kChipBuyerFg),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bg, width: AppDimens.borderThin),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1,
        ),
      ),
    );
  }
}

// ─── Trajet (boîte grise) ───────────────────────────────────────────────

class _TrajetBox extends StatelessWidget {
  const _TrajetBox({required this.trajet, required this.km});

  final String trajet;
  final String km;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.place_outlined,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              trajet,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            km,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Boutons Refuser / Accepter ─────────────────────────────────────────

class _BtnRefuse extends StatelessWidget {
  const _BtnRefuse({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            'Refuser',
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _BtnAccept extends StatelessWidget {
  const _BtnAccept({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary,
              width: AppDimens.borderThin,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            'Accepter',
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── État vide ──────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 40,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Aucune demande en attente',
              style: AppTextStyles.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────

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
