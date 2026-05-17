import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/enums.dart';
import '../../../models/livraison.dart';
import '../../../models/portefeuille.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/vue_erreur.dart';

// ─── Constantes locales (alignées sur la maquette HTML) ──────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(14));
const BorderRadius _kBrIdentity = BorderRadius.all(Radius.circular(16));

// V1 : on n'a pas d'endpoint qui expose le type de véhicule du transporteur.
// Pour rester fidèle à la maquette, on garde un libellé statique sobre.
const String _kVehiculeStatique = 'Camion 3 t';

// V1 : taux de succès non calculable par l'API actuelle — statique.
const String _kTauxSuccesStatique = '98 %';

/// Bundle de données chargées en parallèle pour le profil transporteur.
///
/// Chaque appel est tolérant : un service en échec retourne `null`/liste
/// vide. Les sections affichées restent visibles mais les sous-textes
/// dynamiques (compteurs) sont masqués si la donnée manque.
class _ProfilTransporteurData {
  final Portefeuille? wallet;
  final List<Livraison> missions;
  final List<TransporterRoute> routes;

  const _ProfilTransporteurData({
    required this.wallet,
    required this.missions,
    required this.routes,
  });

  /// Nombre de missions effectivement livrées.
  int get nbLivrees =>
      missions.where((m) => m.status == ShipmentStatus.delivered).length;

  /// Nombre d'itinéraires marqués actifs.
  int get nbItinerairesActifs =>
      routes.where((r) => r.isActive).length;

  /// Nombre de zones uniques couvertes (union des villes d'origine et
  /// de destination de toutes les routes).
  int get nbZonesUniques {
    final ids = <String>{};
    for (final r in routes) {
      final o = r.origineVilleId.trim();
      final d = r.destinationVilleId.trim();
      if (o.isNotEmpty) ids.add(o);
      if (d.isNotEmpty) ids.add(d);
    }
    return ids.length;
  }
}

/// Charge en parallèle wallet + routes + missions du transporteur.
final profilTransporteurDataProvider =
    FutureProvider.autoDispose<_ProfilTransporteurData>((ref) async {
  final logistics = ref.watch(logisticsServiceProvider);
  final finance = ref.watch(financeServiceProvider);

  final results = await Future.wait<dynamic>([
    finance.getWallet().then<Object?>((v) => v).catchError((_) => null),
    logistics
        .listMyRoutes()
        .then<Object?>((v) => v)
        .catchError((_) => <TransporterRoute>[]),
    logistics
        .getAvailableMissions()
        .then<Object?>((v) => v)
        .catchError((_) => <Livraison>[]),
  ]);

  final walletBundle = results[0];
  final Portefeuille? wallet = walletBundle == null
      ? null
      : (walletBundle as dynamic).wallet as Portefeuille;
  final routes = (results[1] as List<TransporterRoute>?) ?? const [];
  final missions = (results[2] as List<Livraison>?) ?? const [];

  return _ProfilTransporteurData(
    wallet: wallet,
    missions: missions,
    routes: routes,
  );
});

/// Onglet Profil du transporteur — fidèle reproduction de
/// `mockups/transporteur_profil.html`. Sections label-only (icône + label
/// + chevron) : un tap déclenche un SnackBar "à venir" pour V1, sauf le
/// wallet qui affiche le montant.
class ProfilTransporteurPage extends ConsumerWidget {
  const ProfilTransporteurPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(profilTransporteurDataProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _AppBarProfil(),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger le profil.',
                    onRetry: () =>
                        ref.invalidate(profilTransporteurDataProvider),
                  ),
                ),
                data: (data) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async =>
                      ref.invalidate(profilTransporteurDataProvider),
                  child: _ContenuProfil(data: data, user: user),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── APP BAR CUSTOM ──────────────────────────────────────────────────────

