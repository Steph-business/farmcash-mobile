import 'package:flutter/material.dart';

/// Vert pale utilise pour les surfaces actives/bio dans le catalogue
/// traitements.
const Color kPrimarySoftCatalogueTraitements = Color(0xFFE8F5E9);

/// Types de traitement alignes sur l'enum backend `TreatmentType` :
/// FONGICIDE / INSECTICIDE / HERBICIDE / ENGRAIS / BIO_STIMULANT / AUTRE.
///
/// Le filtre "BIO" (agriculture biologique, marqueur transversal) est
/// gere separement via `is_bio=true` cote toggle, pas via `type` (les
/// anciennes valeurs BIO/CHIMIQUE/NATUREL n'existent pas backend -> 400).
enum FilterTypeCatalogueTraitements {
  tous,
  fongicide,
  insecticide,
  herbicide,
  engrais,
  bioStimulant,
  autre,
}

/// Conversion du filtre UI vers la valeur backend `TreatmentType` (ou
/// `null` pour "tous", ce qui n'envoie pas le filtre).
String? filterTypeToApiCatalogueTraitements(
    FilterTypeCatalogueTraitements type) {
  return switch (type) {
    FilterTypeCatalogueTraitements.tous => null,
    FilterTypeCatalogueTraitements.fongicide => 'FONGICIDE',
    FilterTypeCatalogueTraitements.insecticide => 'INSECTICIDE',
    FilterTypeCatalogueTraitements.herbicide => 'HERBICIDE',
    FilterTypeCatalogueTraitements.engrais => 'ENGRAIS',
    FilterTypeCatalogueTraitements.bioStimulant => 'BIO_STIMULANT',
    FilterTypeCatalogueTraitements.autre => 'AUTRE',
  };
}
