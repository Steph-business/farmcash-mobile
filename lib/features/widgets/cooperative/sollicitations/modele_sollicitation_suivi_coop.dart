import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/providers.dart';

/// Rôle d'un destinataire dans une sollicitation coop, dérivé du champ
/// `audience_segment` renvoyé par l'API. Utilisé pour le badge coloré
/// affiché à droite du nom dans `ReplyTileSollicitationCoop`.
enum ReplyRoleSollicitationCoop { membre, coop, indep, unknown }

/// Mode de réponse du fournisseur (pour l'instant seulement « maintenant »,
/// à terme un mode « engagement à venir » sera ajouté).
enum ReplyModeSollicitationCoop { now }

/// Une réponse fournisseur décodée depuis la Map riche `getSollicitation`.
class SollicitationReplyCoop {
  final String? recipientId;
  final String nom;
  final ReplyRoleSollicitationCoop role;
  final double qtyKg;
  final ReplyModeSollicitationCoop mode;

  /// True si le recipient a déjà répondu (ACCEPTED).
  final bool deja;

  /// True si la coop a confirmé l'engagement de ce recipient.
  final bool confirme;

  const SollicitationReplyCoop({
    this.recipientId,
    required this.nom,
    required this.role,
    required this.qtyKg,
    required this.mode,
    required this.deja,
    required this.confirme,
  });
}

/// Données décodées depuis la Map riche `getSollicitation(id)`.
class SollicitationDetailCoop {
  final String? produitNom;
  final double? quantiteCibleKg;
  final double quantiteOfferteKg;
  final int totalRecipients;
  final int totalResponses;
  final String status;
  final List<SollicitationReplyCoop> replies;

  const SollicitationDetailCoop({
    this.produitNom,
    this.quantiteCibleKg,
    required this.quantiteOfferteKg,
    required this.totalRecipients,
    required this.totalResponses,
    required this.status,
    required this.replies,
  });
}

/// Provider qui charge le détail d'une sollicitation pour la page suivi
/// coopérative. Exposé pour permettre aux widgets enfants (réponses,
/// sticky d'actions) d'invalider après confirmation/clôture.
final sollicitationSuiviCoopProvider = FutureProvider.autoDispose
    .family<SollicitationDetailCoop, String>((ref, id) async {
  final raw = await ref.read(cooperativesServiceProvider).getSollicitation(id);
  return decodeSollicitationCoop(raw);
});

