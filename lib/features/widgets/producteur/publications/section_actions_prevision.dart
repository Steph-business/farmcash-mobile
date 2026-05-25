import 'package:flutter/material.dart';

import 'action_button_prevision.dart';
import 'section_card_prevision.dart';

/// Section "Actions" de la page détail prévision : 2 boutons outline
/// (modifier la date / annuler) avec gestion d'état désactivé global.
///
/// Lorsque `disabled` vaut `true`, les boutons restent visibles mais avec
/// une opacité réduite et `onTap` qui ne fait rien.
class SectionActionsPrevision extends StatelessWidget {
  const SectionActionsPrevision({
    required this.disabled,
    required this.onModifierDate,
    required this.onAnnuler,
    super.key,
  });

  final bool disabled;
  final VoidCallback onModifierDate;
  final VoidCallback onAnnuler;

  @override
  Widget build(BuildContext context) {
    return SectionCardPrevision(
      title: 'Actions',
      children: [
        Opacity(
          opacity: disabled ? 0.4 : 1,
          child: ActionButtonPrevision(
            icon: Icons.calendar_today_outlined,
            label: 'Modifier la date de récolte',
            variant: ActionVariantPrevision.outlineGreen,
            onTap: disabled ? () {} : onModifierDate,
          ),
        ),
        const SizedBox(height: 10),
        Opacity(
          opacity: disabled ? 0.4 : 1,
          child: ActionButtonPrevision(
            icon: Icons.cancel_outlined,
            label: 'Annuler la prévision (remboursement automatique)',
            variant: ActionVariantPrevision.outlineGrey,
            onTap: disabled ? () {} : onAnnuler,
          ),
        ),
      ],
    );
  }
}
