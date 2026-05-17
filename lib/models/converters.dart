/// JsonConverters tolérants pour gérer les `Decimal` Prisma qui arrivent
/// sérialisés en **String** plutôt qu'en nombre.
///
/// Le backend NestJS + Prisma sérialise par défaut les colonnes `Decimal`
/// en `string` JSON (préservation de la précision). Le cast `as double`
/// généré par json_serializable plante alors avec :
///   `type 'String' is not a subtype of type 'num?'`
///
/// Ces converters acceptent à la fois `num` et `String`, et reviennent à
/// la valeur par défaut si invalide — pas de crash en runtime.
library;

import 'package:json_annotation/json_annotation.dart';

/// `double` requis — accepte num, String ou null (→ 0).
class FlexDouble implements JsonConverter<double, dynamic> {
  const FlexDouble();

  @override
  double fromJson(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  @override
  dynamic toJson(double v) => v;
}

/// `double?` — accepte num, String ou null.
class FlexDoubleN implements JsonConverter<double?, dynamic> {
  const FlexDoubleN();

  @override
  double? fromJson(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  @override
  dynamic toJson(double? v) => v;
}

/// `int` requis — accepte num, String ou null (→ 0).
class FlexInt implements JsonConverter<int, dynamic> {
  const FlexInt();

  @override
  int fromJson(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  @override
  dynamic toJson(int v) => v;
}

/// `int?` — accepte num, String ou null.
class FlexIntN implements JsonConverter<int?, dynamic> {
  const FlexIntN();

  @override
  int? fromJson(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  @override
  dynamic toJson(int? v) => v;
}
