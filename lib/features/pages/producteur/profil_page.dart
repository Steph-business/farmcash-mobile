import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/annonce_vente.dart';
import '../../../models/cooperative.dart';
import '../../../models/parcelle.dart';
import '../../../models/portefeuille.dart';
import '../../../models/produit.dart';
import '../../../models/utilisateur.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/dialog_changer_profil.dart';
import '../../widgets/communs/profil/barre_superieure_profil.dart';
import '../../widgets/communs/profil/bouton_deconnexion_profil.dart';
import '../../widgets/communs/profil/carte_identite_profil.dart';
import '../../widgets/communs/profil/changer_photo_helper.dart';
import '../../widgets/communs/profil/groupe_profil.dart';
import '../../widgets/communs/profil/photo_profil.dart';
import '../../widgets/communs/profil/pied_legal_profil.dart';
import '../../widgets/communs/profil/tuile_profil.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/communs/vue_erreur.dart';
import '../../widgets/producteur/profil/sous_textes_profil_producteur.dart';

// ─── Modèle de données agrégées ────────────────────────────────────────

class _ProfilData {
  const _ProfilData({
    required this.wallet,
    required this.parcelles,
    required this.produits,
    required this.mesAnnonces,
    required this.coopInfo,
  });

  final Portefeuille? wallet;
  final List<Parcelle> parcelles;
  final List<Produit> produits;
  final List<AnnonceVente> mesAnnonces;
  final Cooperative? coopInfo;
}

/// Charge en parallèle toutes les données nécessaires au profil producteur.
/// Chaque appel est tolérant : un échec ponctuel retourne `null`/liste vide
/// et la section concernée se masque ou affiche un fallback.
final _profilProducteurDataProvider =
    FutureProvider.autoDispose<_ProfilData>((ref) async {
  final marketplace = ref.watch(marketplaceServiceProvider);
  final finance = ref.watch(financeServiceProvider);
  final cooperatives = ref.watch(cooperativesServiceProvider);
  final user = ref.watch(currentUserProvider);
  final coopId = user?.cooperativeId;

  final results = await Future.wait<dynamic>([
    // 0 — wallet
    finance.getWallet().then<Object?>((v) => v).catchError((_) => null),
    // 1 — parcelles
    marketplace
        .listParcelles()
        .then<Object?>((v) => v)
        .catchError((_) => <Parcelle>[]),
    // 2 — catalogue produits (pour résoudre les noms des cultures)
    marketplace
        .listProduits()
        .then<Object?>((v) => v)
        .catchError((_) => <Produit>[]),
    // 3 — annonces (filtrées client-side sur farmerId)
    marketplace
        .listAnnoncesVente(limit: 50)
        .then<Object?>((v) => v)
        .catchError((_) => null),
    // 4 — info coopérative si l'utilisateur est membre
    if (coopId != null && coopId.isNotEmpty)
      cooperatives
          .getPublic(coopId)
          .then<Object?>((v) => v)
          .catchError((_) => null),
  ]);

  final walletBundle = results[0];
  final parcelles = (results[1] as List<Parcelle>?) ?? const <Parcelle>[];
  final produits = (results[2] as List<Produit>?) ?? const <Produit>[];
  final annoncesRaw = results[3];
  final coopInfo = (coopId != null && coopId.isNotEmpty)
      ? results[4] as Cooperative?
      : null;

  // Filtrage client-side des annonces sur l'utilisateur courant.
  final farmerId = user?.id;
  final List<AnnonceVente> mesAnnonces = [];
  if (annoncesRaw != null && farmerId != null) {
    try {
      final data = (annoncesRaw as dynamic).data as List;
      for (final a in data) {
        if (a is AnnonceVente && a.farmerId == farmerId) {
          mesAnnonces.add(a);
        }
      }
    } catch (_) {
      // payload inattendu — on garde la liste vide
    }
  }

  return _ProfilData(
    wallet: walletBundle == null
        ? null
        : (walletBundle as dynamic).wallet as Portefeuille?,
    parcelles: parcelles,
    produits: produits,
    mesAnnonces: mesAnnonces,
    coopInfo: coopInfo,
  );
});

// ─── Page principale ───────────────────────────────────────────────────

