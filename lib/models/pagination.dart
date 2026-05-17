/// Wrapper générique pour les réponses paginées du backend.
///
/// Format NestJS attendu :
/// ```json
/// {
///   "data": [...],
///   "meta": { "total": 42, "page": 1, "limit": 20, "totalPages": 3 }
/// }
/// ```
///
/// Classe plain (pas Freezed) car les génériques + json_serializable
/// avec `genericArgumentFactories` rajouteraient pas mal de boilerplate
/// pour zéro bénéfice : Paginated est un transport, jamais stocké en state.
library;

class Paginated<T> {
  final List<T> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const Paginated({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final rawData = (json['data'] as List?) ?? const [];
    final meta = (json['meta'] as Map?)?.cast<String, dynamic>() ?? const {};
    final items = rawData
        .whereType<Map>()
        .map((m) => fromItem(m.cast<String, dynamic>()))
        .toList();
    return Paginated<T>(
      data: items,
      total: (meta['total'] as num?)?.toInt() ?? items.length,
      page: (meta['page'] as num?)?.toInt() ?? 1,
      limit: (meta['limit'] as num?)?.toInt() ?? items.length,
      totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  /// Accepte soit un objet paginé `{data, meta}` soit une `List` brute.
  factory Paginated.fromJsonOrList(
    dynamic raw,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    if (raw is List) {
      final items = raw
          .whereType<Map>()
          .map((m) => fromItem(m.cast<String, dynamic>()))
          .toList();
      return Paginated<T>(
        data: items,
        total: items.length,
        page: 1,
        limit: items.length,
        totalPages: 1,
      );
    }
    if (raw is Map<String, dynamic>) {
      return Paginated.fromJson(raw, fromItem);
    }
    return Paginated<T>(
      data: const [],
      total: 0,
      page: 1,
      limit: 0,
      totalPages: 0,
    );
  }

  bool get hasMore => page < totalPages;
  bool get isEmpty => data.isEmpty;
}
