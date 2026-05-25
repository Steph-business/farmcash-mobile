import 'package:flutter/material.dart';

import 'tuile_methode_paiement.dart';

/// Identifiants logiques des méthodes de paiement supportées dans les pages
/// Recharger. Conservé en dehors des pages pour garder le catalogue
/// commun ; chaque profil compose ensuite son catalogue (notamment pour
/// renseigner son propre numéro Orange Money lié).
enum MethodePaiementId { orangeMoney, mtnMomo, moovMoney, wave, carteBancaire }

/// Construit le catalogue des méthodes affichées sur la page Recharger.
/// Le seul paramètre variant entre profils est le numéro Orange Money lié
/// (les autres méthodes restent par défaut non liées dans la maquette).
///
/// [waveSousTitre] peut être surchargé pour l'acheteur qui affiche
/// `07 88 99 11 22` au lieu de « Aucun compte lié ».
Map<MethodePaiementId, MethodePaiementSpec> catalogueMethodes({
  required String numeroOmLie,
  String waveSousTitre = 'Aucun compte lié',
}) {
  return {
    MethodePaiementId.orangeMoney: MethodePaiementSpec(
      code: 'OM',
      nom: 'Orange Money',
      sousTitre: numeroOmLie,
      logoBg: const Color(0xFFFF6B00),
      logoFg: Colors.white,
      lie: true,
      apiId: 'om-mock',
    ),
    MethodePaiementId.mtnMomo: const MethodePaiementSpec(
      code: 'MTN',
      nom: 'MTN MoMo',
      sousTitre: 'Aucun compte lié',
      logoBg: Color(0xFFFFCC00),
      logoFg: Color(0xFF111827),
      lie: false,
      apiId: 'mtn-mock',
    ),
    MethodePaiementId.moovMoney: const MethodePaiementSpec(
      code: 'MV',
      nom: 'Moov Money',
      sousTitre: 'Aucun compte lié',
      logoBg: Color(0xFF0066CC),
      logoFg: Colors.white,
      lie: false,
      apiId: 'moov-mock',
    ),
    MethodePaiementId.wave: MethodePaiementSpec(
      code: 'WV',
      nom: 'Wave',
      sousTitre: waveSousTitre,
      logoBg: const Color(0xFF1DC4E9),
      logoFg: Colors.white,
      lie: false,
      apiId: 'wave-mock',
    ),
    MethodePaiementId.carteBancaire: const MethodePaiementSpec(
      code: 'CB',
      nom: 'Carte bancaire',
      sousTitre: 'Visa / Mastercard',
      logoBg: Color(0xFF111827),
      logoFg: Colors.white,
      lie: false,
      apiId: 'card-mock',
    ),
  };
}
