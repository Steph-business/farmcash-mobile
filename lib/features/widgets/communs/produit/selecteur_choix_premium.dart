import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Calcule un monogramme à 1 lettre (majuscule) à partir d'un nom. On
/// saute les espaces/ponctuation initiaux pour ne pas tomber sur un
/// caractère vide. Retourne '?' si rien d'utile.
String _monogrammeDe(String nom) {
  for (final rune in nom.runes) {
    final ch = String.fromCharCode(rune);
    if (ch.trim().isNotEmpty && RegExp(r'[a-zA-ZÀ-ÿ]').hasMatch(ch)) {
      return ch.toUpperCase();
    }
  }
  return '?';
}

/// Sélecteur générique premium — tap-target + bottom sheet — réutilisable
/// pour TOUT type d'élément (Culture, Produit, ProduitOption…). Le widget
/// reçoit la liste typée `List<T>` et des **closures** pour extraire
/// emoji, titre, sous-titre, identifiant de chaque item.
///
/// La sheet : drag handle, titre + badge compteur, recherche live, items
/// scrollables avec pastille emoji + checkmark si sélectionné.
///
/// Pourquoi générique : 1 seul code visuel pour tous les acteurs (acheteur,
/// producteur, coop, transporteur) → cohérence parfaite, maintenance unique.
class SelecteurChoixPremium<T> extends StatelessWidget {
  const SelecteurChoixPremium({
    super.key,
    required this.items,
    required this.itemActuel,
    required this.onChanged,
    required this.titreOf,
    this.sousTitreOf,
    this.idOf,
    this.placeholder = 'Choisir',
    this.titreSheet = 'Choisis',
    this.enabled = true,
  });

  final List<T> items;
  final T? itemActuel;
  final ValueChanged<T> onChanged;

  /// Closure : T → titre principal affiché. La 1ère lettre alimente
  /// aussi le monogramme dans la pastille (avatar-like, neutre et juste).
  final String Function(T) titreOf;

  /// Closure optionnelle : T → sous-titre (ex: nom de parcelle, catégorie).
  final String? Function(T)? sousTitreOf;

  /// Closure optionnelle : T → identifiant unique (string). Si absent, on
  /// compare via `==`. Utile quand `==` n'est pas implémenté (DTO).
  final String Function(T)? idOf;

  final String placeholder;
  final String titreSheet;
  final bool enabled;

