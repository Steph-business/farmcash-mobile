import 'package:flutter/material.dart';

/// Constantes visuelles partagées par les widgets de l'accueil acheteur.
///
/// Centralise les couleurs accent locales et les radius spécifiques à
/// cette page (légèrement différents des standards `AppDimens`).

/// Vert pâle utilisé pour les bandeaux (demande active, tendances).
const Color kAccueilPrimarySoft = Color(0xFFE8F5E9);

/// Radius des cards d'accueil (14 — un poil au-dessus du standard pour
/// donner du souffle aux photos).
const BorderRadius kAccueilBrCard = BorderRadius.all(Radius.circular(14));

/// Radius du hero CTA (16 — plus marqué que les cards).
const BorderRadius kAccueilBrHero = BorderRadius.all(Radius.circular(16));

/// Photo statique Unsplash pour la card "Assistant achat".
const String kAccueilPhotoAssistantAchat =
    'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=400&h=300&fit=crop&auto=format';

/// Photo statique Unsplash pour la card "Alertes prix".
const String kAccueilPhotoAlertesPrix =
    'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=300&fit=crop&auto=format';
