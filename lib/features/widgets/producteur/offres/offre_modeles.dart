import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/enums.dart';
import '../../../../models/negociation.dart';

/// Couleurs locales partagées entre les widgets "offres reçues".
const Color kPrimarySoft = Color(0xFFE8F5E9);
const Color kWarnSoft = Color(0xFFFFF8E1);
const Color kWarn = Color(0xFFB26A00);
const Color kRedSoft = Color(0xFFFDECEA);

/// Filtre haut de page : toutes / en attente / acceptées / refusées.
enum StatusFilter { toutes, pending, accepted, refused }

/// Origine de l'offre côté FARMER : candidature entrante d'un acheteur,
/// ou proposition envoyée par le FARMER sur une annonce d'achat.
enum OffreKind { candidature, proposition }

/// Une offre côté FARMER, peu importe son type. Unifie candidature et
/// proposition pour l'affichage et le traitement.
class OffreUnifiee {
  const OffreUnifiee({
    required this.id,
    required this.kind,
    required this.quantiteKg,
    required this.prixProposeKg,
    required this.status,
    this.message,
    this.createdAt,
  });

  final String id;
  final OffreKind kind;
  final double quantiteKg;
  final double prixProposeKg;
  final NegotiationStatus status;
  final String? message;
  final DateTime? createdAt;

  factory OffreUnifiee.fromCandidature(Candidature c) => OffreUnifiee(
        id: c.id,
        kind: OffreKind.candidature,
        quantiteKg: c.quantiteKg,
        prixProposeKg: c.prixProposeKg,
        status: c.status,
        message: c.message,
        createdAt: c.createdAt,
      );

  factory OffreUnifiee.fromProposition(Proposition p) => OffreUnifiee(
        id: p.id,
        kind: OffreKind.proposition,
        quantiteKg: p.quantiteKg,
        prixProposeKg: p.prixProposeKg,
        status: p.status,
        message: p.message,
        createdAt: p.createdAt,
      );
}

/// Bundle des offres reçues : candidatures entrantes (acheteurs ayant
/// candidaté sur les annonces de vente du FARMER) + propositions sortantes
/// (le FARMER a proposé sur des annonces d'achat) que le buyer a traitées.
class OffresBundle {
  const OffresBundle({required this.offres});
  final List<OffreUnifiee> offres;
}

/// Formateur "1 234 F" partagé entre les cartes d'offres.
final nfOffres = NumberFormat('#,##0', 'fr_FR');
