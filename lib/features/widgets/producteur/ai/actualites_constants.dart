import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Couleur primary soft (chip categorie) — utilisee dans les widgets
/// d'actualites.
const Color kActualitesPrimarySoft = Color(0xFFE8F5E9);

/// Convertit un role backend (FARMER, BUYER, ...) en libelle FR pour le chip
/// categorie d'une actualite.
String libelleRoleActualite(String role) {
  switch (role.toUpperCase()) {
    case 'FARMER':
      return 'Producteur';
    case 'BUYER':
      return 'Acheteur';
    case 'COOPERATIVE':
      return 'Coopérative';
    case 'TRANSPORTER':
      return 'Transporteur';
    case 'ADMIN':
      return 'Admin';
    default:
      return role;
  }
}

/// Formatte une date au format "d MMMM yyyy" (fr_FR) pour affichage dans
/// les cartes d'actualites.
String formatDateActualite(DateTime? d) {
  if (d == null) return '';
  return DateFormat('d MMMM yyyy', 'fr_FR').format(d);
}
