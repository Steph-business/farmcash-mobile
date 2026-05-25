import 'package:flutter/material.dart';

/// Vert pale partage par les widgets de l'assistant (avatar bot, surface
/// active, bulle assistant).
const Color kPrimarySoftAssistant = Color(0xFFE8F5E9);

/// Suggestions proposees quand la conversation est vide.
///
/// Volontairement courtes et orientees agriculture / marketplace pour
/// debloquer le premier message.
const List<String> kSuggestionsAssistant = <String>[
  'Quand semer le maïs ?',
  'Comment lutter contre la pyrale ?',
  'Quel prix pour le manioc ?',
  'Combien arroser une parcelle de tomates ?',
];
