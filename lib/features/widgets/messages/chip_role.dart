import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'messages_types.dart';

// ─── Palettes — alignées sur les maquettes ────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
// Producteur viewer
const Color _kChipAcheteurBg = Color(0xFFFFF8E1);
const Color _kChipAcheteurFg = Color(0xFFB26A00);
const Color _kChipTransportBg = Color(0xFFDBEAFE);
const Color _kChipTransportFg = Color(0xFF1D4ED8);
// Acheteur viewer
const Color _kChipCoopBgAcheteur = Color(0xFFEFF6FF);
const Color _kChipCoopFgAcheteur = Color(0xFF1E40AF);
const Color _kChipTransBgAcheteur = Color(0xFFFEF3C7);
const Color _kChipTransFgAcheteur = Color(0xFFB45309);
// Transporteur viewer
const Color _kChipCoopBgTransp = Color(0xFFE0E7FF);
const Color _kChipCoopFgTransp = Color(0xFF3730A3);
const Color _kChipAcheteurBgTransp = Color(0xFFFFF8E1);
const Color _kChipAcheteurFgTransp = Color(0xFFB26A00);

/// Badge bas-niveau utilisé par les `ChipRole*` posés sous l'avatar.
///
/// Border blanche 1.5 px → effet "détaché" du fond avatar. Utilisé en
/// `Positioned` overlay sur l'avatar dans `TuileConversationAvecChip`.
class ChipBadge extends StatelessWidget {
  const ChipBadge({
    required this.label,
    required this.bg,
    required this.fg,
    super.key,
  });

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.background, width: 1.5),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1,
        ),
      ),
    );
  }
}

/// Chip rôle posé sous l'avatar, palette **producteur viewer**.
///
/// Affiche la nature de l'interlocuteur (coop vert, acheteur orange,
/// transp. bleu). Utilisé dans `TuileConversationAvecChip`.
class ChipRoleProducteur extends StatelessWidget {
  const ChipRoleProducteur({required this.role, super.key});

  final RoleInterlocuteur role;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (role) {
      RoleInterlocuteur.coop => ('Coop', _kPrimarySoft, AppColors.primary),
      RoleInterlocuteur.acheteur =>
        ('Acheteur', _kChipAcheteurBg, _kChipAcheteurFg),
      RoleInterlocuteur.transport =>
        ('Transp.', _kChipTransportBg, _kChipTransportFg),
      RoleInterlocuteur.farmer =>
        ('Farmer', _kPrimarySoft, AppColors.primary),
    };
    return ChipBadge(label: label, bg: bg, fg: fg);
  }
}

/// Chip rôle posé sous l'avatar, palette **transporteur viewer**.
///
/// Variantes coop indigo (vs. vert pour le producteur). Mêmes positions
/// que `ChipRoleProducteur`, structurellement identique.
class ChipRoleTransporteur extends StatelessWidget {
  const ChipRoleTransporteur({required this.role, super.key});

  final RoleInterlocuteur role;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (role) {
      RoleInterlocuteur.farmer =>
        ('Farmer', _kPrimarySoft, AppColors.primary),
      RoleInterlocuteur.coop =>
        ('Coop', _kChipCoopBgTransp, _kChipCoopFgTransp),
      RoleInterlocuteur.acheteur =>
        ('Acheteur', _kChipAcheteurBgTransp, _kChipAcheteurFgTransp),
      RoleInterlocuteur.transport =>
        ('Transp.', _kChipTransportBg, _kChipTransportFg),
    };
    return ChipBadge(label: label, bg: bg, fg: fg);
  }
}

/// Chip rôle palette **acheteur viewer** — affiché À CÔTÉ du nom
/// (et non sous l'avatar). Pas de border blanche (rendu inline texte),
/// radius 5 plus serré pour s'intégrer dans la ligne du nom.
class ChipRoleAcheteur extends StatelessWidget {
  const ChipRoleAcheteur({required this.role, super.key});

  final RoleInterlocuteur role;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (role) {
      RoleInterlocuteur.farmer =>
        ('Farmer', _kPrimarySoft, AppColors.primary),
      RoleInterlocuteur.coop =>
        ('Coop', _kChipCoopBgAcheteur, _kChipCoopFgAcheteur),
      RoleInterlocuteur.transport =>
        ('Transport', _kChipTransBgAcheteur, _kChipTransFgAcheteur),
      RoleInterlocuteur.acheteur =>
        ('Acheteur', _kChipAcheteurBg, _kChipAcheteurFg),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1.2,
        ),
      ),
    );
  }
}
