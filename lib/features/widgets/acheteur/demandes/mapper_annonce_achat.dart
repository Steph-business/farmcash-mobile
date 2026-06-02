import '../../../../models/annonce_achat.dart';
import 'modele_demande_affichage.dart';

// ─── Photos auto par produit ───────────────────────────────────────────
//
// L'API ne renvoie pas de photo sur les annonces d'achat (le buyer ne
// joint pas de visuel). On retombe sur des photos génériques par
// produit pour donner un aperçu accrocheur dans les listes. Idem pour le
// composant `MesDemandesAcheteurPage` — c'est la même fonction.

const String _kMaisThumb =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=200&h=200&fit=crop&auto=format';
const String _kManiocThumb =
    'https://images.unsplash.com/photo-1574484284002-952d92456975?w=200&h=200&fit=crop&auto=format';
const String _kTomateThumb =
    'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31?w=200&h=200&fit=crop&auto=format';
const String _kBananeThumb =
    'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=200&h=200&fit=crop&auto=format';

/// Choisit une photo générique en fonction du nom de produit.
String thumbnailPourProduit(String produitNom) {
  final n = produitNom.toLowerCase();
  if (n.contains('manioc')) return _kManiocThumb;
  if (n.contains('tomate')) return _kTomateThumb;
  if (n.contains('banane') || n.contains('plantain')) return _kBananeThumb;
  return _kMaisThumb;
}

/// Convertit une `AnnonceAchat` (modèle API) en `ModeleDemandeAffichage`
/// (modèle UI) pour les cartes acheteur. Utilisé à la fois par
/// `MesDemandesAcheteurPage` et par l'onglet Négociations de Mes
/// commandes — d'où l'extraction dans un fichier partagé.
///
/// On préfère systématiquement les NOMS joints (`regions_ci.nom`,
/// `produits_agricoles.nom`) plutôt que les UUID. Sinon l'utilisateur
/// voyait un horrible `86738c2c-681a-472e-9a59-aa48487e8594` à la place
/// de la ville.
ModeleDemandeAffichage annonceAchatVersModeleAffichage(AnnonceAchat a) {
  // `produitLabel` est le getter qui cascade :
  //   produitNom (catalogue joint) → titre libre → "Demande".
  // Beaucoup plus robuste que `a.titre` brut qui était souvent null.
  final produit = a.produitLabel;
  // Nom de la région (depuis le join `regions_ci.nom`). Si null on
  // n'affiche tout simplement pas la ligne — mieux que « — » qui
  // ressemble à de la donnée manquante.
  final region = a.regionNom?.trim();
  return ModeleDemandeAffichage(
    id: a.id,
    produitNom: produit,
    quantite: '${a.quantiteKg.toStringAsFixed(0)} kg',
    prixMaxLabel: 'max ${a.prixMaxKg.toStringAsFixed(0)} F/kg',
    villeLabel: (region != null && region.isNotEmpty) ? region : '',
    propositions: 0,
    publieIlYa: 'publiée récemment',
    photoUrl: thumbnailPourProduit(produit),
  );
}
