import 'package:freezed_annotation/freezed_annotation.dart';

import 'annonce_vente.dart';
import 'converters.dart';

part 'panier.freezed.dart';
part 'panier.g.dart';

/// Panier d'achats d'un BUYER.
///
/// Le backend expose la relation Prisma `panier_items[]` directement,
/// avec pour chaque item l'annonce jointe (`annonces_vente`).
@freezed
class Panier with _$Panier {
  const Panier._();

  const factory Panier({
    @Default('') String id,
    @Default('') String userId,
    @JsonKey(name: 'panier_items')
    @Default(<PanierItem>[])
    List<PanierItem> items,
    DateTime? createdAt,
  }) = _Panier;

  factory Panier.fromJson(Map<String, dynamic> json) => _$PanierFromJson(json);

  double get total => items.fold(0.0, (sum, it) => sum + it.sousTotal);
  int get nbArticles => items.length;
}

@freezed
class PanierItem with _$PanierItem {
  const PanierItem._();

  const factory PanierItem({
    required String id,
    @Default('') String panierId,
    required String annonceId,
    @FlexDouble() required double quantiteKg,
    @JsonKey(name: 'prix_unitaire')
    @FlexDouble()
    required double prixUnitaire,
    @JsonKey(name: 'annonces_vente') AnnonceVente? annonce,
  }) = _PanierItem;

  factory PanierItem.fromJson(Map<String, dynamic> json) =>
      _$PanierItemFromJson(json);

  double get sousTotal => quantiteKg * prixUnitaire;
  String? get annonceTitre => annonce?.produitLabel ?? annonce?.titre;
  String? get annoncePhotoUrl =>
      (annonce?.photos.isNotEmpty ?? false) ? annonce!.photos.first : null;
  String? get vendeurNom => annonce?.vendeurNom;
  String? get localisation => annonce?.localisationLabel;
}
