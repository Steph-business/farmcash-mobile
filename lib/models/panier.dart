import 'package:freezed_annotation/freezed_annotation.dart';

import 'annonce_vente.dart';
import 'converters.dart';

part 'panier.freezed.dart';
part 'panier.g.dart';

@freezed
class Panier with _$Panier {
  const Panier._();

  const factory Panier({
    @Default('') String id,
    @Default('') String userId,
    @Default(<PanierItem>[]) List<PanierItem> items,
    DateTime? updatedAt,
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
    @FlexDouble() required double prixUnitaire,
    AnnonceVente? annonce,
  }) = _PanierItem;

  factory PanierItem.fromJson(Map<String, dynamic> json) =>
      _$PanierItemFromJson(json);

  double get sousTotal => quantiteKg * prixUnitaire;
  String? get annonceTitre => annonce?.titre;
  String? get annoncePhotoUrl =>
      (annonce?.photos.isNotEmpty ?? false) ? annonce!.photos.first : null;
}
