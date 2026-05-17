import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

// ─── COULEURS & RADIUS LOCAUX (alignés sur la maquette) ─────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

const BorderRadius _kBrHero = BorderRadius.all(Radius.circular(14));
const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(14));
const BorderRadius _kBrThumbSm = BorderRadius.all(Radius.circular(8));
const BorderRadius _kBrThumbMd = BorderRadius.all(Radius.circular(10));

// Photos statiques (Unsplash — illustrations neutres alignées maquette).
const String _kPhotoMembre =
    'https://images.unsplash.com/photo-1531123897727-8f129e1688ce'
    '?w=200&h=200&fit=crop&auto=format';
const String _kPhotoParcelleNord =
    'https://images.unsplash.com/photo-1488459716781-31db52582fe9'
    '?w=200&h=200&fit=crop&auto=format';
const String _kPhotoParcelleEst =
    'https://images.unsplash.com/photo-1574484284002-952d92456975'
    '?w=200&h=200&fit=crop&auto=format';
const String _kPhotoMais =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716'
    '?w=200&h=200&fit=crop&auto=format';
const String _kPhotoManioc =
    'https://images.unsplash.com/photo-1574484284002-952d92456975'
    '?w=200&h=200&fit=crop&auto=format';
const String _kPhotoCacao =
    'https://images.unsplash.com/photo-1488459716781-31db52582fe9'
    '?w=200&h=200&fit=crop&auto=format';

/// Modèle mock pour une parcelle / contribution.
class _ParcelleMock {
  final String photo;
  final String nom;
  final String meta;
  const _ParcelleMock(this.photo, this.nom, this.meta);
}

class _ContribMock {
  final String photo;
  final String titre;
  final String date;
  final String montant;
  const _ContribMock(this.photo, this.titre, this.date, this.montant);
}

const List<_ParcelleMock> _kParcelles = [
  _ParcelleMock(_kPhotoParcelleNord, 'Parcelle Nord', '2.5 ha · Maïs, Manioc'),
  _ParcelleMock(_kPhotoParcelleEst, 'Parcelle Est', '1.8 ha · Cacao'),
];

const List<_ContribMock> _kContribs = [
  _ContribMock(_kPhotoMais, 'Maïs blanc · 250 kg', '14 mai 2026', '62 500 F'),
  _ContribMock(_kPhotoManioc, 'Manioc · 400 kg', '8 mai 2026', '80 000 F'),
  _ContribMock(_kPhotoCacao, 'Cacao · 120 kg', '2 mai 2026', '144 000 F'),
];

/// Fiche d'un membre de la coopérative (accès via la liste membres).
///
/// CRITIQUE — règle chantier 3b "anti-contournement" :
/// La coopérative voit FULL ses membres. Cet écran affiche donc :
///   • le nom complet (« Yao Konan ») partout (header, hero, …) ;
///   • le bouton « Appeler » fonctionnel ;
///   • toutes les contributions chiffrées ;
///   • le solde du wallet du membre + bouton "Verser une avance".
///
/// Cette EXCEPTION s'applique UNIQUEMENT entre la coop et SES membres.
/// Tous les autres rôles continuent de voir le nom tronqué.
class MembreDetailPage extends ConsumerWidget {
  const MembreDetailPage({super.key, required this.membreId});

