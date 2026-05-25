import 'package:flutter/material.dart';

import '../../../../models/annonce_achat.dart';
import '../../../../models/membre_coop.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '_constantes_accueil_coop.dart';
import 'avatars_empiles_coop.dart';
import 'item_action_coop.dart';
import 'ligne_item_action_coop.dart';
import 'section_head_coop.dart';

/// Section "Actions à traiter" de l'accueil coopérative : liste compacte
/// d'items (adhésions, offres d'achat reçues, annonces à valider) chacun
/// avec son compteur et son accent sémantique. La priorité du "Voir tout"
/// va aux adhésions > offres > validations selon ce qui est non vide.
class SectionActionsATraiterCoop extends StatelessWidget {
  const SectionActionsATraiterCoop({
    super.key,
    required this.joinRequests,
    required this.annoncesAchat,
    required this.nbAnnoncesAValider,
    required this.nbAnnoncesVentePending,
    required this.nbPrevisionsPending,
    required this.onAdhesions,
    required this.onOffres,
    required this.onValidations,
  });

  final List<CoopJoinRequest> joinRequests;
  final List<AnnonceAchat> annoncesAchat;
  final int nbAnnoncesAValider;
  final int nbAnnoncesVentePending;
  final int nbPrevisionsPending;

  final VoidCallback onAdhesions;
  final VoidCallback onOffres;
  final VoidCallback onValidations;

  @override
  Widget build(BuildContext context) {
    final items = <DonneesItemActionCoop>[];

    if (joinRequests.isNotEmpty) {
      final dernier = _plusRecent(
        joinRequests.map((r) => r.createdAt),
      );
      final relatif = _formatRelatif(dernier);
      items.add(
        DonneesItemActionCoop(
          icon: Icons.group_add_outlined,
          titre: '${joinRequests.length} '
              '${joinRequests.length > 1 ? "demandes" : "demande"} '
              'd’adhésion',
          sousTitre:
              relatif != null ? 'dont 1 reçue $relatif' : 'à examiner',
          accent: kInfoAccentCoop,
          accentSoft: kInfoSoftCoop,
          count: joinRequests.length,
          onTap: onAdhesions,
        ),
      );
    }

    if (annoncesAchat.isNotEmpty) {
      items.add(
        DonneesItemActionCoop(
          icon: Icons.shopping_cart_outlined,
          titre: '${annoncesAchat.length} '
              '${annoncesAchat.length > 1 ? "offres" : "offre"} '
              'd’achat ${annoncesAchat.length > 1 ? "reçues" : "reçue"}',
          sousTitre: _sousTitreOffres(annoncesAchat),
          accent: kWarnAccentCoop,
          accentSoft: kWarnSoftCoop,
          count: annoncesAchat.length,
          onTap: onOffres,
        ),
      );
    }

    if (nbAnnoncesAValider > 0) {
      items.add(
        DonneesItemActionCoop(
          icon: Icons.fact_check_outlined,
          titre: '$nbAnnoncesAValider '
              '${nbAnnoncesAValider > 1 ? "annonces" : "annonce"} '
              'à valider',
          sousTitre: _sousTitreValidations(
            nbAnnoncesVentePending,
            nbPrevisionsPending,
          ),
          accent: AppColors.primary,
          accentSoft: kPrimarySoftCoop,
          count: nbAnnoncesAValider,
          onTap: onValidations,
        ),
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    // "Voir tout" du header : priorité = adhésions > offres > validations,
    // pour pointer sur la liste la plus probable.
    final VoidCallback onVoirTout = joinRequests.isNotEmpty
        ? onAdhesions
        : (annoncesAchat.isNotEmpty ? onOffres : onValidations);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeadCoop(
          titre: 'Actions à traiter',
          lienTexte: 'Voir tout',
          onLien: onVoirTout,
          trailing: joinRequests.isEmpty
              ? null
              : AvatarsEmpilesCoop(
                  seeds: joinRequests
                      .map((r) => r.farmerId)
                      .take(3)
                      .toList(),
                ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: kBrCardCoop,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                LigneItemActionCoop(
                  data: items[i],
                  onTap: items[i].onTap,
                ),
                if (i < items.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.border,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// "il y a Xh" / "il y a Xj" / "à l'instant".
String? _formatRelatif(DateTime? date) {
  if (date == null) return null;
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'à l’instant';
  if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
  if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
  final semaines = (diff.inDays / 7).floor();
  if (semaines < 5) return 'il y a $semaines sem';
  final mois = (diff.inDays / 30).floor();
  return 'il y a $mois mois';
}

DateTime? _plusRecent(Iterable<DateTime?> dates) {
  DateTime? best;
  for (final d in dates) {
    if (d == null) continue;
    if (best == null || d.isAfter(best)) best = d;
  }
  return best;
}

String _sousTitreOffres(List<AnnonceAchat> offres) {
  if (offres.isEmpty) return '';
  final premier = offres.first;
  final qty = _formatStock(premier.quantiteKg);
  final titre = (premier.titre ?? '').trim();
  if (titre.isNotEmpty) return '$titre · $qty';
  return qty;
}

String _sousTitreValidations(int nbVente, int nbPrev) {
  final parts = <String>[];
  if (nbVente > 0) {
    parts.add('$nbVente ${nbVente > 1 ? "annonces" : "annonce"}');
  }
  if (nbPrev > 0) {
    parts.add('$nbPrev ${nbPrev > 1 ? "prévisions" : "prévision"}');
  }
  if (parts.isEmpty) return 'à examiner';
  return '${parts.join(" · ")} à examiner';
}

/// Formate une quantité en kg : au-dessus de 1000 → "12,5 t", sinon "[n] kg".
String _formatStock(double kg) {
  if (kg <= 0) return '0 kg';
  if (kg >= 1000) {
    return '${_formatDecimal(kg / 1000)} t';
  }
  return '${kg.toInt()} kg';
}

/// Une décimale, séparateur virgule à la française, sans zéro inutile.
String _formatDecimal(double v) {
  final rounded = (v * 10).round() / 10;
  final isInt = rounded == rounded.roundToDouble();
  if (isInt) return rounded.toInt().toString();
  return rounded.toString().replaceAll('.', ',');
}
