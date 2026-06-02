import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/annonce_achat.dart';
import '../../../models/annonce_vente.dart';
import '../../../models/pagination.dart';
import '../../../models/portefeuille.dart';
import '../../../models/utilisateur.dart';
import '../../../models/wallet_with_transactions.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../state/auth_state.dart';
import '../../widgets/acheteur/profil/sous_ligne_identite_acheteur.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/profil/barre_superieure_profil.dart';
import '../../widgets/communs/profil/bouton_deconnexion_profil.dart';
import '../../widgets/communs/profil/carte_identite_profil.dart';
import '../../widgets/communs/profil/changer_photo_helper.dart';
import '../../widgets/communs/profil/groupe_profil.dart';
import '../../widgets/communs/profil/photo_profil.dart';
import '../../widgets/communs/profil/pied_legal_profil.dart';
import '../../widgets/communs/profil/tuile_profil.dart';
import '../../widgets/communs/vue_erreur.dart';

// ─── AGRÉGAT DE DONNÉES ─────────────────────────────────────────────────

/// Données agrégées affichées sur le profil acheteur.
class _ProfilData {
  const _ProfilData({
    required this.user,
    required this.wallet,
    required this.mesDemandes,
    required this.favoris,
  });

  final Utilisateur? user;
  final Portefeuille? wallet;
  final List<AnnonceAchat> mesDemandes;
  final List<AnnonceVente> favoris;

  int get demandesActives => mesDemandes.where((d) => d.isActive).length;

  int get demandesArchivees => mesDemandes.length - demandesActives;
}

/// Provider FutureProvider.autoDispose agrégeant les 3 endpoints réseaux
/// utiles au profil acheteur. Les erreurs unitaires retombent sur des
/// valeurs neutres pour ne pas casser la page si UNE API échoue.
final _profilAcheteurDataProvider =
    FutureProvider.autoDispose<_ProfilData>((ref) async {
  final user = ref.watch(currentUserProvider);
  final marketSvc = ref.watch(marketplaceServiceProvider);
  final financeSvc = ref.watch(financeServiceProvider);

  final results = await Future.wait<Object?>([
    // 0 — wallet
    financeSvc.getWallet(limit: 1).then<Object?>((v) => v).catchError(
          (_) => null,
        ),
    // 1 — mes demandes d'achat (filtrage client-side sur buyerId)
    marketSvc.listAnnoncesAchat(limit: 50).then<Object?>((v) => v).catchError(
          (_) => const Paginated<AnnonceAchat>(
            data: [],
            total: 0,
            page: 1,
            limit: 0,
            totalPages: 0,
          ),
        ),
    // 2 — favoris (annonces de vente sauvegardées)
    marketSvc.listFavoris().then<Object?>((v) => v).catchError(
          (_) => const <AnnonceVente>[],
        ),
  ]);

  final walletRaw = results[0] as WalletWithTransactions?;
  final demandesPage = results[1] as Paginated<AnnonceAchat>;
  final favoris = results[2] as List<AnnonceVente>;

  // Filtre client-side : on ne garde que les demandes de cet utilisateur.
  final mesDemandes = user == null
      ? const <AnnonceAchat>[]
      : demandesPage.data.where((d) => d.buyerId == user.id).toList();

  return _ProfilData(
    user: user,
    wallet: walletRaw?.wallet,
    mesDemandes: mesDemandes,
    favoris: favoris,
  );
});

// ─── PAGE ───────────────────────────────────────────────────────────────

