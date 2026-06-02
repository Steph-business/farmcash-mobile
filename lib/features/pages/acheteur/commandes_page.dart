import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_colors.dart';
import '../../widgets/acheteur/commandes/onglet_commandes_directes.dart';
import '../../widgets/acheteur/commandes/onglet_reservations.dart';
import '../../widgets/acheteur/commandes/onglets_principaux_commandes.dart';
import '../../widgets/communs/entete_page_compacte_acheteur.dart';

/// « Mes commandes » côté acheteur — page à 2 onglets :
///
///   1. **Commandes** — achats payés (en cours / livrés / etc.)
///   2. **Réservations** — précommandes sur prévisions (acompte versé)
///
/// Note : l'ancien onglet « Négociations » a été sorti dans une page
/// autonome dédiée (`/acheteur/negociations`), accessible depuis la
/// tuile sur l'accueil. Une négociation n'est pas une commande au sens
/// propre (pas de paiement, pas de livraison) — la séparer clarifie
/// l'UX et évite de mélanger 3 concepts différents sous le même titre.
class CommandesAcheteurPage extends ConsumerStatefulWidget {
  const CommandesAcheteurPage({
    this.initialTab = OngletPrincipalCommandes.commandes,
    super.key,
  });

  /// Onglet à sélectionner au montage. Permet aux deep-links et aux
  /// raccourcis d'ouvrir directement le bon flux.
  final OngletPrincipalCommandes initialTab;

  /// Convertit la valeur d'un query param `?tab=...` en enum.
  /// Retourne `commandes` par défaut si la valeur est absente ou inconnue.
  static OngletPrincipalCommandes parseTabParam(String? value) {
    switch (value) {
      case 'reservations':
        return OngletPrincipalCommandes.reservations;
      case 'commandes':
      default:
        return OngletPrincipalCommandes.commandes;
    }
  }

  @override
  ConsumerState<CommandesAcheteurPage> createState() =>
      _CommandesAcheteurPageState();
}

class _CommandesAcheteurPageState
    extends ConsumerState<CommandesAcheteurPage> {
  late OngletPrincipalCommandes _tab = widget.initialTab;

  int get _index {
    switch (_tab) {
      case OngletPrincipalCommandes.commandes:
        return 0;
      case OngletPrincipalCommandes.reservations:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageCompacteAcheteur(title: 'Commandes'),
            OngletsPrincipalCommandes(
              current: _tab,
              onSelect: (t) => setState(() => _tab = t),
            ),
            Expanded(
              child: IndexedStack(
                index: _index,
                children: const [
                  OngletCommandesDirectes(),
                  OngletReservations(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