/// Onglet Profil du producteur — pattern iOS Settings : chaque row est un
/// label + chevron, on tape pour ouvrir le détail (SnackBar pour V1).
/// Seule exception : le solde wallet montre le montant à droite.
class ProfilProducteurPage extends ConsumerWidget {
  /// Crée la page profil producteur.
  const ProfilProducteurPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final async = ref.watch(_profilProducteurDataProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BarreSuperieureProfil(
              onParametres: () =>
                  context.push(RouteNames.producteurProfilSettingsPath),
            ),
            Expanded(
              child: async.when(
                loading: () => const Chargement(size: 22),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.space16),
                  child: VueErreur(
                    message: 'Impossible de charger votre profil. $err',
                    onRetry: () =>
                        ref.invalidate(_profilProducteurDataProvider),
                  ),
                ),
                data: (data) => _ContenuProfilProducteur(
                  user: user,
                  data: data,
                  onLogout: () async {
                    await ref.read(authStateProvider.notifier).logout();
                    if (context.mounted) {
                      context.go(RouteNames.bienvenuePath);
                    }
                  },
                  onChangerPhoto: () => changerPhotoProfil(context, ref),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Contenu principal scrollable ──────────────────────────────────────

class _ContenuProfilProducteur extends StatelessWidget {
  const _ContenuProfilProducteur({
    required this.user,
    required this.data,
    required this.onLogout,
    required this.onChangerPhoto,
  });

  final Utilisateur? user;
  final _ProfilData data;
  final VoidCallback onLogout;
  final VoidCallback onChangerPhoto;

  @override
  Widget build(BuildContext context) {
    final nom = user?.fullName?.trim().isNotEmpty == true
        ? user!.fullName!.trim()
        : 'Producteur';

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space16,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      children: [
        // 2 — Carte d'identité
        CarteIdentiteProfil(
          nom: nom,
          initiales: initialesProfilDepuisNom(user?.fullName),
          photoUrl: user?.photoUrl,
          sousLigne:
              sousLigneIdentiteProducteur(rating: user?.rating ?? 0),
          onModifier: () =>
              context.push(RouteNames.producteurProfilEditerPath),
          onEditPhoto: onChangerPhoto,
        ),
        AppDimens.vGap24,

        // 3 — Mon exploitation
        GroupeProfil(
          titre: 'Mon exploitation',
          enfants: [
            TuileProfil(
              icone: Icons.grass_outlined,
              accent: true,
              label: 'Mes parcelles & cultures',
              sousTitre: sousTexteParcellesProducteur(data.parcelles),
              onTap: () =>
                  context.push(RouteNames.producteurMesParcellesPath),
            ),
            TuileProfil(
              icone: Icons.eco_outlined,
              accent: true,
              label: 'Cultures principales',
              sousTitre: sousTexteCulturesProducteur(
                data.parcelles,
                data.produits,
              ),
              onTap: () =>
                  context.push(RouteNames.producteurMesParcellesPath),
            ),
            TuileProfil(
              icone: Icons.groups_outlined,
              accent: true,
              label: 'Ma coopérative',
              sousTitre: sousTexteCoopProducteur(data.coopInfo),
              onTap: () => data.coopInfo == null
                  ? Snackbars.showInfo(
                      context,
                      'Rejoindre une coopérative — à venir',
                    )
                  : context.push(RouteNames.producteurCooperativePath),
            ),
          ],
        ),
        AppDimens.vGap24,

        // 4 — Finance
        GroupeProfil(
          titre: 'Finance',
          enfants: [
            TuileProfil(
              icone: Icons.account_balance_wallet_outlined,
              accent: true,
              label: 'Mon wallet',
              trailingTexte:
                  formatMontantProducteur(data.wallet?.balance ?? 0),
              onTap: () => context.push(RouteNames.producteurWalletPath),
            ),
            TuileProfil(
              icone: Icons.credit_card_outlined,
              label: 'Moyens de paiement',
              onTap: () => context.push(RouteNames.moyensPaiementPath),
            ),
            TuileProfil(
              icone: Icons.show_chart,
              label: 'Mes transactions',
              onTap: () => context.push(RouteNames.producteurWalletPath),
            ),
          ],
        ),
        AppDimens.vGap24,

        // 5 — Activité
        GroupeProfil(
          titre: 'Activité',
          enfants: [
            TuileProfil(
              icone: Icons.list_alt_outlined,
              label: 'Mes annonces',
              sousTitre: sousTexteAnnoncesProducteur(data.mesAnnonces),
              onTap: () =>
                  context.push(RouteNames.producteurMesPublicationsPath),
            ),
            TuileProfil(
              icone: Icons.cloud_upload_outlined,
              label: 'Documents (KYC)',
              sousTitre: 'À compléter',
              onTap: () =>
                  context.push(RouteNames.producteurDocumentsKycPath),
            ),
          ],
        ),
        AppDimens.vGap24,

        // 6 — Paramètres
        GroupeProfil(
          titre: 'Paramètres',
          enfants: [
            TuileProfil(
              icone: Icons.language,
              label: 'Langue',
              trailingTexte: 'Français',
              onTap: () => context.push(RouteNames.languePath),
            ),
            TuileProfil(
              icone: Icons.notifications_none,
              label: 'Notifications',
              onTap: () =>
                  context.push(RouteNames.notificationsPreferencesPath),
            ),
            TuileProfil(
              icone: Icons.lock_outline,
              label: 'Sécurité (PIN, sessions)',
              onTap: () => context.push(RouteNames.securitePath),
            ),
            // V1 : un user = un rôle. Dialog explicatif + 2 alternatives.
            TuileProfil(
              icone: Icons.swap_horiz_rounded,
              label: 'Changer de profil',
              sousTitre: 'Acheteur · Producteur · Coopérative',
              onTap: () => showDialogChangerProfil(context),
            ),
          ],
        ),
        AppDimens.vGap24,

        // 7 — Aide & légal
        GroupeProfil(
          titre: 'Aide & légal',
          enfants: [
            TuileProfil(
              icone: Icons.help_outline,
              label: "Centre d'aide",
              onTap: () => context.push(RouteNames.aidePath),
            ),
            TuileProfil(
              icone: Icons.gavel_rounded,
              label: 'Légal et confidentialité',
              sousTitre: 'CGU, CGV, Privacy, Mentions',
              onTap: () => context.push(RouteNames.legalPath),
            ),
            TuileProfil(
              icone: Icons.download_rounded,
              label: 'Exporter mes données',
              onTap: () => context.push(RouteNames.exporterDonneesPath),
            ),
            TuileProfil(
              icone: Icons.delete_outline,
              label: 'Supprimer mon compte',
              accent: true,
              onTap: () => context.push(RouteNames.supprimerComptePath),
            ),
          ],
        ),
        AppDimens.vGap12,

        // 8 — Bouton déconnexion
        BoutonDeconnexionProfil(onTap: onLogout),
        AppDimens.vGap16,

        // 9 — Légal footer
        const Center(child: PiedLegalProfil()),
        AppDimens.vGap16,
      ],
    );
  }
}
