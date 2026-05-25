import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/annonce_vente.dart';
import '../../../../models/commande.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/chargement.dart';
import '../../communs/section_titre.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Provider de la traçabilité publique d'un lot. Retourne `null` si le
/// backend renvoie 404 (commande non rattachée à un lot tracé) — on
/// distingue « pas disponible » de « vide » pour afficher un message
/// honnête à l'acheteur.
final commandeTracabiliteProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, lotId) async {
  try {
    return await ref.read(aiServiceProvider).getLotTraceability(lotId);
  } on ApiException catch (e) {
    if (e.type == ApiExceptionType.notFound) return null;
    rethrow;
  }
});

/// Section « Parcours du produit » de la page détail commande côté
/// acheteur. Affiche la timeline backend du lot lié à la commande :
/// HARVESTED → DEPOSITED_AT_COOP → PICKED_UP → IN_TRANSIT → DELIVERED.
///
/// Pas de fallback « annonce comme lot » : si la commande n'a pas de
/// `lot_id`, on l'écrit honnêtement à l'utilisateur plutôt que de
/// fabriquer des étapes bidon.
class SectionParcours extends ConsumerWidget {
  const SectionParcours({
    required this.commande,
    required this.annonce,
    super.key,
  });

  final Commande commande;
  final AnnonceVente? annonce;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotId = commande.lotId;
    if (lotId == null || lotId.isEmpty) {
      return const SectionTitre(
        titre: 'Parcours du produit',
        child: _EmptyTracabilite(
          message: 'Traçabilité non disponible pour cette commande.',
        ),
      );
    }

    final async = ref.watch(commandeTracabiliteProvider(lotId));
    return async.when(
      loading: () => const SectionTitre(
        titre: 'Parcours du produit',
        child: SizedBox(
          height: 60,
          child: Center(child: Chargement(size: 18)),
        ),
      ),
      error: (e, _) => SectionTitre(
        titre: 'Parcours du produit',
        child: _EmptyTracabilite(
          message: 'Impossible de charger la traçabilité. $e',
        ),
      ),
      data: (payload) {
        if (payload == null || payload.isEmpty) {
          return const SectionTitre(
            titre: 'Parcours du produit',
            child: _EmptyTracabilite(
              message: 'Traçabilité non disponible pour cette commande.',
            ),
          );
        }
        return SectionTitre(
          titre: 'Parcours du produit',
          child: _ParcoursContent(payload: payload, annonce: annonce),
        );
      },
    );
  }
}

class _EmptyTracabilite extends StatelessWidget {
  const _EmptyTracabilite({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParcoursContent extends StatelessWidget {
  const _ParcoursContent({required this.payload, required this.annonce});
  final Map<String, dynamic> payload;
  final AnnonceVente? annonce;

  @override
  Widget build(BuildContext context) {
    final lot = payload['lot'];
    final events = payload['events'];
    final eventsList = events is List ? events : const <dynamic>[];

    final lotCode = (lot is Map ? lot['lot_code'] : null) as String?;
    final produit = (lot is Map ? lot['produit'] : null) as String?;
    final farmerNom = annonce?.vendeurNom;
    final farmerPhoto = annonce?.vendeur?.photoUrl;
    final loc = annonce?.localisationLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _kPrimarySoft,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Row(
            children: [
              ClipOval(
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: farmerPhoto != null && farmerPhoto.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: farmerPhoto,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(color: Colors.white),
                          errorWidget: (_, _, _) =>
                              Container(color: Colors.white),
                        )
                      : Container(
                          color: Colors.white,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.person_outline,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      farmerNom ?? produit ?? 'Producteur',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (lotCode != null && lotCode.isNotEmpty)
                          'Lot $lotCode',
                        if (loc != null) loc,
                      ].join(' · '),
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (eventsList.isEmpty)
          const _EmptyTracabilite(
            message: 'Aucun événement enregistré pour ce lot.',
          )
        else
          Column(
            children: [
              for (var i = 0; i < eventsList.length; i++)
                _ParcoursStep(
                  raw: eventsList[i],
                  isLast: i == eventsList.length - 1,
                ),
            ],
          ),
      ],
    );
  }
}

class _ParcoursStep extends StatelessWidget {
  const _ParcoursStep({required this.raw, required this.isLast});
  final dynamic raw;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final m =
        raw is Map ? raw.cast<String, dynamic>() : const <String, dynamic>{};
    final type = m['type'] as String?;
    final dateStr = m['date'] as String?;
    final metadata = m['metadata'];
    final note = metadata is Map ? metadata['note'] as String? : null;
    final warehouse = metadata is Map ? metadata['warehouse'] as String? : null;
    final transporter =
        metadata is Map ? metadata['transporter'] as String? : null;

    final df = DateFormat('d MMM y · HH\'h\'mm', 'fr_FR');
    final dateLabel = (dateStr != null && dateStr.isNotEmpty)
        ? df.format(DateTime.parse(dateStr).toLocal())
        : '—';

    final title = _eventTitle(type);
    final icon = _eventIcon(type);
    final detail = [
      if (note != null && note.trim().isNotEmpty) note,
      if (warehouse != null && warehouse.trim().isNotEmpty) warehouse,
      if (transporter != null && transporter.trim().isNotEmpty)
        'Transporteur · $transporter',
    ].join(' · ');

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!isLast)
                  Positioned(
                    top: 24,
                    bottom: -14,
                    child: Container(width: 2, color: AppColors.border),
                  ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 12, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (detail.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _eventTitle(String? type) {
    switch (type) {
      case 'HARVESTED':
        return 'Récolte au champ';
      case 'DEPOSITED_AT_COOP':
        return 'Dépôt à la coopérative';
      case 'PICKED_UP':
        return 'Pris en charge par le transporteur';
      case 'IN_TRANSIT':
        return 'En cours d\'acheminement';
      case 'DELIVERED':
        return 'Livré à l\'acheteur';
      case 'CREATED':
        return 'Lot créé';
      default:
        // Fallback honnête : on affiche le type brut plutôt qu'un libellé
        // bidon. Permet de débugger les nouveaux event_type côté back.
        return type ?? 'Événement';
    }
  }

  IconData _eventIcon(String? type) {
    switch (type) {
      case 'HARVESTED':
        return Icons.agriculture_outlined;
      case 'DEPOSITED_AT_COOP':
        return Icons.warehouse_outlined;
      case 'PICKED_UP':
      case 'IN_TRANSIT':
        return Icons.local_shipping_outlined;
      case 'DELIVERED':
        return Icons.check;
      case 'CREATED':
        return Icons.qr_code_2;
      default:
        return Icons.circle;
    }
  }
}
