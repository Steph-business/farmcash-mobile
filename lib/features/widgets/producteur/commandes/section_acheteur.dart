import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/commande.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/section_titre.dart';
import '../../communs/snackbars.dart';

const Color _kPastelVert = Color(0xFFE8F5E9);

/// Section « Acheteur » de la page détail commande côté producteur.
/// Layout compact :
///   - Avatar rond (photo ou initiales) à gauche
///   - Vrai nom de l'acheteur (depuis le join backend), avec icône chat
///     **inline** à droite (sur la même ligne) pour démarrer une conv 1-1
///   - Adresse de livraison juste sous le nom
///   - Petit texte discret en pied : « Coordonnées partagées avec le
///     transporteur uniquement » — pour rassurer sans encombrer
///
/// **Pas de bouton « Appeler »** : volontaire pour éviter le contournement
/// de la plateforme (un farmer + acheteur qui s'échangent leurs numéros
/// finissent par traiter hors-app, FarmCash perd la commission).
class SectionAcheteur extends ConsumerWidget {
  const SectionAcheteur({required this.commande, super.key});

  final Commande commande;

  /// Ouvre (ou crée) la conversation 1-1 avec l'acheteur et navigue vers
  /// la page chat. Le backend `createConversation` retourne la conv
  /// existante si une session DIRECT existe déjà — pas de doublon en DB.
  Future<void> _ouvrirConversation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final conv = await ref
          .read(messagingServiceProvider)
          .createOrFindConversation(otherUserId: commande.buyerId);
      if (!context.mounted) return;
      context.push(RouteNames.chatDetailPathFor(conv.id));
    } on ApiException catch (e) {
      if (context.mounted) Snackbars.showErreur(context, e.message);
    } catch (_) {
      if (context.mounted) {
        Snackbars.showErreur(context, 'Impossible d\'ouvrir la conversation.');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adresse = commande.livraisonAdresse?.trim();
    final nom = (commande.buyerName ?? '').trim().isNotEmpty
        ? commande.buyerName!
        : 'Acheteur';
    final photo = commande.buyerPhotoUrl;

    // Titre « ACHETEUR » volontairement omis : le visuel (avatar + nom
    // + adresse) est auto-explicatif, le label ajoutait du bruit.
    return SectionTitre(
      titre: '',
      encadre: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _AvatarAcheteur(nom: nom, photoUrl: photo),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  nom,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Icône chat INLINE à droite du nom — gestuel direct, pas
              // besoin d'un gros bouton plein-largeur qui ajoute du bruit.
              InkWell(
                onTap: () => _ouvrirConversation(context, ref),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _kPastelVert,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          if (adresse != null && adresse.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.place_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    adresse,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 14,
                      color: AppColors.text,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Avatar circulaire : photo si dispo, sinon **2 premières lettres du
/// nom** (initiales) sur fond pastel vert.
class _AvatarAcheteur extends StatelessWidget {
  const _AvatarAcheteur({required this.nom, required this.photoUrl});

  final String nom;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    return ClipOval(
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: _kPastelVert,
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.center,
        child: hasPhoto
            ? CachedNetworkImage(
                imageUrl: photoUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: _kPastelVert),
                errorWidget: (_, _, _) => _Initiales(nom: nom),
              )
            : _Initiales(nom: nom),
      ),
    );
  }
}

class _Initiales extends StatelessWidget {
  const _Initiales({required this.nom});
  final String nom;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kPastelVert,
      alignment: Alignment.center,
      child: Text(
        _initialesDe(nom),
        style: AppTextStyles.titleMedium.copyWith(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Renvoie les 2 premières lettres du nom (et prénom si disponible).
/// Ex. « Stephy Koutouandah » → « SK ». Tolère les noms simples.
String _initialesDe(String nom) {
  final n = nom.trim();
  if (n.isEmpty) return '?';
  final parts = n.split(RegExp(r'\s+'));
  if (parts.length == 1) {
    return parts.first.characters.take(2).toString().toUpperCase();
  }
  final a = parts.first.characters.firstOrNull?.toString() ?? '';
  final b = parts.last.characters.firstOrNull?.toString() ?? '';
  final out = (a + b).toUpperCase();
  return out.isEmpty ? '?' : out;
}