class _AppBarProfil extends StatelessWidget {
  const _AppBarProfil();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Mon profil',
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _snack(context, 'Paramètres — à venir'),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: const Icon(
                Icons.settings_outlined,
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

// ─── CONTENU ─────────────────────────────────────────────────────────────

class _ContenuProfil extends ConsumerWidget {
  const _ContenuProfil({required this.data, required this.user});

  final _ProfilTransporteurData data;
  final dynamic user; // Utilisateur? — typage souple, lu via getters dynamiques

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = data.wallet?.balance ?? 0;
    final devise = data.wallet?.currency ?? 'XOF';
    final rating = (user?.rating as double?) ?? 0;
    final nbLivrees = data.nbLivrees;
    final nbZones = data.nbZonesUniques;
    final nbItineraires = data.nbItinerairesActifs;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space16,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      children: [
        // 1. Carte d'identité
        _CarteIdentite(user: user, rating: rating),
        AppDimens.vGap24,

        // 2. Stats
        _LigneStats(
          livrees: nbLivrees,
          gains: balance,
          tauxSucces: _kTauxSuccesStatique,
        ),
        AppDimens.vGap24,

        // 3. Mon véhicule
        _SectionGroup(
          titre: 'Mon véhicule',
          rows: [
            _RowTile(
              icon: Icons.local_shipping_outlined,
              iconAccent: true,
              label: 'Type de véhicule',
              onTap: () => _snack(context, 'Type de véhicule — à venir'),
            ),
            _RowTile(
              icon: Icons.confirmation_number_outlined,
              iconAccent: true,
              label: 'Immatriculation',
              onTap: () => _snack(context, 'Immatriculation — à venir'),
            ),
            _RowTile(
              icon: Icons.inventory_2_outlined,
              iconAccent: true,
              label: 'Capacité & volume',
              onTap: () => _snack(context, 'Capacité & volume — à venir'),
            ),
            _RowTile(
              icon: Icons.badge_outlined,
              iconAccent: true,
              label: 'Numéro de permis',
              onTap: () => _snack(context, 'Numéro de permis — à venir'),
            ),
          ],
        ),
        AppDimens.vGap16,

        // 4. Tarification & zones
        _SectionGroup(
          titre: 'Tarification & zones',
          rows: [
            _RowTile(
              icon: Icons.attach_money,
              label: 'Tarif par kg',
              onTap: () => _snack(context, 'Tarif par kg — à venir'),
            ),
            _RowTile(
              icon: Icons.timelapse,
              label: 'Tarif minimum',
              onTap: () => _snack(context, 'Tarif minimum — à venir'),
            ),
            _RowTile(
              icon: Icons.location_on_outlined,
              label: 'Zones couvertes',
              sub: nbZones > 0
                  ? '$nbZones zone${nbZones > 1 ? 's' : ''}'
                  : null,
              onTap: () => _snack(context, 'Zones couvertes — à venir'),
            ),
            _RowTile(
              icon: Icons.alt_route,
              label: 'Mes itinéraires',
              sub: nbItineraires > 0
                  ? '$nbItineraires actif${nbItineraires > 1 ? 's' : ''}'
                  : null,
              onTap: () => _snack(context, 'Mes itinéraires — à venir'),
            ),
          ],
        ),
        AppDimens.vGap16,

        // 5. Disponibilité (ligne avec switch)
        _SectionGroup(
          titre: 'Disponibilité',
          rows: [
            _RowTile(
              icon: Icons.event_available,
              label: 'Disponible pour livrer',
              sub: 'Les missions arrivent',
              trailing: _DisponibiliteSwitch(
                onTap: () => _snack(
                  context,
                  'Changement de disponibilité — à venir',
                ),
              ),
              showChevron: false,
              onTap: null,
            ),
          ],
        ),
        AppDimens.vGap16,

        // 6. Finance
        _SectionGroup(
          titre: 'Finance',
          rows: [
            _RowTile(
              icon: Icons.account_balance_wallet_outlined,
              iconAccent: true,
              label: 'Mon wallet',
              trailing: Padding(
                padding: const EdgeInsets.only(right: AppDimens.space8),
                child: Text(
                  _formatMontant(balance, devise),
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ),
              onTap: () => _snack(context, 'Mon wallet — à venir'),
            ),
            _RowTile(
              icon: Icons.credit_card_outlined,
              label: 'Moyens de paiement',
              onTap: () => _snack(context, 'Moyens de paiement — à venir'),
            ),
            _RowTile(
              icon: Icons.show_chart,
              label: 'Mes transactions',
              onTap: () => _snack(context, 'Mes transactions — à venir'),
            ),
          ],
        ),
        AppDimens.vGap16,

        // 7. Paramètres
        _SectionGroup(
          titre: 'Paramètres',
          rows: [
            _RowTile(
              icon: Icons.language,
              label: 'Langue',
              onTap: () => _snack(context, 'Langue — à venir'),
            ),
            _RowTile(
              icon: Icons.notifications_none,
              label: 'Notifications',
              onTap: () => _snack(context, 'Notifications — à venir'),
            ),
            _RowTile(
              icon: Icons.lock_outline,
              label: 'Sécurité (PIN, sessions)',
              onTap: () => _snack(context, 'Sécurité — à venir'),
            ),
          ],
        ),
        AppDimens.vGap16,

        // 8. Aide & légal
        _SectionGroup(
          titre: 'Aide & légal',
          rows: [
            _RowTile(
              icon: Icons.help_outline,
              label: "Centre d'aide",
              onTap: () => _snack(context, "Centre d'aide — à venir"),
            ),
            _RowTile(
              icon: Icons.description_outlined,
              label: 'Conditions & confidentialité',
              onTap: () => _snack(context, 'Conditions — à venir'),
            ),
          ],
        ),
        AppDimens.vGap8,

        // 9. Bouton "Se déconnecter"
        _BoutonDeconnexion(
          onTap: () => ref.read(authStateProvider.notifier).logout(),
        ),

        AppDimens.vGap16,

        // 10. Footer légal
        const _FooterLegal(),
      ],
    );
  }
}

// ─── CARTE D'IDENTITÉ ────────────────────────────────────────────────────

class _CarteIdentite extends StatelessWidget {
  const _CarteIdentite({required this.user, required this.rating});

