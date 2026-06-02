import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/snackbars.dart';

/// Footer discret affichant la référence de la commande — petit, gris,
/// tappable pour copier dans le presse-papier.
///
/// Conçu pour remplacer l'affichage du long `#ORD-1779898061412-…`
/// dans la carte récap : l'utilisateur n'a pas besoin de le lire au
/// quotidien, mais doit pouvoir le retrouver/copier en cas de support.
/// On tronque l'affichage (« réf : …-1412 ») mais on copie le complet.
class PiedReferenceCommandeSucces extends StatelessWidget {
  const PiedReferenceCommandeSucces({required this.reference, super.key});

  /// Référence complète (ex: `ord-1779898061412-ab12`). Si vide, le
  /// widget rend un `SizedBox.shrink()`.
  final String reference;

  @override
  Widget build(BuildContext context) {
    final ref = reference.trim();
    if (ref.isEmpty) return const SizedBox.shrink();
    final court = _tronquer(ref);

    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: ref));
          if (context.mounted) {
            Snackbars.showSucces(context, 'Référence copiée');
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tag,
                size: 13,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Réf : $court',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.copy_outlined,
                size: 13,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Affichage court : on garde uniquement les 6 derniers caractères
  /// (suffisamment unique pour reconnaître sa commande), précédés de
  /// «…». Si la chaîne est déjà courte, on la rend telle quelle.
  String _tronquer(String ref) {
    if (ref.length <= 8) return ref;
    return '…${ref.substring(ref.length - 6)}';
  }
}
