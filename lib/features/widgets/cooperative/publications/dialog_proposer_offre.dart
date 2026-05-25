import 'package:flutter/material.dart';

import '../../../../models/annonce_achat.dart';

/// Résultat du dialog « Proposer une offre » :
///   - `annule = true` si l'utilisateur a annulé,
///   - `brouillon` non-null si la saisie est valide,
///   - les deux à null si l'utilisateur a soumis mais avec des champs
///     invalides (le caller doit alors afficher l'erreur appropriée).
class ResultatProposition {
  const ResultatProposition({this.annule = false, this.brouillon});
  final bool annule;
  final BrouillonProposition? brouillon;
}

/// Brouillon de proposition envoyée par la coopérative en réponse à une
/// offre d'achat reçue : quantité, prix proposé, message optionnel.
class BrouillonProposition {
  const BrouillonProposition({
    required this.quantiteKg,
    required this.prixKg,
    required this.message,
  });

  final double quantiteKg;
  final double prixKg;
  final String? message;
}

/// Dialog de saisie d'une proposition envoyée par la COOP à l'acheteur.
/// Pré-remplit la quantité demandée par l'offre et propose un prix par
/// défaut à -5 % du `prixMaxKg`.
///
/// Sémantique du retour :
///   - `annule: true` si l'utilisateur a tapé « Annuler »,
///   - `brouillon` non-null si la saisie est valide,
///   - `annule: false` + `brouillon: null` si l'utilisateur a tapé
///     « Envoyer » mais que la quantité ou le prix est invalide.
Future<ResultatProposition> ouvrirDialogProposerOffre(
  BuildContext context, {
  required AnnonceAchat offre,
}) async {
  final qteCtrl = TextEditingController(
    text: offre.quantiteKg.round().toString(),
  );
  final prixCtrl = TextEditingController(
    text: (offre.prixMaxKg * 0.95).round().toString(),
  );
  final msgCtrl = TextEditingController();

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Proposer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: qteCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantité (kg)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: prixCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Prix proposé (F/kg)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: msgCtrl,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Message (optionnel)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Envoyer'),
        ),
      ],
    ),
  );

  if (ok != true) {
    return const ResultatProposition(annule: true);
  }
  final qte = double.tryParse(qteCtrl.text.replaceAll(',', '.'));
  final prix = double.tryParse(prixCtrl.text.replaceAll(',', '.'));
  if (qte == null || qte <= 0 || prix == null || prix <= 0) {
    return const ResultatProposition();
  }
  return ResultatProposition(
    brouillon: BrouillonProposition(
      quantiteKg: qte,
      prixKg: prix,
      message: msgCtrl.text.trim().isEmpty ? null : msgCtrl.text.trim(),
    ),
  );
}