  final dynamic user;
  final double rating;

  @override
  Widget build(BuildContext context) {
    final fullName = (user?.fullName as String?)?.trim();
    final nom = (fullName == null || fullName.isEmpty)
        ? 'Transporteur'
        : fullName;
    final photoUrl = user?.photoUrl as String?;
    final sousLigne = _sousLigne(rating);

    return Container(
      padding: const EdgeInsets.all(AppDimens.space16 + 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrIdentity,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          _PhotoIdentite(photoUrl: photoUrl, fullName: fullName),
          AppDimens.hGap16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nom,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  sousLigne,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          AppDimens.hGap8,
          InkWell(
            onTap: () => _snack(context, 'Modification du profil — à venir'),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space8,
                vertical: AppDimens.space4,
              ),
              child: Text(
                'Modifier',
                style: AppTextStyles.link.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _sousLigne(double rating) {
    final note = rating > 0
        ? rating.toStringAsFixed(1).replaceAll('.', ',')
        : '—';
    return 'Transporteur · $_kVehiculeStatique · ★ $note';
  }
}

class _PhotoIdentite extends StatelessWidget {
  const _PhotoIdentite({required this.photoUrl, required this.fullName});

  final String? photoUrl;
  final String? fullName;

  @override
  Widget build(BuildContext context) {
    final initiales = _initiales(fullName);
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            child: hasPhoto
                ? CachedNetworkImage(
                    imageUrl: photoUrl!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: _kPrimarySoft),
                    errorWidget: (_, __, ___) => _Initiales(text: initiales),
                  )
                : _Initiales(text: initiales),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.background,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.edit,
                size: 12,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initiales(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return '?';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _Initiales extends StatelessWidget {
  const _Initiales({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: AppTextStyles.titleLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── LIGNE STATS ─────────────────────────────────────────────────────────

class _LigneStats extends StatelessWidget {
  const _LigneStats({
    required this.livrees,
    required this.gains,
    required this.tauxSucces,
  });

  final int livrees;
  final double gains;
  final String tauxSucces;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            valeur: livrees.toString(),
            libelle: 'Livraisons',
          ),
        ),
        AppDimens.hGap8,
        Expanded(
          child: _StatCard(
            valeur: _formatCompact(gains),
            libelle: 'Gains 30 j',
          ),
        ),
        AppDimens.hGap8,
        Expanded(
          child: _StatCard(
            valeur: tauxSucces,
            libelle: 'Taux succès',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.valeur, required this.libelle});

  final String valeur;
  final String libelle;

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            valeur,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            libelle,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── SECTION GROUP ──────────────────────────────────────────────────────

class _SectionGroup extends StatelessWidget {
  const _SectionGroup({required this.titre, required this.rows});

  final String titre;
  final List<_RowTile> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppDimens.space4,
            right: AppDimens.space4,
            bottom: AppDimens.space8,
          ),
          child: Text(
            titre.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
        ),
        Container(
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
              for (var i = 0; i < rows.length; i++) ...[
                rows[i],
                if (i < rows.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.border,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── ROW TILE ───────────────────────────────────────────────────────────

class _RowTile extends StatelessWidget {
  const _RowTile({
    required this.icon,
    required this.label,
    this.sub,
    this.trailing,
    this.onTap,
    this.iconAccent = false,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final String? sub;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool iconAccent;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final iconBg = iconAccent ? _kPrimarySoft : AppColors.surfaceSoft;
    final iconColor =
        iconAccent ? AppColors.primary : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: 14,
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(AppDimens.radius),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: iconColor),
            ),
            AppDimens.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (sub != null && sub!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      sub!,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (showChevron && trailing == null) ...[
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textSubtle,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── DISPONIBILITÉ SWITCH ───────────────────────────────────────────────

class _DisponibiliteSwitch extends StatefulWidget {
  const _DisponibiliteSwitch({required this.onTap});

  /// Notifie un tap utilisateur (avant ou après changement local).
  final VoidCallback onTap;

  @override
  State<_DisponibiliteSwitch> createState() => _DisponibiliteSwitchState();
}

class _DisponibiliteSwitchState extends State<_DisponibiliteSwitch> {
  // Valeur initiale : true (statique, pas d'endpoint pour récupérer/setter).
  bool _value = true;

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: _value,
      activeThumbColor: AppColors.primary,
      onChanged: (v) {
        setState(() => _value = v);
        widget.onTap();
      },
    );
  }
}

// ─── BOUTON DÉCONNEXION ─────────────────────────────────────────────────

class _BoutonDeconnexion extends StatelessWidget {
  const _BoutonDeconnexion({required this.onTap});

  final VoidCallback onTap;

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
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.space16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout,
                size: 18,
                color: AppColors.error,
              ),
              AppDimens.hGap8,
              Text(
                'Se déconnecter',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── FOOTER LÉGAL ───────────────────────────────────────────────────────

class _FooterLegal extends StatelessWidget {
  const _FooterLegal();

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.labelSmall.copyWith(
      fontSize: 11,
      color: AppColors.textSubtle,
      fontWeight: FontWeight.w400,
      height: 1.5,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.space8),
      child: Column(
        children: [
          Text('FarmCash · v1.0.0', style: style),
          Text("Made in Côte d'Ivoire", style: style),
        ],
      ),
    );
  }
}

// ─── HELPERS ────────────────────────────────────────────────────────────

/// Formate `12500` → `12 500 F` (devise XOF uniquement, sinon le code).
String _formatMontant(double montant, String devise) {
  final formatted = NumberFormat('#,##0', 'fr_FR').format(montant);
  if (devise == 'XOF' || devise.isEmpty) {
    return '$formatted F';
  }
  return '$formatted $devise';
}

/// Format compact pour les KPI : `456000` → `456 K`. Pour les valeurs
/// inférieures à 1000, on garde la valeur entière sans suffixe.
String _formatCompact(double v) {
  if (v >= 1000) {
    return '${(v / 1000).toStringAsFixed(0)} K';
  }
  return v.toStringAsFixed(0);
}

/// SnackBar discrète "à venir".
void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