  /// Identifiant du membre, conservé pour la future API
  /// (`cooperativesService.getMember(id)`).
  final String membreId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pour le mock, on garde le membre "Yao Konan" décrit par la maquette.
    // membreId sera utilisé pour brancher l'API quand elle sera prête.
    const nomComplet = 'Yao Konan';
    const ville = 'Abidjan · Treichville';
    const membreDepuis = 'Membre depuis 03/2026';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(nom: nomComplet),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  0,
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                ),
                children: [
                  // 1. Hero card : photo + nom + ville + tag "Membre depuis"
                  _HeroCard(
                    nom: nomComplet,
                    ville: ville,
                    membreDepuis: membreDepuis,
                    onAppeler: () =>
                        _snack(context, 'Appel en cours — à venir'),
                    onMessage: () =>
                        _snack(context, 'Message — à venir'),
                  ),
                  AppDimens.vGap16,

                  // 2. KPI row : Livré · Payé · Note
                  const _KpiRow(),
                  AppDimens.vGap24,

                  // 3. Section "Ses parcelles"
                  const _SectionHead(titre: 'Ses parcelles'),
                  _ParcellesCard(items: _kParcelles),
                  AppDimens.vGap16,

                  // 4. Section "Dernières contributions"
                  const _SectionHead(titre: 'Dernières contributions'),
                  _ContribsCard(items: _kContribs),
                  AppDimens.vGap16,

                  // 5. Section "Wallet du membre" — visibilité chiffrée
                  const _SectionHead(titre: 'Wallet du membre'),
                  _WalletCard(
                    solde: '25 000 F',
                    onVerserAvance: () => _snack(
                      context,
                      'Verser une avance — à venir',
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

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

// ─── Header (back + nom COMPLET du membre) ──────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.nom});

  final String nom;

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
                : context.go(RouteNames.cooperativeMembresPath),
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
              nom,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

// ─── Hero card ──────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.nom,
    required this.ville,
    required this.membreDepuis,
    required this.onAppeler,
    required this.onMessage,
  });

  final String nom;
  final String ville;
  final String membreDepuis;
  final VoidCallback onAppeler;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrHero,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        children: [
          // Photo ronde 80px (Unsplash)
          Container(
            width: 80,
            height: 80,
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
              imageUrl: _kPhotoMembre,
              fit: BoxFit.cover,
              placeholder: (_, __) => const ColoredBox(color: _kPrimarySoft),
              errorWidget: (_, __, ___) => Center(
                child: Text(
                  _initiales(nom),
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            nom,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ville,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              membreDepuis,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.phone_outlined,
                  label: 'Appeler',
                  filled: false,
                  onTap: onAppeler,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Message',
                  filled: true,
                  onTap: onMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? AppColors.onPrimary : AppColors.text;
    final bg = filled ? AppColors.primary : AppColors.background;
    final border = filled ? AppColors.primary : AppColors.border;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border, width: AppDimens.borderThin),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── KPI row (3 cards) ──────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  const _KpiRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _KpiCard(value: '1.2 t', label: 'Livré')),
        SizedBox(width: 8),
        Expanded(child: _KpiCard(value: '850K F', label: 'Payé')),
        SizedBox(width: 8),
        Expanded(child: _KpiCard(value: '4.8★', label: 'Note')),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: AppColors.text,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section head ───────────────────────────────────────────────────────

class _SectionHead extends StatelessWidget {
  const _SectionHead({required this.titre});

  final String titre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        titre,
        style: AppTextStyles.titleSmall.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Parcelles ──────────────────────────────────────────────────────────

class _ParcellesCard extends StatelessWidget {
  const _ParcellesCard({required this.items});

  final List<_ParcelleMock> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space16,
                vertical: AppDimens.space12,
              ),
              child: Row(
                children: [
                  // Thumbnail 60x60
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _kPrimarySoft,
                      borderRadius: _kBrThumbMd,
                      border: Border.all(
                        color: AppColors.border,
                        width: AppDimens.borderThin,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CachedNetworkImage(
                      imageUrl: items[i].photo,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          const ColoredBox(color: _kPrimarySoft),
                      errorWidget: (_, __, ___) =>
                          const ColoredBox(color: _kPrimarySoft),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          items[i].nom,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          items[i].meta,
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
                ],
              ),
            ),
            if (i < items.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.border,
              ),
          ],
        ],
      ),
    );
  }
}

// ─── Contributions ──────────────────────────────────────────────────────

class _ContribsCard extends StatelessWidget {
  const _ContribsCard({required this.items});

  final List<_ContribMock> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space16,
                vertical: AppDimens.space12,
              ),
              child: Row(
                children: [
                  // Thumbnail 50x50
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _kPrimarySoft,
                      borderRadius: _kBrThumbSm,
                      border: Border.all(
                        color: AppColors.border,
                        width: AppDimens.borderThin,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CachedNetworkImage(
                      imageUrl: items[i].photo,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          const ColoredBox(color: _kPrimarySoft),
                      errorWidget: (_, __, ___) =>
                          const ColoredBox(color: _kPrimarySoft),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          items[i].titre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          items[i].date,
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
                  const SizedBox(width: 8),
                  Text(
                    items[i].montant,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
            if (i < items.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.border,
              ),
          ],
        ],
      ),
    );
  }
}

// ─── Wallet ─────────────────────────────────────────────────────────────

class _WalletCard extends StatelessWidget {
  const _WalletCard({required this.solde, required this.onVerserAvance});

  final String solde;
  final VoidCallback onVerserAvance;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.space16,
              vertical: 14,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Solde',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  solde,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          Material(
            color: AppColors.primary,
            child: InkWell(
              onTap: onVerserAvance,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: Text(
                  'Verser une avance',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
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
