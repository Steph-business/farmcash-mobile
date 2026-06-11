import '../../../../models/annonce_vente.dart';
import '../../../../models/enums.dart';
import '../../../../models/publication_coop.dart';

/// Wrapper léger qui unifie une `AnnonceVente` (publication solo
/// producteur) et une `PublicationCoop` (lot agrégé par une coopérative)
/// pour les afficher ensemble dans la grille du Marché acheteur.
///
/// Sans ce wrapper, le marché acheteur n'affichait QUE les annonces
/// solo des producteurs autonomes. Les publications coop (souvent les
/// gros volumes intéressants pour les industriels) étaient invisibles
/// côté acheteur — bug majeur de découverte des coops.
///
/// L'acheteur ne se soucie pas du « qui vend » au moment de browse :
/// il veut voir des produits disponibles. Le wrapper permet la grille
/// unifiée + le tap route vers la bonne page détail.
class OffreMarche {
  const OffreMarche._({
    required this.id,
    required this.produitId,
    required this.titre,
    required this.quantiteKg,
    required this.prixParKg,
    required this.qualite,
    required this.photos,
    required this.createdAt,
    required this.isPublicationCoop,
    this.regionNom,
    this.villeNom,
    this.assignedToCooperativeId,
    this.certifications = const [],
    this.dateRecolte,
    this.annonceSource,
    this.publicationCoopSource,
  });

  factory OffreMarche.annonce(AnnonceVente a) => OffreMarche._(
        id: a.id,
        produitId: a.produitId,
        titre: a.titre,
        quantiteKg: a.quantiteKg,
        prixParKg: a.prixParKg,
        qualite: a.qualite,
        photos: a.photos,
        createdAt: a.createdAt,
        isPublicationCoop: false,
        regionNom: a.regionNom,
        villeNom: a.villeNom,
        assignedToCooperativeId: a.assignedToCooperativeId,
        certifications: a.certifications,
        dateRecolte: a.dateRecolte,
        annonceSource: a,
      );

  factory OffreMarche.publicationCoop(PublicationCoop p) => OffreMarche._(
        id: p.id,
        produitId: p.produitId,
        titre: p.titre,
        quantiteKg: p.quantiteKg,
        prixParKg: p.prixParKg,
        qualite: p.qualite,
        photos: p.photos,
        createdAt: p.createdAt,
        isPublicationCoop: true,
        // Marque comme « vendu par coop » pour l'affichage côté carte.
        // L'id de la coop n'est pas exposé sur PublicationCoop côté
        // grille publique → on met juste un flag truthy.
        assignedToCooperativeId: p.cooperativeId,
        // Première date du lot (min) comme date de récolte affichable
        // sur la carte — fraîcheur visible côté acheteur.
        dateRecolte: p.dateRecolteMin,
        publicationCoopSource: p,
      );

  final String id;
  final String produitId;
  final String titre;
  final double quantiteKg;
  final double prixParKg;
  final ProductQuality qualite;
  final List<String> photos;
  final DateTime? createdAt;
  final bool isPublicationCoop;
  final String? regionNom;
  final String? villeNom;
  final String? assignedToCooperativeId;
  final List<String> certifications;
  final DateTime? dateRecolte;

  /// Source originale (AnnonceVente) — null si c'est une publication.
  final AnnonceVente? annonceSource;

  /// Source originale (PublicationCoop) — null si c'est une annonce.
  final PublicationCoop? publicationCoopSource;
}
