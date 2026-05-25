import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/profil_settings/entete_profil_settings.dart';
import '../../../widgets/communs/profil_settings/titre_section_settings.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/cooperative/documents_officiels/carte_document_coop.dart';

/// Modèle interne d'un document attendu côté coop.
class _Document {
  const _Document({
    required this.icone,
    required this.nom,
    required this.description,
    required this.statut,
    this.dateUpload,
  });

  final IconData icone;
  final String nom;
  final String description;
  final StatutDocumentCoop statut;
  final String? dateUpload;
}

/// Page Documents officiels (coopérative) — KYC coop.
///
/// Liste les documents légaux attendus avec leur statut (validé / en
/// attente / expiré / manquant) et permet d'upload / remplacer / visualiser.
/// V1 : mock + snackbars, à brancher à un service backend KYC dédié.
class DocumentsOfficielsCoopPage extends ConsumerStatefulWidget {
  /// Construit la page Documents officiels.
  const DocumentsOfficielsCoopPage({super.key});

  @override
  ConsumerState<DocumentsOfficielsCoopPage> createState() =>
      _DocumentsOfficielsCoopPageState();
}

class _DocumentsOfficielsCoopPageState
    extends ConsumerState<DocumentsOfficielsCoopPage> {
  late List<_Document> _documents;

  @override
  void initState() {
    super.initState();
    _documents = const [
      _Document(
        icone: Icons.verified_outlined,
        nom: 'Agrément coopérative',
        description:
            'Délivré par le Ministère de l\'Agriculture. Obligatoire pour '
            'opérer sur la plateforme.',
        statut: StatutDocumentCoop.valide,
        dateUpload: '12 février 2024',
      ),
      _Document(
        icone: Icons.description_outlined,
        nom: 'Statuts de la coopérative',
        description:
            'Document fondateur définissant la gouvernance et les règles '
            'de la coop.',
        statut: StatutDocumentCoop.valide,
        dateUpload: '12 février 2024',
      ),
      _Document(
        icone: Icons.assignment_ind_outlined,
        nom: 'Pièce d\'identité du président',
        description:
            'CNI ou passeport en cours de validité du représentant légal.',
        statut: StatutDocumentCoop.enAttente,
        dateUpload: '20 mai 2026',
      ),
      _Document(
        icone: Icons.account_balance_outlined,
        nom: 'RIB / Attestation bancaire',
        description:
            'Permet de recevoir les paiements et distributions par '
            'virement bancaire.',
        statut: StatutDocumentCoop.refuse,
        dateUpload: '03 mai 2026',
      ),
      _Document(
        icone: Icons.shield_outlined,
        nom: 'Attestation d\'assurance',
        description:
            'Couvre les risques liés à l\'activité (annuelle). À renouveler '
            'chaque année.',
        statut: StatutDocumentCoop.expire,
        dateUpload: '15 janvier 2025',
      ),
      _Document(
        icone: Icons.receipt_long_outlined,
        nom: 'Récépissé de dépôt',
        description:
            'Attestation d\'enregistrement officielle de la coopérative.',
        statut: StatutDocumentCoop.manquant,
      ),
    ];
  }

  int get _nbValides =>
      _documents.where((d) => d.statut == StatutDocumentCoop.valide).length;

  int get _nbProblemes => _documents
      .where((d) =>
          d.statut == StatutDocumentCoop.refuse ||
          d.statut == StatutDocumentCoop.expire ||
          d.statut == StatutDocumentCoop.manquant)
      .length;

  void _actionDocument(_Document d) {
    final action = switch (d.statut) {
      StatutDocumentCoop.manquant => 'Uploader',
      StatutDocumentCoop.enAttente => 'Visualiser',
      StatutDocumentCoop.valide => 'Visualiser / Remplacer',
      StatutDocumentCoop.refuse => 'Re-uploader',
      StatutDocumentCoop.expire => 'Re-uploader',
    };
    Snackbars.showInfo(
      context,
      '$action ${d.nom} — à venir',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EnteteProfilSettings(
              fallbackPath: RouteNames.cooperativeProfilPath,
              titre: 'Documents officiels',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  AppDimens.space8,
                  AppDimens.pagePaddingH,
                  AppDimens.space24,
                ),
                children: [
                  // Bandeau résumé KYC
                  _BandeauResume(
                    nbValides: _nbValides,
                    nbProblemes: _nbProblemes,
                    nbTotal: _documents.length,
                  ),
                  AppDimens.vGap16,

                  // Section problèmes (si présents)
                  if (_nbProblemes > 0) ...[
                    const TitreSectionSettings('À traiter en priorité'),
                    for (final d in _documents.where((x) =>
                        x.statut == StatutDocumentCoop.refuse ||
                        x.statut == StatutDocumentCoop.expire ||
                        x.statut == StatutDocumentCoop.manquant))
                      CarteDocumentCoop(
                        icone: d.icone,
                        nom: d.nom,
                        description: d.description,
                        statut: d.statut,
                        dateUpload: d.dateUpload,
                        onAction: () => _actionDocument(d),
                      ),
                    AppDimens.vGap16,
                  ],

                  // Section OK
                  const TitreSectionSettings('Documents validés / en cours'),
                  for (final d in _documents.where((x) =>
                      x.statut == StatutDocumentCoop.valide ||
                      x.statut == StatutDocumentCoop.enAttente))
                    CarteDocumentCoop(
                      icone: d.icone,
                      nom: d.nom,
                      description: d.description,
                      statut: d.statut,
                      dateUpload: d.dateUpload,
                      onAction: () => _actionDocument(d),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BandeauResume extends StatelessWidget {
  const _BandeauResume({
    required this.nbValides,
    required this.nbProblemes,
    required this.nbTotal,
  });

  final int nbValides;
  final int nbProblemes;
  final int nbTotal;

  @override
  Widget build(BuildContext context) {
    final progres = nbTotal == 0 ? 0.0 : nbValides / nbTotal;
    final tousValides = nbValides == nbTotal;
    final couleur =
        tousValides ? AppColors.success : AppColors.primary;
    final fond = tousValides
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFE8F5E9);

    return Container(
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: couleur.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                tousValides ? Icons.verified : Icons.fact_check_outlined,
                color: couleur,
                size: 24,
              ),
              AppDimens.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tousValides
                          ? 'KYC coopérative complet'
                          : 'KYC coopérative : $nbValides / $nbTotal documents validés',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: couleur,
                      ),
                    ),
                    if (nbProblemes > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '$nbProblemes document${nbProblemes > 1 ? "s" : ""} '
                        'à traiter',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          AppDimens.vGap12,
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progres,
              minHeight: 6,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(couleur),
            ),
          ),
        ],
      ),
    );
  }
}
