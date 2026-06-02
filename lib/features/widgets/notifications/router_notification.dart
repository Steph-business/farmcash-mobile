import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/enums.dart';
import '../../../models/notification.dart';
import '../../../routing/route_names.dart';

/// Convertit un type de notification backend (+ ses `data`) en chemin
/// mobile concret, adapté au rôle de l'utilisateur courant.
///
/// **Stratégie en deux passes** :
///
/// 1. **Data-first** : on regarde d'abord les champs `data` (commande_id,
///    conversation_id, shipment_id, etc.). Si on y trouve un ID, on
///    route vers la cible correspondante quel que soit `notif.type`.
///    Ça couvre le cas fréquent où le backend envoie `type: SYSTEM`
///    mais glisse un `commande_id` (ex. mise à jour statut commande).
///
/// 2. **Type-fallback** : si aucun ID actionnable dans `data`, on
///    branche sur des routes "liste" par type (NEGOTIATION → demandes,
///    WALLET_CREDITED → wallet, etc.).
///
/// Renvoie `null` uniquement pour les notifs vraiment systémiques sans
/// cible actionnable → l'appelant affiche un snackbar avec le titre.
String? routeFromNotification(AppNotification notif, UserRole? role) {
  final data = notif.data ?? <String, dynamic>{};
  final commandeId = _asString(data['commande_id']);
  final conversationId = _asString(data['conversation_id']);
  final shipmentId = _asString(data['shipment_id']);
  final annonceId = _asString(data['annonce_id']);
  final annonceAchatId = _asString(data['annonce_achat_id']);
  final sollicitationId = _asString(data['sollicitation_id']);

  // ─── PASSE 1 : data-first ──────────────────────────────────────────
  // Une notif avec un commande_id pointe presque toujours sur le détail
  // de cette commande, peu importe son type (SYSTEM, ORDER, PAYMENT,
  // PICKUP_CONFIRMED, etc.).

  if (commandeId != null) {
    // Transporteur : préfère le détail de SA mission si on a un
    // shipment_id (la commande n'est pas dans son shell).
    if (role == UserRole.transporter && shipmentId != null) {
      return RouteNames.transporteurMissionDetailPathFor(shipmentId);
    }
    final route = _commandeDetailFor(role, commandeId);
    if (route != null) return route;
  }

  if (conversationId != null) {
    return RouteNames.chatDetailPathFor(conversationId);
  }

  if (role == UserRole.transporter && shipmentId != null) {
    return RouteNames.transporteurMissionDetailPathFor(shipmentId);
  }

  if (role == UserRole.buyer && annonceId != null) {
    return RouteNames.acheteurAnnonceDetailPathFor(annonceId);
  }

  // Propositions reçues sur une demande d'achat (notif NEGOTIATION).
  if (annonceAchatId != null && role == UserRole.buyer) {
    return RouteNames.acheteurPropositionsRecuesPathFor(annonceAchatId);
  }

  // Sollicitation coop suivi.
  if (sollicitationId != null && role == UserRole.cooperative) {
    return RouteNames.cooperativeSollicitationSuiviPathFor(sollicitationId);
  }

  // ─── PASSE 2 : type-fallback ───────────────────────────────────────
  // Pas d'ID actionnable dans data → on route par type vers une liste
  // qui contient probablement l'item concerné.

  switch (notif.type) {
    case 'WALLET_CREDITED':
    case 'WALLET_TOPUP_SUCCESS':
      return _walletFor(role);

    case 'COOP_JOIN_ACCEPTED':
    case 'COOP_JOIN_REJECTED':
      if (role == UserRole.farmer) {
        return RouteNames.producteurCooperativePath;
      }
      return null;

    case 'NEGOTIATION':
      // Côté acheteur : ses demandes/propositions. Côté producteur/coop :
      // les offres reçues.
      if (role == UserRole.buyer) return RouteNames.acheteurDemandesPath;
      if (role == UserRole.farmer) {
        return RouteNames.producteurOffresRecuesPath;
      }
      if (role == UserRole.cooperative) {
        return RouteNames.cooperativeOffresRecuesPath;
      }
      return null;

    case 'MARKETPLACE':
      if (role == UserRole.buyer) return RouteNames.acheteurMarchePath;
      return null;

    default:
      return null;
  }
}

/// Navigation pratique : applique le routing + push si une route est
/// résolue. Sinon, exécute le callback `onSystem` (typiquement un
/// snackbar avec le titre de la notif).
void ouvrirNotification(
  BuildContext context,
  AppNotification notif,
  UserRole? role, {
  required VoidCallback onSystem,
}) {
  final path = routeFromNotification(notif, role);
  if (path == null) {
    onSystem();
    return;
  }
  context.push(path);
}

// ─── Helpers ─────────────────────────────────────────────────────────

/// Cast défensif — le `data` JSON peut contenir null, des nombres, etc.
String? _asString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

String? _commandeDetailFor(UserRole? role, String commandeId) {
  switch (role) {
    case UserRole.buyer:
      return RouteNames.acheteurCommandeDetailPathFor(commandeId);
    case UserRole.farmer:
    case UserRole.cooperative:
      // La coop réutilise la route producteur (même UI vendeur).
      return RouteNames.producteurCommandeDetailPathFor(commandeId);
    default:
      return null;
  }
}

String? _walletFor(UserRole? role) {
  switch (role) {
    case UserRole.buyer:
      return RouteNames.acheteurWalletPath;
    case UserRole.farmer:
      return RouteNames.producteurWalletPath;
    case UserRole.cooperative:
      return RouteNames.cooperativeWalletPath;
    case UserRole.transporter:
      return RouteNames.transporteurWalletPath;
    default:
      return null;
  }
}
