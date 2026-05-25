import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/produit.dart';
import '../../../../models/ville.dart';
import '../../../../services/providers.dart';

/// Liste des produits du référentiel marketplace — utilisée pour proposer
/// les cultures sélectionnables lors de la création/édition d'une parcelle.
final produitsParcelleProvider = FutureProvider<List<Produit>>((ref) async {
  return ref.watch(marketplaceServiceProvider).listProduits();
});

/// Liste des villes du référentiel — utilisée pour le matching automatique
/// (Nominatim → ville référentiel) et la sélection manuelle dans la sheet.
final villesParcelleProvider = FutureProvider<List<Ville>>((ref) async {
  return ref.watch(marketplaceServiceProvider).listVilles();
});

/// Top 6 cultures les plus fréquentes en Côte d'Ivoire — affichées en
/// premier dans la liste pour réduire la friction. Les autres sont
/// accessibles via "Voir toutes" / la recherche.
const kTopCulturesCI = <String>[
  'Maïs',
  'Manioc',
  'Banane plantain',
  'Tomate',
  'Arachide',
  'Riz',
];
