import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

/// Barre de recherche unifiée pour toute l'application.
///
/// Style aligné sur la page Marché (référence design) : hauteur 44,
/// borderRadius 12, fond gris doux, bordure fine `borderStrong`, icône
/// search 18 px à gauche.
///
/// Deux modes d'usage selon le besoin :
///
/// 1. **Read-only tappable** — pour les pages où le tap pousse vers un
///    écran dédié de recherche (ex. Marché, Accueil acheteur). Fournis
///    `onTap` et `placeholder`, omets `controller`.
///
///    ```dart
///    BarreRechercheCommune(
///      placeholder: 'Rechercher un produit, un vendeur…',
///      onTap: () => context.push(RouteNames.acheteurRecherchePath),
///    )
///    ```
///
/// 2. **Éditable** — pour les pages avec recherche inline (ex. Messages,
///    catalogue, sélection ville). Fournis `controller` + `onChanged`,
///    omets `onTap`.
///
///    ```dart
///    BarreRechercheCommune(
///      placeholder: 'Rechercher…',
///      controller: _searchCtrl,
///      onChanged: (v) => setState(() => _query = v),
///    )
///    ```
///
/// Quand le mode éditable a du texte, un bouton ✕ apparaît à droite pour
/// vider en un tap (pattern iOS / Telegram).
class BarreRechercheCommune extends StatefulWidget {
  const BarreRechercheCommune({
    required this.placeholder,
    this.controller,
    this.onChanged,
    this.onTap,
    super.key,
  }) : assert(
          (controller != null && onChanged != null) || onTap != null,
          'Fournis soit (controller + onChanged) pour le mode éditable, '
          'soit onTap pour le mode read-only tappable.',
        );

  /// Placeholder affiché quand la barre est vide. Adapté au contexte
  /// (ex. « Rechercher un produit, un vendeur… » sur Marché).
  final String placeholder;

  /// Mode éditable : controller du TextField. Si null → mode read-only.
  final TextEditingController? controller;

  /// Mode éditable : callback à chaque changement de texte.
  final ValueChanged<String>? onChanged;

  /// Mode read-only : callback au tap sur la barre entière.
  final VoidCallback? onTap;

  @override
  State<BarreRechercheCommune> createState() => _BarreRechercheCommuneState();
}

class _BarreRechercheCommuneState extends State<BarreRechercheCommune> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  void _clear() {
    widget.controller?.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final editable = widget.controller != null;
    final hasText = editable && widget.controller!.text.isNotEmpty;

    final box = Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderStrong,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: AppColors.textSubtle),
          const SizedBox(width: 10),
          Expanded(
            child: editable
                ? TextField(
                    controller: widget.controller,
                    onChanged: widget.onChanged,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13,
                      color: AppColors.text,
                    ),
                    textInputAction: TextInputAction.search,
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      // CRITIQUE : le theme global applique
                      // `filled: true` + `fillColor: background` sur tous
                      // les TextField. Sans override, on aurait un
                      // rectangle blanc DANS le container gris doux de
                      // la barre — effet « double zone » disgracieux.
                      // On force le TextField à être transparent ici
                      // pour qu'il s'intègre proprement dans la barre.
                      filled: false,
                      fillColor: Colors.transparent,
                      hintText: widget.placeholder,
                      hintStyle: AppTextStyles.hint.copyWith(
                        fontSize: 13,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  )
                : Text(
                    widget.placeholder,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13,
                      color: AppColors.textSubtle,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          if (hasText)
            GestureDetector(
              onTap: _clear,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(left: 6),
                decoration: const BoxDecoration(
                  color: AppColors.textSubtle,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );

    // En mode read-only, on enveloppe d'un InkWell pour ouvrir la page
    // de recherche dédiée au tap.
    if (!editable && widget.onTap != null) {
      return InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: box,
      );
    }
    return box;
  }
}
