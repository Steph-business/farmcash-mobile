import 'package:flutter/material.dart';

import '../../../../models/annonce_achat.dart';

/// Couleurs accent (warn-soft / coop-orange) pour la liste demandes d'achat.
const Color kPrimarySoftDemande = Color(0xFFE8F5E9);
const Color kCoopOrangeBg = Color(0xFFFFF3E0);
const Color kCoopOrangeFg = Color(0xFFE65100);
const Color kWarnSoftDemande = Color(0xFFFEF3C7);
const Color kWarnDemande = Color(0xFFB45309);

const String kMaisThumb =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=200&h=200&fit=crop&auto=format';
const String kManiocThumb =
    'https://images.unsplash.com/photo-1574484284002-952d92456975?w=200&h=200&fit=crop&auto=format';
const String kTomateThumb =
    'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31?w=200&h=200&fit=crop&auto=format';
const String kBananeThumb =
    'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=200&h=200&fit=crop&auto=format';

/// Vignette par défaut quand le produit n'est pas identifié.
const String kDefaultThumbDemande = kMaisThumb;

/// Choisit une vignette Unsplash selon le nom du produit (mots-clés).
String thumbForProduit(String produitNom) {
  final n = produitNom.toLowerCase();
  if (n.contains('manioc')) return kManiocThumb;
  if (n.contains('tomate')) return kTomateThumb;
  if (n.contains('banane') || n.contains('plantain')) return kBananeThumb;
  return kMaisThumb;
}

/// Modèle d'affichage local pour la carte d'une demande d'achat.
class MockDemande {
  final String id;
  final String buyerNom;
  final String buyerAvatar;
  final String ville;
  final bool viaCoop;
  final String produitNom;
  final String produitThumb;
  final String quantite;
  final String prixMaxLabel;

  /// Libellé valeur totale max (qté × prix max), ex: « soit max 450 000 F ».
  final String valeurTotaleLabel;
  final String publieIlYa;
  final String livraisonLabel;
  final bool urgent;

  const MockDemande({
    required this.id,
    required this.buyerNom,
    required this.buyerAvatar,
    required this.ville,
    required this.viaCoop,
    required this.produitNom,
    required this.produitThumb,
    required this.quantite,
    required this.prixMaxLabel,
    required this.valeurTotaleLabel,
    required this.publieIlYa,
    required this.livraisonLabel,
    required this.urgent,
  });
}

/// Filtre culture affiché en chip horizontal en haut de la liste.
class FiltreCulture {
  final String key;
  final String label;
  final int count;
  const FiltreCulture(this.key, this.label, this.count);
}

const List<FiltreCulture> kFiltresCultures = [
  FiltreCulture('all', 'Toutes', 8),
  FiltreCulture('mais', 'Maïs', 3),
  FiltreCulture('manioc', 'Manioc', 2),
  FiltreCulture('tomate', 'Tomate', 2),
  FiltreCulture('banane', 'Banane', 1),
];

/// Convertit une `AnnonceAchat` backend (avec ses relations jointes) en
/// modèle d'affichage local. Utilise le nom du buyer et la région réels
/// quand le back les fournit.
/// Formate un nombre en F CFA façon fr-CI : « 450 000 », « 1 250 000 ».
String _fmtNombre(double v) {
  final s = v.round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
}

MockDemande annonceAchatToMock(AnnonceAchat a) {
  final produitNom = a.produitLabel;
  final qteFmt = _fmtNombre(a.quantiteKg);
  final prixFmt = _fmtNombre(a.prixMaxKg);
  final totalFmt = _fmtNombre(a.prixMaxKg * a.quantiteKg);
  return MockDemande(
    id: a.id,
    buyerNom: a.buyerNom ?? 'Acheteur',
    buyerAvatar: a.buyer?.photoUrl ?? kDefaultThumbDemande,
    ville: a.regionNom ?? '—',
    viaCoop: a.targetCooperativeId != null,
    produitNom: produitNom,
    produitThumb: thumbForProduit(produitNom),
    // Titre affiché en gros sur la carte : « 500 kg de Maïs grain blanc ».
    quantite: '$qteFmt kg de $produitNom',
    prixMaxLabel: 'jusqu\'à $prixFmt F/kg',
    valeurTotaleLabel: 'soit max $totalFmt F',
    publieIlYa: a.createdAt != null ? 'Publié récemment' : '—',
    livraisonLabel:
        a.dateLimiteLivraison != null ? 'Livraison sous délai' : 'À convenir',
    urgent: false,
  );
}
