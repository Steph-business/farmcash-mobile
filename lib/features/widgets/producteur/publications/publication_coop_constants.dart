import 'package:flutter/material.dart';

/// Vert pale partage par les widgets de la publication coop.
const Color kPrimarySoftPublicationCoop = Color(0xFFE8F5E9);

/// Jaune pale + jaune fonce pour le statut « En cours » d'une publication
/// coop.
const Color kWarnSoftPublicationCoop = Color(0xFFFFF8E1);
const Color kWarnPublicationCoop = Color(0xFFB26A00);

/// Rayon de cadre standard des cartes (12 px) de la fiche publication
/// coop. Maintenu local pour rester independant d'un eventuel changement
/// global de `AppDimens.brCard`.
const BorderRadius kBrCardPublicationCoop =
    BorderRadius.all(Radius.circular(12));

/// Statut d'une publication coop tel qu'affiche sur la fiche detail
/// producteur.
enum PubStatusPublicationCoop { enCours, publie, vendu }
