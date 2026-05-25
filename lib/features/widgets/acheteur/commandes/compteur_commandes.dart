import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Pastel vert utilisé comme fond doux pour la KPI principale.
const Color _kPastelVert = Color(0xFFE8F5E9);

/// Bloc d'aperçu chiffré en haut de la liste « Mes commandes » côté
/// acheteur. Affiche **2 KPI côte à côte** :
///   - À gauche, fond pastel vert : les commandes EN COURS (besoin d'attention)
///   - À droite, fond blanc bordé : les commandes LIVRÉES (clôturées)
///
/// Pensé pour qu'un utilisateur low-tech voie d'un coup d'œil combien
/// d'actions sont en attente sans avoir à compter les cartes.
class CompteurCommandes extends StatelessWidget {
  const CompteurCommandes({
    required this.enCours,
    required this.livrees,
    super.key,
  });

  /// Nombre de commandes actuellement actives (SENT/ACCEPTED/IN_PROGRESS/
  /// DISPUTED). Mis en avant — c'est ce qui demande de l'attention.
  final int enCours;

  /// Nombre de commandes livrées / clôturées. Donné en repère mais sans
  /// urgence visuelle.
  final int livrees;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Kpi(
            valeur: enCours,
            libelle: enCours <= 1 ? 'En cours' : 'En cours',
            icone: Icons.local_shipping_outlined,
            // Variante « hero » avec fond pastel + valeur grosse en vert.
            highlight: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Kpi(
            valeur: livrees,
            libelle: livrees <= 1 ? 'Livrée' : 'Livrées',
            icone: Icons.check_circle_outline,
            highlight: false,
          ),
        ),
      ],
    );
  }
}

/// Une carte KPI : chiffre en gros + libellé court + icône thématique.
class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.valeur,
    required this.libelle,
    required this.icone,
    required this.highlight,
  });

  final int valeur;
  final String libelle;
  final IconData icone;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: highlight ? _kPastelVert : AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight
              ? AppColors.primary.withValues(alpha: 0.25)
              : AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: highlight ? AppColors.background : _kPastelVert,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icone, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$valeur',
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: highlight ? AppColors.primary : AppColors.text,
                    height: 1.0,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  libelle,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
