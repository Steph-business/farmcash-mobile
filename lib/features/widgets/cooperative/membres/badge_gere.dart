import 'package:flutter/material.dart';

import '../../../../theme/app_text_styles.dart';

const Color _kBadgeBg = Color(0xFFFFF4E5);
const Color _kBadgeFg = Color(0xFFAA6A00);

/// Petit badge « Géré » avec une icône téléphone barré, affiché à côté du
/// nom d'un membre dont le compte est géré par la coopérative (pas de
/// téléphone, pas de connexion possible).
class BadgeGere extends StatelessWidget {
  const BadgeGere({super.key, this.compact = false});

  /// Variante compacte (juste l'icône, sans le texte) — utile dans une
  /// ligne très dense.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _kBadgeBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.phone_disabled_outlined,
            size: 12,
            color: _kBadgeFg,
          ),
          if (!compact) ...[
            const SizedBox(width: 3),
            Text(
              'Géré',
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _kBadgeFg,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
