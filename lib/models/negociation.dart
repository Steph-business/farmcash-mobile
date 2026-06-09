import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';
import 'enums.dart';

part 'negociation.freezed.dart';
part 'negociation.g.dart';

/// Offre d'un BUYER sur une annonce de vente.
@freezed
class Candidature with _$Candidature {
  const factory Candidature({
    required String id,
    required String annonceId,
    required String buyerId,
    @FlexDouble() required double quantiteKg,
    @FlexDouble() required double prixProposeKg,
    @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
    @Default(NegotiationStatus.unknown)
    NegotiationStatus status,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Candidature;

  factory Candidature.fromJson(Map<String, dynamic> json) =>
      _$CandidatureFromJson(json);
}

/// Proposition d'un FARMER/COOP sur une annonce d'achat.
///
/// Le backend joint `users` du vendeur (avec son rôle + cooperative_profiles
/// si applicable) pour permettre à l'acheteur de distinguer une proposition
/// COOP d'une proposition farmer individuelle. Utilisé pour afficher la
/// carte « Garanties » sur les propositions coop côté acheteur.
@freezed
class Proposition with _$Proposition {
  const Proposition._();

  const factory Proposition({
    required String id,
    required String annonceAchatId,
    required String vendeurId,
    @FlexDouble() required double quantiteKg,
    @FlexDouble() required double prixProposeKg,
    @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
    @Default(NegotiationStatus.unknown)
    NegotiationStatus status,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,

    /// Vendeur joint backend (nom, rôle, photo, rating + coop si applicable).
    /// Permet au mobile de basculer en mode « Garanties coop » dès que
    /// `vendeur?.cooperative != null`.
    @JsonKey(
      name: 'users',
      fromJson: _vendeurFromJson,
      toJson: _vendeurToJson,
    )
    VendeurProposition? vendeur,
  }) = _Proposition;

  factory Proposition.fromJson(Map<String, dynamic> json) =>
      _$PropositionFromJson(json);

  /// Raccourci : la proposition vient-elle d'une coopérative ?
  bool get isFromCooperative => vendeur?.cooperative != null;
}

/// Informations du vendeur jointes à une proposition par le backend.
/// Classe manuelle (pas freezed) — c'est de l'agrégation read-only à
/// usage UI, pas besoin de codegen.
class VendeurProposition {
  const VendeurProposition({
    required this.id,
    this.fullName,
    this.role,
    this.photoUrl,
    this.rating,
    this.cooperative,
  });

  final String id;
  final String? fullName;

  /// Rôle texte tel que renvoyé par backend (`FARMER`, `COOPERATIVE`, …).
  final String? role;

  final String? photoUrl;
  final double? rating;

  /// Profil coop si le vendeur EST une coopérative — null sinon.
  final CooperativeApercu? cooperative;
}

/// Aperçu minimal d'une coopérative (joint sur une proposition).
class CooperativeApercu {
  const CooperativeApercu({
    required this.id,
    required this.nom,
    this.nbMembres = 0,
  });
  final String id;
  final String nom;
  final int nbMembres;
}

VendeurProposition? _vendeurFromJson(dynamic raw) {
  if (raw is! Map) return null;
  final m = raw.cast<String, dynamic>();
  final rating = m['rating'];
  final coopRaw = m['cooperative_profiles'];
  CooperativeApercu? coop;
  if (coopRaw is Map) {
    final c = coopRaw.cast<String, dynamic>();
    coop = CooperativeApercu(
      id: c['id'] as String? ?? '',
      nom: c['nom'] as String? ?? 'Coopérative',
      nbMembres: c['nb_membres'] is num
          ? (c['nb_membres'] as num).toInt()
          : 0,
    );
  }
  return VendeurProposition(
    id: m['id'] as String? ?? '',
    fullName: m['full_name'] as String?,
    role: m['role'] as String?,
    photoUrl: m['photo_url'] as String?,
    rating: rating is num
        ? rating.toDouble()
        : (rating is String ? double.tryParse(rating) : null),
    cooperative: coop,
  );
}

Map<String, dynamic>? _vendeurToJson(VendeurProposition? v) {
  if (v == null) return null;
  return {
    'id': v.id,
    if (v.fullName != null) 'full_name': v.fullName,
    if (v.role != null) 'role': v.role,
    if (v.photoUrl != null) 'photo_url': v.photoUrl,
    if (v.rating != null) 'rating': v.rating,
    if (v.cooperative != null)
      'cooperative_profiles': {
        'id': v.cooperative!.id,
        'nom': v.cooperative!.nom,
        'nb_membres': v.cooperative!.nbMembres,
      },
  };
}

/// Résultat des endpoints `PUT /negotiation/{candidatures|propositions|
/// contre-offres-coop}/:id/traiter`.
///
/// Le backend NE retourne PAS la négociation complète — il retourne un
/// petit objet récap : un message à afficher + l'`id` (et la référence)
/// de la commande créée si l'action a déclenché sa création
/// (cas `ACCEPTED`). Côté UI on s'en sert pour informer l'utilisateur
/// et éventuellement naviguer vers la nouvelle commande.
///
/// Avant 2026-05-27 le mobile tentait de désérialiser ce payload comme
/// `Candidature` / `Proposition` / `ContreOffreCoop` → crash
/// CheckedFromJsonException sur `id` manquant.
@freezed
class TraitementNegociationResultat with _$TraitementNegociationResultat {
  const factory TraitementNegociationResultat({
    @Default('') String message,
    String? commandeId,
    String? reference,
  }) = _TraitementNegociationResultat;

  factory TraitementNegociationResultat.fromJson(Map<String, dynamic> json) =>
      _$TraitementNegociationResultatFromJson(json);
}

/// Contre-offre BUYER sur une publication coop.
@freezed
class ContreOffreCoop with _$ContreOffreCoop {
  const factory ContreOffreCoop({
    required String id,
    required String publicationCoopId,
    required String buyerId,
    @FlexDouble() required double quantiteKg,
    @FlexDouble() required double prixProposeKg,
    @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
    @Default(NegotiationStatus.unknown)
    NegotiationStatus status,
    String? message,
    DateTime? createdAt,
  }) = _ContreOffreCoop;

  factory ContreOffreCoop.fromJson(Map<String, dynamic> json) =>
      _$ContreOffreCoopFromJson(json);
}
