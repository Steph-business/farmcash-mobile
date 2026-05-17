import 'package:freezed_annotation/freezed_annotation.dart';

part 'ville.freezed.dart';
part 'ville.g.dart';

/// Ville de Côte d'Ivoire. Le backend joint la région pour éviter au
/// client un second appel quand il affiche `Ville · Région`.
@freezed
class Ville with _$Ville {
  const Ville._();

  const factory Ville({
    required String id,
    required String nom,
    required String regionId,
    @JsonKey(name: 'regions_ci', fromJson: _regionNomFromMap)
    String? regionNom,
  }) = _Ville;

  factory Ville.fromJson(Map<String, dynamic> json) => _$VilleFromJson(json);

  /// Format usuel pour affichage : « Abidjan · Abidjan » ou « Abidjan »
  /// si la région porte le même nom que la ville.
  String get displayWithRegion =>
      regionNom == null || regionNom == nom ? nom : '$nom · $regionNom';
}

/// Le backend renvoie `regions_ci: { nom: "Abidjan" }` sous une clé
/// imbriquée. On extrait juste le nom pour aplatir.
String? _regionNomFromMap(dynamic raw) {
  if (raw is Map && raw['nom'] is String) return raw['nom'] as String;
  return null;
}
