import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';

part 'produit.freezed.dart';
part 'produit.g.dart';

/// Produit du catalogue agricole (maïs, manioc, riz, etc.).
@freezed
class Produit with _$Produit {
  const factory Produit({
    required String id,
    required String slug,
    required String nom,
    String? sousCategorieId,
    String? description,
    @FlexDoubleN() double? prixMarcheMin,
    @FlexDoubleN() double? prixMarcheMax,
    @Default(false) bool estSaisonnier,
    @Default(false) bool estExportable,
    String? iconUrl,
    String? imageUrl,
  }) = _Produit;

  factory Produit.fromJson(Map<String, dynamic> json) =>
      _$ProduitFromJson(json);
}

@freezed
class Categorie with _$Categorie {
  const factory Categorie({
    required String id,
    required String slug,
    required String nom,
    String? iconUrl,
    @Default(<SousCategorie>[]) List<SousCategorie> sousCategories,
  }) = _Categorie;

  factory Categorie.fromJson(Map<String, dynamic> json) =>
      _$CategorieFromJson(json);
}

@freezed
class SousCategorie with _$SousCategorie {
  const factory SousCategorie({
    required String id,
    required String categorieId,
    required String slug,
    required String nom,
  }) = _SousCategorie;

  factory SousCategorie.fromJson(Map<String, dynamic> json) =>
      _$SousCategorieFromJson(json);
}
