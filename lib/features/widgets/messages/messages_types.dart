/// Types partagés entre la page Messages et les widgets extraits.
///
/// Définis dans un fichier neutre pour éviter les imports circulaires entre
/// la page (`pages/_shared/messages_page.dart`) et les widgets enfants
/// (`widgets/messages/*.dart`).
library;

/// Filtres possibles pour la liste de conversations. Superset des 4 rôles ;
/// chaque rôle ne montre qu'un sous-ensemble (cf. `FiltresMessages._items`).
enum FiltreMessages {
  tous,
  acheteurs,
  cooperatives,
  transporteurs,
  producteurs,
  farmers, // alias coop pour producteurs
}

/// Rôle de l'interlocuteur — pilote la couleur du chip dans la tile.
enum RoleInterlocuteur { farmer, acheteur, coop, transport }
