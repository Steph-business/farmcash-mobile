import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../services/providers.dart';
import '../../../state/auth_state.dart';
import '../snackbars.dart';

/// Helper réutilisable : ouvre une bottom sheet « Caméra / Galerie »,
/// récupère l'image choisie, l'upload comme avatar de profil et
/// rafraîchit les providers user. Utilisable depuis les 4 pages profil
/// (acheteur / producteur / coop / transporteur).
///
/// Usage :
/// ```dart
/// onEditPhoto: () => changerPhotoProfil(context, ref),
/// ```
///
/// Le helper gère lui-même les erreurs (snackbar) et le feedback
/// utilisateur — l'appelant n'a rien à faire de plus.
Future<void> changerPhotoProfil(BuildContext context, WidgetRef ref) async {
  final source = await _choisirSource(context);
  if (source == null || !context.mounted) return;

  final picker = ImagePicker();
  final XFile? picked;
  try {
    picked = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
  } catch (e) {
    if (context.mounted) {
      Snackbars.showErreur(context, 'Sélection d\'image impossible : $e');
    }
    return;
  }
  if (picked == null || !context.mounted) return;

  // Petit loader pendant l'upload (la requête multipart peut prendre
  // 1-3 sec sur un réseau lent). On garde une durée longue (8 s) pour
  // que le snackbar reste visible le temps de l'upload — il sera
  // explicitement caché via `hideCurrentSnackBar()` à la fin (succès
  // ou erreur), exactement comme avant.
  Snackbars.showInfo(
    context,
    'Envoi de la photo…',
    duration: const Duration(seconds: 8),
  );

  try {
    final updated =
        await ref.read(authServiceProvider).uploadAvatar(file: File(picked.path));
    // Met à jour le user courant en mémoire pour rafraîchir l'avatar
    // partout dans l'app (header, profil, cartes…).
    ref.read(authStateProvider.notifier).updateUser(updated);
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      Snackbars.showSucces(context, 'Photo mise à jour');
    }
  } on ApiException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      Snackbars.showErreur(context, e.message);
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      Snackbars.showErreur(context, 'Échec de l\'envoi : $e');
    }
  }
}

/// Bottom sheet de choix : Caméra ou Galerie. Retourne `null` si annulé.
Future<ImageSource?> _choisirSource(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Prendre une photo'),
            onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choisir dans la galerie'),
            onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
