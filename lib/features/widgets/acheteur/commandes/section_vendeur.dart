import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/annonce_vente.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/section_titre.dart';
import '../../communs/snackbars.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Section « Vendeur » de la page détail commande côté acheteur :
/// avatar + nom + rating + bouton chat (cercle). Le tap sur l'icône chat
/// ouvre (ou crée) une conversation 1-1 avec le vendeur via
/// `messaging_service.createOrFindConversation` — le backend dédoublonne
/// les conversations DIRECT, donc pas de risque de doublon en DB.
class SectionVendeur extends ConsumerWidget {
  const SectionVendeur({
    required this.annonce,
    super.key,
  });

  /// Annonce associée à la commande. `null` si l'annonce a été dépubliée
  /// → on ne sait plus qui était le vendeur, on affiche un placeholder.
  final AnnonceVente? annonce;

  Future<void> _ouvrirConversation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final sellerId = annonce?.vendeur?.id ?? annonce?.farmerId;
    if (sellerId == null || sellerId.isEmpty) {
      Snackbars.showErreur(
        context,
        'Vendeur introuvable — conversation impossible.',
      );
      return;
    }
    try {
      final conv = await ref
          .read(messagingServiceProvider)
          .createOrFindConversation(otherUserId: sellerId);
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
    final nom = annonce?.vendeurNom ?? 'Vendeur';
    final rating = annonce?.vendeur?.rating;
    final photo = annonce?.vendeur?.photoUrl;
    return SectionTitre(
      titre: 'Vendeur',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _AvatarVendeur(nom: nom, photoUrl: photo),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nom,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (rating != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    '★ ${rating.toStringAsFixed(1)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _ouvrirConversation(context, ref),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _kPrimarySoft,
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
    );
  }
}

/// Avatar circulaire vendeur : photo si dispo, sinon **initiales** sur
/// fond pastel vert. Aligné sur le pattern producteur pour cohérence
/// visuelle.
class _AvatarVendeur extends StatelessWidget {
  const _AvatarVendeur({required this.nom, required this.photoUrl});

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
          color: _kPrimarySoft,
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
                placeholder: (_, _) => Container(color: _kPrimarySoft),
                errorWidget: (_, _, _) => _InitialesVendeur(nom: nom),
              )
            : _InitialesVendeur(nom: nom),
      ),
    );
  }
}

class _InitialesVendeur extends StatelessWidget {
  const _InitialesVendeur({required this.nom});
  final String nom;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kPrimarySoft,
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
