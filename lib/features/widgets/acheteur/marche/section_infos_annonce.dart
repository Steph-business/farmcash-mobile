import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/annonce_vente.dart';
import 'annonce_detail_constants.dart';
import 'info_row_annonce.dart';
import 'section_annonce.dart';

/// Section "Informations" : quantité min commande, date de publication,
/// date limite de disponibilité, nombre de vues. Les champs nullables sont
/// omis pour éviter d'afficher "—" partout.
class SectionInfosAnnonce extends StatelessWidget {
  const SectionInfosAnnonce({
    required this.annonce,
    required this.qteMinKg,
    super.key,
  });

  final AnnonceVente annonce;
  final int qteMinKg;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMMM y', 'fr_FR');
    final publie = annonce.createdAt;
    final dispo = annonce.disponibleJusqu;

    return SectionAnnonce(
      title: 'Informations',
      child: Column(
        children: [
          InfoRowAnnonce(
            label: 'Quantité min. à commander',
            value: '${kAnnonceDetailNumFmt.format(qteMinKg)} kg',
          ),
          if (publie != null)
            InfoRowAnnonce(
              label: 'Publié le',
              value: df.format(publie),
            ),
          if (dispo != null)
            InfoRowAnnonce(
              label: 'Disponible jusqu\'au',
              value: df.format(dispo),
            ),
          InfoRowAnnonce(
            label: 'Vues',
            value: '${annonce.viewsCount}',
          ),
        ],
      ),
    );
  }
}