/// Onglet Profil de l'acheteur.
///
/// Reproduction fidèle de `mockups/acheteur_profil.html` :
/// carte identité, mon activité, finance (wallet/moyens/transactions),
/// préférences (favoris/adresses), paramètres, aide & légal, déconnexion.
///
/// Pattern iOS Settings : les rows ne montrent JAMAIS la valeur du champ.
/// Seule exception : le solde wallet à droite + sous-textes dynamiques
/// (X actives · Y archivées, X producteurs sauvegardés).
class ProfilAcheteurPage extends ConsumerWidget {
  /// Crée la page profil acheteur.
  const ProfilAcheteurPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(_profilAcheteurDataProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BarreSuperieureProfil(
              onParametres: () =>
                  context.push(RouteNames.acheteurProfilSettingsPath),
            ),
            Expanded(
              child: asyncData.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger le profil. $err',
                    onRetry: () =>
                        ref.invalidate(_profilAcheteurDataProvider),
                  ),
                ),
                data: (data) => _ContenuProfilAcheteur(
                  data: data,
                  onRefresh: () async {
                    ref.invalidate(_profilAcheteurDataProvider);
                    await ref.read(_profilAcheteurDataProvider.future);
                  },
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

// ─── CONTENU PRINCIPAL ──────────────────────────────────────────────────

class _ContenuProfilAcheteur extends StatelessWidget {
  const _ContenuProfilAcheteur({
    required this.data,
    required this.onRefresh,
    required this.onLogout,
    required this.onChangerPhoto,
  });

  final _ProfilData data;
  final Future<void> Function() onRefresh;
  final VoidCallback onLogout;
  final VoidCallback onChangerPhoto;

  @override
  Widget build(BuildContext context) {
    final user = data.user;
    final nom = (user?.fullName?.trim().isNotEmpty ?? false)
        ? user!.fullName!.trim()
        : 'Acheteur';

    // Calcul sous-texte "X actives · Y archivées".
    final sousDemandes =
        '${data.demandesActives} active${data.demandesActives > 1 ? 's' : ''}'
        ' · '
        '${data.demandesArchivees} archivée${data.demandesArchivees > 1 ? 's' : ''}';

    // Sous-texte favoris (masqué si 0).
    final nbFav = data.favoris.length;
    final String? sousFavoris = nbFav > 0
        ? '$nbFav producteur${nbFav > 1 ? 's' : ''} sauvegardé${nbFav > 1 ? 's' : ''}'
        : null;

    // Wallet : valeur à droite uniquement si dispo.
    final String? walletTrailing = data.wallet != null
        ? '${NumberFormat('#,##0', 'fr_FR').format(data.wallet!.balance.round())} F'
        : null;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pagePaddingH,
          AppDimens.space16,
          AppDimens.pagePaddingH,
          AppDimens.space16,
        ),
        children: [
          // 2. Carte d'identité
          CarteIdentiteProfil(
            nom: nom,
            initiales: initialesProfilDepuisNom(nom),
            photoUrl: user?.photoUrl,
            sousLigne: sousLigneIdentiteAcheteur(rating: user?.rating ?? 0),
            onModifier: () =>
                context.push(RouteNames.acheteurProfilSettingsPath),
            onEditPhoto: onChangerPhoto,
          ),
          AppDimens.vGap24,

          // 3. Section "Mon activité"
          GroupeProfil(
            titre: 'Mon activité',
            enfants: [
              TuileProfil(
                icone: Icons.business_outlined,
                accent: true,
                label: 'Mon entreprise',
                sousTitre: 'Raison sociale, RCCM, zones',
                onTap: () =>
                    context.push(RouteNames.acheteurMonEntreprisePath),
              ),
              TuileProfil(
                icone: Icons.shopping_cart_outlined,
                accent: true,
                label: "Mes demandes d'achat",
                sousTitre: sousDemandes,
                onTap: () => context.push(RouteNames.acheteurDemandesPath),
              ),
            ],
          ),
          AppDimens.vGap16,

          // 4. Section "Finance"
          GroupeProfil(
            titre: 'Finance',
            enfants: [
              TuileProfil(
                icone: Icons.account_balance_wallet_outlined,
                accent: true,
                label: 'Mon wallet',
                trailingTexte: walletTrailing,
                onTap: () => context.push(RouteNames.acheteurWalletPath),
              ),
              TuileProfil(
                icone: Icons.credit_card_outlined,
                label: 'Moyens de paiement',
                onTap: () => context.push(RouteNames.moyensPaiementPath),
              ),
              TuileProfil(
                icone: Icons.show_chart,
                label: 'Mes transactions',
                onTap: () => context.push(RouteNames.acheteurWalletPath),
              ),
            ],
          ),
          AppDimens.vGap16,

          // 5. Section "Préférences"
          GroupeProfil(
            titre: 'Préférences',
            enfants: [
              TuileProfil(
                icone: Icons.favorite_border,
                label: 'Mes favoris',
                sousTitre: sousFavoris,
                onTap: () => context.push(RouteNames.acheteurFavorisPath),
              ),
              TuileProfil(
                icone: Icons.location_on_outlined,
                label: 'Adresses de livraison',
                onTap: () =>
                    context.push(RouteNames.acheteurAdressesLivraisonPath),
              ),
            ],
          ),
          AppDimens.vGap16,

          // 6. Section "Paramètres"
          GroupeProfil(
            titre: 'Paramètres',
            enfants: [
              TuileProfil(
                icone: Icons.language,
                label: 'Langue',
                onTap: () => context.push(RouteNames.languePath),
              ),
              TuileProfil(
                icone: Icons.notifications_none,
                label: 'Notifications',
                onTap: () => context.push(
                  RouteNames.notificationsPreferencesPath,
                ),
              ),
              TuileProfil(
                icone: Icons.lock_outline,
                label: 'Sécurité (PIN, sessions)',
                onTap: () => context.push(RouteNames.securitePath),
              ),
            ],
          ),
          AppDimens.vGap16,

          // 7. Section "Aide & légal"
          GroupeProfil(
            titre: 'Aide & légal',
            enfants: [
              TuileProfil(
                icone: Icons.help_outline,
                label: "Centre d'aide",
                onTap: () => context.push(RouteNames.aidePath),
              ),
              TuileProfil(
                icone: Icons.description_outlined,
                label: 'Conditions & confidentialité',
                onTap: () => context.push(RouteNames.conditionsPath),
              ),
            ],
          ),
          AppDimens.vGap16,

          // 8. Bouton "Se déconnecter"
          BoutonDeconnexionProfil(onTap: onLogout),
          AppDimens.vGap16,

          // 9. Footer légal
          const PiedLegalProfil(),
          AppDimens.vGap16,
        ],
      ),
    );
  }
}