/// Décode la Map JSON brute renvoyée par `getSollicitation` en un
/// [SollicitationDetailCoop] typé. Tolère les variantes de casse
/// (camelCase / snake_case) et les champs absents.
SollicitationDetailCoop decodeSollicitationCoop(Map<String, dynamic> raw) {
  final annonce = raw['annonce'];
  String? produitNom;
  double? quantiteCibleKg;
  if (annonce is Map) {
    final a = annonce.cast<String, dynamic>();
    final p = a['produit'];
    if (p is Map) {
      produitNom = p['nom'] as String?;
    }
    quantiteCibleKg = asDoubleSollicitationCoop(a['quantite_kg']);
  }

  final replies = <SollicitationReplyCoop>[];
  final recipients = raw['recipients'];
  if (recipients is List) {
    for (final r in recipients.whereType<Map>()) {
      final m = r.cast<String, dynamic>();
      final user = m['user'];
      String nom = 'Destinataire';
      if (user is Map) {
        final u = user.cast<String, dynamic>();
        nom = (u['full_name'] as String?) ??
            (u['fullName'] as String?) ??
            (u['phone'] as String?) ??
            'Destinataire';
      }
      final audience =
          (m['audience_segment'] as String? ?? 'UNKNOWN').toUpperCase();
      ReplyRoleSollicitationCoop role;
      switch (audience) {
        case 'MEMBRES':
        case 'MEMBRE':
          role = ReplyRoleSollicitationCoop.membre;
          break;
        case 'COOPS_VOISINES':
        case 'COOP':
          role = ReplyRoleSollicitationCoop.coop;
          break;
        case 'INDEPENDANTS':
        case 'INDEPENDANT':
          role = ReplyRoleSollicitationCoop.indep;
          break;
        default:
          role = ReplyRoleSollicitationCoop.unknown;
      }
      final action = (m['response_action'] as String? ?? '').toUpperCase();
      final accepted = action == 'ACCEPTED' || action == 'CONFIRMED_BY_COOP';
      final confirme = (m['confirmed_by_coop_at'] as Object?) != null ||
          action == 'CONFIRMED_BY_COOP';
      final qty = asDoubleSollicitationCoop(m['response_quantite_kg']) ?? 0;
      replies.add(SollicitationReplyCoop(
        recipientId: m['id'] as String?,
        nom: nom,
        role: role,
        qtyKg: qty,
        mode: ReplyModeSollicitationCoop.now,
        deja: accepted,
        confirme: confirme,
      ));
    }
  }

  final summary = raw['responses_summary'];
  double totalOfferte = 0;
  if (summary is Map) {
    final s = summary.cast<String, dynamic>();
    totalOfferte = asDoubleSollicitationCoop(s['total_quantite_offerte']) ??
        asDoubleSollicitationCoop(s['totalQuantiteOfferte']) ??
        0;
  }
  if (totalOfferte == 0) {
    totalOfferte = replies
        .where((r) => r.deja)
        .fold<double>(0, (acc, r) => acc + r.qtyKg);
  }

  return SollicitationDetailCoop(
    produitNom: produitNom,
    quantiteCibleKg: quantiteCibleKg,
    quantiteOfferteKg: totalOfferte,
    totalRecipients:
        (raw['total_recipients'] as num?)?.toInt() ?? replies.length,
    totalResponses: (raw['total_responses'] as num?)?.toInt() ??
        replies.where((r) => r.deja).length,
    status: (raw['status'] as String? ?? 'OPEN').toUpperCase(),
    replies: replies,
  );
}

/// Convertit un `Object?` (num | String | null) en `double?`.
double? asDoubleSollicitationCoop(Object? v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

/// Formate une valeur numérique kg en chaîne avec espace tous les
/// 3 chiffres (« 12 345 »). Utilisé dans les cards et tuiles de la
/// page suivi sollicitation coopérative.
String formatKgSollicitationCoop(double v) {
  final i = v.round();
  if (i < 1000) return '$i';
  final s = '$i';
  final buf = StringBuffer();
  for (var k = 0; k < s.length; k++) {
    if (k > 0 && (s.length - k) % 3 == 0) buf.write(' ');
    buf.write(s[k]);
  }
  return buf.toString();
}

/// Extrait des initiales (1 ou 2 lettres majuscules) à partir d'un nom
/// complet, pour l'avatar circulaire de [ReplyTileSollicitationCoop].
String initialesSollicitationCoop(String s) {
  final t = s.trim();
  if (t.isEmpty) return '?';
  final parts = t.split(RegExp(r'[\s\-_]+'))..removeWhere((p) => p.isEmpty);
  if (parts.length >= 2) {
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
  if (t.length == 1) return t.toUpperCase();
  return t.substring(0, 2).toUpperCase();
}

/// Couleur pastel verte commune aux widgets de la page suivi sollicitation
/// coopérative (chips, badges et bordures d'avatar membres).
const kPrimarySoftSollicitationCoop = Color(0xFFE8F5E9);

/// Couleur pastel bleue utilisée pour les badges « Coop » dans la liste
/// des réponses fournisseurs.
const kBlueSoftSollicitationCoop = Color(0xFFE3F2FD);

/// Bleu profond servant de texte au badge « Coop » (contraste avec son
/// pastel d'accompagnement).
const kBlueSollicitationCoop = Color(0xFF1565C0);
