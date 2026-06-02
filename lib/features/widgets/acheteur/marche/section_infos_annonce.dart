import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/annonce_vente.dart';
import 'annonce_detail_constants.dart';
import 'info_row_annonce.dart';
import 'section_annonce.dart';

/// Section « Informations » du détail annonce, disposée en tableau
/// clé/valeur (style fiche produit).
///
/// **Règle d'affichage** : chaque ligne ne s'affiche que si la donnée
/// existe réellement côté base. On ne montre **aucun fallback fantôme**
/// (« — », « 1 kg » par défaut, etc.). Si le producteur n'a pas
/// renseigné une info à la publication, elle ne s'affiche pas — l'œil
/// de l'acheteur reste focus sur ce qui est concret.
///
/// Seules les valeurs **toujours présentes** dans le schéma DB
/// (`quantite_kg`, `prix_par_kg`) sont garanties affichées. Le
/// montant total est calculé donc également toujours présent.
class SectionInfosAnnonce extends StatelessWidget {
  const SectionInfosAnnonce({
    required this.annonce,
    super.key,
  });

  final AnnonceVente annonce;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMMM y', 'fr_FR');
    final qteDispo = annonce.quantiteKg.round();
    final prix = annonce.prixParKg.round();
    final montantTotal = qteDispo * prix;
    // Quantité minimum : nullable côté backend. On affiche UNIQUEMENT
    // si le producteur l'a renseignée à la publication — sinon on
    // cache la ligne (pas de fallback « 1 kg » qui n'a aucun sens).
    final int? qteMin = annonce.quantiteMinKg?.round();
    // Date de disponibilité : on prend en priorité la date de récolte
    // (info fraîcheur), sinon la date limite « disponible jusqu'au ».
    // Pas de fallback sur createdAt — ce n'est pas une date de
    // disponibilité au sens propre.
    final DateTime? dateDispo =
        annonce.dateRecolte ?? annonce.disponibleJusqu;

    return SectionAnnonce(
      title: 'Informations',
      child: Column(
        children: [
          InfoRowAnnonce(
            label: 'Quantité disponible',
            value: '${kAnnonceDetailNumFmt.format(qteDispo)} kg',
          ),
          InfoRowAnnonce(
            label: 'Prix unitaire',
            value: '${kAnnonceDetailNumFmt.format(prix)} FCFA / kg',
          ),
          if (qteMin != null && qteMin > 0)
            InfoRowAnnonce(
              label: 'Quantité minimum',
              value: '${kAnnonceDetailNumFmt.format(qteMin)} kg',
            ),
          InfoRowAnnonce(
            label: 'Montant total (${kAnnonceDetailNumFmt.format(qteDispo)} kg)',
            value: '${kAnnonceDetailNumFmt.format(montantTotal)} FCFA',
            // Met en valeur la ligne du montant (vert primary + Poppins
            // bold) — c'est l'info la plus regardée par l'acheteur.
            highlight: true,
          ),
          if (dateDispo != null)
            InfoRowAnnonce(
              label: 'Date de disponibilité',
              value: df.format(dateDispo),
            ),
        ],
      ),
    );
  }
}