  Future<void> _ouvrir(BuildContext context) async {
    if (!enabled) return;
    final choisi = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder: (_) => _SheetChoix<T>(
        items: items,
        itemActuel: itemActuel,
        titre: titreSheet,
        titreOf: titreOf,
        sousTitreOf: sousTitreOf,
        idOf: idOf,
      ),
    );
    if (choisi != null) onChanged(choisi);
  }

  @override
  Widget build(BuildContext context) {
    final actuel = itemActuel;
    final titre = actuel == null ? placeholder : titreOf(actuel);
    final monogramme = actuel == null ? '?' : _monogrammeDe(titre);
    final sousTitre = actuel == null ? null : sousTitreOf?.call(actuel);

    return Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? () => _ouvrir(context) : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: actuel == null
                    ? AppColors.borderStrong
                    : AppColors.primary.withValues(alpha: 0.35),
                width: actuel == null ? 1 : 1.3,
              ),
            ),
            child: Row(
              children: [
                _Pastille(monogramme: monogramme, neutre: actuel == null),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        titre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleSmall.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: actuel == null
                              ? AppColors.textSecondary
                              : AppColors.text,
                        ),
                      ),
                      if (sousTitre != null && sousTitre.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          sousTitre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.unfold_more_rounded,
                  size: 20,
                  color: AppColors.textSubtle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Bottom sheet ────────────────────────────────────────────────

class _SheetChoix<T> extends StatefulWidget {
  const _SheetChoix({
    required this.items,
    required this.itemActuel,
    required this.titre,
    required this.titreOf,
    this.sousTitreOf,
    this.idOf,
  });

  final List<T> items;
  final T? itemActuel;
  final String titre;
  final String Function(T) titreOf;
  final String? Function(T)? sousTitreOf;
  final String Function(T)? idOf;

  @override
  State<_SheetChoix<T>> createState() => _SheetChoixState<T>();
}

class _SheetChoixState<T> extends State<_SheetChoix<T>> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      final v = _searchCtrl.text.trim();
      if (v != _query) setState(() => _query = v);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<T> get _filtres {
    if (_query.isEmpty) return widget.items;
    final q = _query.toLowerCase();
    return widget.items.where((it) {
      final titre = widget.titreOf(it).toLowerCase();
      final st = widget.sousTitreOf?.call(it)?.toLowerCase() ?? '';
      return titre.contains(q) || st.contains(q);
    }).toList();
  }

  bool _estActuel(T it) {
    final actuel = widget.itemActuel;
    if (actuel == null) return false;
    final getId = widget.idOf;
    if (getId != null) return getId(actuel) == getId(it);
    return actuel == it;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.42,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.titre,
                        style: AppTextStyles.titleLarge.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${widget.items.length}',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _ChampRecherche(controller: _searchCtrl),
              ),
              Expanded(
                child: _filtres.isEmpty
                    ? _ListeVide(query: _query)
                    : ListView.separated(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: _filtres.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 6),
                        itemBuilder: (_, i) {
                          final it = _filtres[i];
                          final titre = widget.titreOf(it);
                          return _Item(
                            monogramme: _monogrammeDe(titre),
                            titre: titre,
                            sousTitre: widget.sousTitreOf?.call(it),
                            selected: _estActuel(it),
                            onTap: () => Navigator.of(context).pop(it),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Sous-widgets ────────────────────────────────────────────────

class _ChampRecherche extends StatelessWidget {
  const _ChampRecherche({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      style: AppTextStyles.bodyMedium.copyWith(fontSize: 14.5),
      decoration: InputDecoration(
        hintText: 'Rechercher…',
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSubtle,
          fontSize: 14.5,
        ),
        filled: true,
        fillColor: AppColors.surfaceSoft,
        prefixIcon: const Icon(
          Icons.search_rounded,
          size: 20,
          color: AppColors.textSecondary,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.textSubtle,
                ),
                onPressed: () => controller.clear(),
              ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.45),
            width: 1.3,
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.monogramme,
    required this.titre,
    required this.sousTitre,
    required this.selected,
    required this.onTap,
  });

  final String monogramme;
  final String titre;
  final String? sousTitre;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.08)
          : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.45)
                  : AppColors.border,
              width: selected ? 1.3 : 1,
            ),
          ),
          child: Row(
            children: [
              _Pastille(monogramme: monogramme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    if (sousTitre != null && sousTitre!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        sousTitre!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (selected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pastille verte affichant la 1ère lettre du nom (style avatar/monogram).
/// Pourquoi pas d'emoji : un emoji n'est jamais juste à 100 % pour un
/// produit agricole (manioc ≠ patate, gombo ≠ concombre…). Le monogramme
/// reste neutre et distinct visuellement.
class _Pastille extends StatelessWidget {
  const _Pastille({required this.monogramme, this.neutre = false});
  final String monogramme;
  final bool neutre;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: neutre
            ? AppColors.surfaceSoft
            : AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        monogramme,
        style: AppTextStyles.titleLarge.copyWith(
          fontFamily: 'Poppins',
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: neutre ? AppColors.textSubtle : AppColors.primary,
          height: 1.0,
        ),
      ),
    );
  }
}

class _ListeVide extends StatelessWidget {
  const _ListeVide({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 36,
              color: AppColors.textSubtle,
            ),
            const SizedBox(height: 12),
            Text(
              query.isEmpty
                  ? 'Aucun élément disponible.'
                  : 'Aucun résultat pour « $query »',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
