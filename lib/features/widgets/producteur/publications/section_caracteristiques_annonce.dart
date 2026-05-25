import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/annonce_vente.dart';
import 'annonce_detail_helpers.dart';
import 'feat_row_annonce.dart';
import 'section_card_annonce.dart';

/// Section « Caractéristiques » de la page détail d'une annonce producteur :
/// produit, qualité, quantité, prix, dates, région, certifications, traitements.
///
/// Les dates « disponible jusqu'au » ont été retirées du formulaire et ne
/// sont donc plus exposées ici — gardées dans le model pour compat ancienne
/// data mais non affichées.
class SectionCaracteristiquesAnnonce extends StatelessWidget {
  const SectionCaracteristiquesAnnonce({required this.annonce, super.key});

  final AnnonceVente annonce;

  @override
  Widget build(BuildContext context) {
    final qte = NumberFormat('#,##0', 'fr_FR').format(annonce.quantiteKg);
    final prix = NumberFormat('#,##0', 'fr_FR').format(annonce.prixParKg);
    final recolte = annonce.dateRecolte;
    final recolteTexte = recolte == null
        ? 'Non renseignée'
        : DateFormat('d MMM y', 'fr_FR').format(recolte);
    final pub = annonce.createdAt;
    final pubTexte = pub == null
        ? '—'
        : DateFormat('d MMM y', 'fr_FR').format(pub);
    final certifs = annonce.certifications.isEmpty
        ? null
        : annonce.certifications.join(', ');
    final region = annonce.regionNom?.trim();

    return SectionCardAnnonce(
      title: 'Caractéristiques',
      children: [
        FeatRowAnnonce(label: 'Produit', value: annonce.produitLabel),
        FeatRowAnnonce(
          label: 'Qualité',
          value: annonceDetailQualiteLabel(annonce.qualite) ?? '—',
        ),
        FeatRowAnnonce(label: 'Quantité', value: '$qte kg'),
        FeatRowAnnonce(label: 'Prix', value: '$prix F/kg'),
        FeatRowAnnonce(label: 'Date de récolte', value: recolteTexte),
        FeatRowAnnonce(label: 'Date de publication', value: pubTexte),
        if (region != null && region.isNotEmpty)
          FeatRowAnnonce(label: 'Région', value: region),
        if (certifs != null)
          FeatRowAnnonce(label: 'Certifications', value: certifs),
        if (annonce.traitements.isNotEmpty)
          FeatRowAnnonce(
            label: 'Traitements appliqués',
            value: '${annonce.traitements.length} déclaré'
                '${annonce.traitements.length > 1 ? 's' : ''}',
          ),
      ],
    );
  }
}
