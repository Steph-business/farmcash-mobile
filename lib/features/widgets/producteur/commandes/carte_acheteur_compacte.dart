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
import '../../communs/snackbars.dart';

/// Carte acheteur compacte sur la page détail commande producteur —
/// avatar carré + nom + bouton "Discuter" plein vert avec badge non-lu
/// optionnel.
///
/// Remplace l'ancienne `SectionAcheteur` qui empilait avatar + nom +
/// adresse + icône chat discrète. Le CTA pill est ici le canal principal
/// pour échanger avec l'acheteur.
class CarteAcheteurCompacte extends ConsumerWidget {
  /// Construit la carte acheteur.
  const CarteAcheteurCompacte({
    required this.commande,
    this.unreadCount = 0,
    super.key,
  });

  /// Commande source — on en extrait `buyerId`, `buyerName`, `buyerPhotoUrl`.
  final Commande commande;

  /// Nombre de messages non lus avec cet acheteur. Affiché en badge si > 0.
  final int unreadCount;

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
        Snackbars.showErreur(
          context,
          'Impossible d\'ouvrir la conversation.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nom = (commande.buyerName ?? '').trim().isNotEmpty
        ? commande.buyerName!
        : 'Acheteur';
    final photo = commande.buyerPhotoUrl;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _AvatarAcheteurCarre(nom: nom, photoUrl: photo),
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
          _BoutonDiscuter(
            unreadCount: unreadCount,
            onTap: () => _ouvrirConversation(context, ref),
          ),
        ],
      ),
    );
  }
}

class _BoutonDiscuter extends StatelessWidget {
  const _BoutonDiscuter({
    required this.unreadCount,
    required this.onTap,
  });

  final int unreadCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            minimumSize: const Size(110, 44),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: AppTextStyles.button.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          child: const Text('Discuter'),
        ),
        if (unreadCount > 0)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 22,
                minHeight: 22,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AvatarAcheteurCarre extends StatelessWidget {
  const _AvatarAcheteurCarre({required this.nom, required this.photoUrl});

  final String nom;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 48,
        height: 48,
        color: AppColors.primary,
        alignment: Alignment.center,
        child: hasPhoto
            ? CachedNetworkImage(
                imageUrl: photoUrl!,
                fit: BoxFit.cover,
                width: 48,
                height: 48,
                placeholder: (_, _) => _Initiale(nom: nom),
                errorWidget: (_, _, _) => _Initiale(nom: nom),
              )
            : _Initiale(nom: nom),
      ),
    );
  }
}

class _Initiale extends StatelessWidget {
  const _Initiale({required this.nom});
  final String nom;

  @override
  Widget build(BuildContext context) {
    final n = nom.trim();
    final lettre = n.isEmpty ? '?' : n.characters.first.toUpperCase();
    return Container(
      color: AppColors.primary,
      alignment: Alignment.center,
      child: Text(
        lettre,
        style: AppTextStyles.titleMedium.copyWith(
          fontFamily: 'Poppins',
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
