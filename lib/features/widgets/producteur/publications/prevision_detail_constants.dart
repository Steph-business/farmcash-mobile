import 'package:flutter/material.dart';

/// Vert pâle utilisé pour les pastilles d'info et fonds de chips positifs
/// dans le détail d'une prévision producteur.
const Color kPrevisionDetailPrimarySoft = Color(0xFFE8F5E9);

/// Fond chaud (jaune doux) utilisé pour la chip "Prévision · J-X" indiquant
/// que le bien n'est pas encore en vente.
const Color kPrevisionDetailWarnSoft = Color(0xFFFFF8E1);

/// Brun chaud utilisé pour le texte de la chip de prévision (lisible sur
/// fond `kPrevisionDetailWarnSoft`).
const Color kPrevisionDetailWarn = Color(0xFFB26A00);

/// Photo de remplacement utilisée tant que les visuels par culture ne sont
/// pas branchés. Image Unsplash dérivée de la maquette d'origine.
const String kPrevisionDetailHeroFallback =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=600&h=400&fit=crop&auto=format';
