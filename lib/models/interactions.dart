import 'package:freezed_annotation/freezed_annotation.dart';

import 'utilisateur.dart';

part 'interactions.freezed.dart';
part 'interactions.g.dart';

/// Avis posté par un utilisateur sur un autre (après une commande livrée).
@freezed
class Avis with _$Avis {
  const Avis._();

  const factory Avis({
    required String id,
    required String reviewerId,
    required String reviewedUserId,
    @Default('') String contextType,
    String? contextId,
    @Default(0) int note,
    String? commentaire,
    Utilisateur? reviewer,
    DateTime? createdAt,
  }) = _Avis;

  factory Avis.fromJson(Map<String, dynamic> json) => _$AvisFromJson(json);

  String? get reviewerName => reviewer?.fullName;
  String? get reviewerPhotoUrl => reviewer?.photoUrl;
}

@freezed
class Favori with _$Favori {
  const factory Favori({
    required String id,
    required String userId,
    required String annonceId,
    DateTime? createdAt,
  }) = _Favori;

  factory Favori.fromJson(Map<String, dynamic> json) => _$FavoriFromJson(json);
}

@freezed
class Media with _$Media {
  const factory Media({
    required String id,
    required String ownerId,
    @Default('') String url,
    String? annonceId,
    String? type,
    @Default(0) int position,
    DateTime? createdAt,
  }) = _Media;

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);
}
