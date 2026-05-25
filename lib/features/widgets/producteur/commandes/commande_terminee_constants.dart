import 'package:flutter/material.dart';

/// Vert pâle utilisé pour la trace card et les surfaces accent positives
/// de la page « Commande livrée » producteur.
const Color kCommandeTermineePrimarySoft = Color(0xFFE8F5E9);

/// Slug par défaut affiché tant que l'API ne renvoie pas de slug de
/// traçabilité réel par commande. Conserve la fidélité à la maquette.
const String kCommandeTermineeFallbackTraceSlug = 'c89-mb500';

/// Référence par défaut affichée tant que l'API ne renvoie pas de
/// référence de commande exploitable.
const String kCommandeTermineeFallbackRef = 'C-2026-0089';

/// Photo héro par défaut (image Unsplash dérivée de la maquette d'origine)
/// utilisée dans la recap card de la page « Commande livrée ».
const String kCommandeTermineeHeroPhoto =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=600&h=300&fit=crop&auto=format';
