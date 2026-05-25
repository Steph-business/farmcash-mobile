import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/commande.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'snackbars.dart';

/// Ouvre un dialog pour saisir une raison + description et créer un
/// litige côté backend (`POST /orders/disputes`). Utilisable des deux
/// côtés — **acheteur ET producteur** : le backend identifie qui
/// signale via l'auth, et gère le workflow admin : gel de l'escrow,
/// notification de la contrepartie, résolution par un staff.
///
/// Le wording du hint et de la description s'adapte au rôle pour rester
/// naturel (« vendeur n'envoie pas » vs « acheteur ne répond pas »).
///
/// Contraintes du backend (`OpenDisputeDto.raison`) :
///   - min 10 caractères → vérifié côté UI avant envoi
///   - max 1000 caractères → enforcement via `maxLength` du TextField
///
/// Retourne `true` si un litige a été créé, `false` si l'utilisateur a
/// annulé ou si une erreur est survenue (un snackbar a été affiché).
Future<bool> ouvrirDialogSignalerProbleme(
  BuildContext context,
  Commande commande, {
  bool viewerIsBuyer = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => _DialogSignalerProbleme(
      commande: commande,
      viewerIsBuyer: viewerIsBuyer,
    ),
  );
  return result == true;
}

/// Widget interne — c'est un `StatefulWidget` (pas un `StatefulBuilder`)
/// pour que le `TextEditingController` soit possédé par le State et
/// disposé proprement dans `dispose()`. L'ancien pattern (controller
/// créé dans la fonction qui `showDialog`, disposé après l'await)
/// causait un crash « TextEditingController used after being disposed »
/// parce que l'AlertDialog peut être encore en train d'animer sa
/// fermeture quand on dispose.
class _DialogSignalerProbleme extends ConsumerStatefulWidget {
  const _DialogSignalerProbleme({
    required this.commande,
    required this.viewerIsBuyer,
  });

  final Commande commande;
  final bool viewerIsBuyer;

  @override
  ConsumerState<_DialogSignalerProbleme> createState() =>
      _DialogSignalerProblemeState();
}

class _DialogSignalerProblemeState
    extends ConsumerState<_DialogSignalerProbleme> {
  final _raisonCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _raisonCtrl.dispose();
    super.dispose();
  }

  Future<void> _envoyer() async {
    final raison = _raisonCtrl.text.trim();
    if (raison.length < 10) {
      Snackbars.showErreur(
        context,
        'Décris ton problème en au moins 10 caractères.',
      );
      return;
    }
    setState(() => _sending = true);
    try {
      await ref.read(ordersServiceProvider).openDispute(
            commandeId: widget.commande.id,
            raison: raison,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      Snackbars.showSucces(
        context,
        'Litige ouvert. Notre équipe te recontacte sous 24h.',
      );
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) {
        Snackbars.showErreur(context, 'Impossible d\'ouvrir le litige.');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final description = widget.viewerIsBuyer
        ? "Décris ce qui ne va pas (vendeur n'envoie pas, produit différent, etc.). Notre équipe interviendra et ton paiement reste protégé tant que le problème n'est pas résolu."
        : "Décris ce qui ne va pas (acheteur ne répond pas, refuse la livraison, etc.). Notre équipe interviendra. Le paiement reste en escrow tant que le litige n'est pas résolu.";
    final hint = widget.viewerIsBuyer
        ? "Ex : Le vendeur n'a pas répondu depuis 3 jours…"
        : "Ex : L'acheteur ne répond pas depuis 3 jours…";

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text('Signaler un problème'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _raisonCtrl,
            enabled: !_sending,
            maxLines: 4,
            minLines: 3,
            maxLength: 1000,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed:
              _sending ? null : () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _sending ? null : _envoyer,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.onPrimary,
          ),
          child: _sending
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onPrimary,
                  ),
                )
              : const Text('Envoyer'),
        ),
      ],
    );
  }
}
