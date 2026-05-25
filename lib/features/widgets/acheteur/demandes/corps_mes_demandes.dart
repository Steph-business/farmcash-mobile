import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import 'carte_demande_acheteur.dart';
import 'compteur_mes_demandes.dart';
import 'modele_demande_affichage.dart';
import 'onglets_mes_demandes.dart';

/// Corps scrollable de la page « Mes demandes » : compteur, onglets et
/// liste des cartes pour l'onglet sélectionné.
class CorpsMesDemandes extends StatelessWidget {
  const CorpsMesDemandes({
    required this.items,
    required this.tab,
    required this.onTabChange,
    super.key,
  });

  /// Demandes (déjà formatées en `ModeleDemandeAffichage`).
  final List<ModeleDemandeAffichage> items;

  /// Onglet courant.
  final OngletMesDemandes tab;

  /// Callback de changement d'onglet.
  final ValueChanged<OngletMesDemandes> onTabChange;

  @override
  Widget build(BuildContext context) {
    final actives = items.length;
    final totalPropositions =
        items.fold<int>(0, (sum, d) => sum + d.propositions);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        CompteurMesDemandes(
          actives: actives,
          totalPropositions: totalPropositions,
        ),
        OngletsMesDemandes(
          tab: tab,
          activesCount: actives,
          onChange: onTabChange,
        ),
        const SizedBox(height: 14),
        if (tab == OngletMesDemandes.actives)
          for (final d in items) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: CarteDemandeAcheteur(demande: d),
            ),
          ]
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Center(
              child: Text(
                tab == OngletMesDemandes.conclues
                    ? 'Aucune demande conclue pour l\'instant.'
                    : 'Aucune demande archivée.',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
