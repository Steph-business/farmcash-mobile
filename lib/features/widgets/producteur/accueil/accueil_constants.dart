import 'package:flutter/material.dart';

// ─── COULEURS ACCENT (utilisées localement, conformes au mockup) ─────────

/// Vert très pâle pour les fonds doux d'accent (bulles, bannières coop,
/// avatars, bandeau conseils). Spécifique à l'accueil producteur.
const Color kAccueilPrimarySoft = Color(0xFFE8F5E9);

/// Jaune pâle pour les bulles d'action de type avertissement.
const Color kAccueilWarnSoft = Color(0xFFFFF8E1);

/// Brun-orangé pour le texte/icône des bulles d'avertissement.
const Color kAccueilWarn = Color(0xFFB26A00);

/// Rouge pâle pour les bulles d'action de type erreur.
const Color kAccueilRedSoft = Color(0xFFFDECEA);

/// Radius standard des cards de l'accueil producteur (14).
const BorderRadius kAccueilBrCard = BorderRadius.all(Radius.circular(14));

/// Radius du CTA hero "Publier ma récolte" (16 — card unique mise en avant).
const BorderRadius kAccueilBrHero = BorderRadius.all(Radius.circular(16));
