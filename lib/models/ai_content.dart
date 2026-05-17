import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_content.freezed.dart';
part 'ai_content.g.dart';

/// Actualité poussée par l'admin (filtrée selon le rôle du user).
@freezed
class NewsItem with _$NewsItem {
  const factory NewsItem({
    required String id,
    @Default('') String titre,
    String? resume,
    String? body,
    String? imageUrl,
    @Default(<String>[]) List<String> targetRoles,
    @Default(true) bool isActive,
    DateTime? publishedAt,
    DateTime? createdAt,
  }) = _NewsItem;

  factory NewsItem.fromJson(Map<String, dynamic> json) =>
      _$NewsItemFromJson(json);
}

/// Insights personnalisés pour le user (tendances prix, opportunités).
@freezed
class AiInsights with _$AiInsights {
  const factory AiInsights({
    @Default(<AiInsightItem>[]) List<AiInsightItem> tendances,
    @Default(<AiInsightItem>[]) List<AiInsightItem> alertes,
    @Default(<AiInsightItem>[]) List<AiInsightItem> opportunites,
  }) = _AiInsights;

  factory AiInsights.fromJson(Map<String, dynamic> json) =>
      _$AiInsightsFromJson(json);
}

@freezed
class AiInsightItem with _$AiInsightItem {
  const factory AiInsightItem({
    @Default('') String id,
    @Default('') String type,
    @Default('') String titre,
    String? body,
    String? severity,
    Map<String, dynamic>? data,
    DateTime? createdAt,
  }) = _AiInsightItem;

  factory AiInsightItem.fromJson(Map<String, dynamic> json) =>
      _$AiInsightItemFromJson(json);
}

/// Message dans la conversation avec l'assistant IA.
@freezed
class AiChatMessage with _$AiChatMessage {
  const factory AiChatMessage({
    @Default('') String id,
    @Default('assistant') String role,
    @Default('') String content,
    DateTime? createdAt,
  }) = _AiChatMessage;

  factory AiChatMessage.fromJson(Map<String, dynamic> json) =>
      _$AiChatMessageFromJson(json);
}
