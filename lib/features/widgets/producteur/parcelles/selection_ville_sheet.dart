import 'package:flutter/material.dart';

import '../../../../models/ville.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Bottom sheet de sélection manuelle d'une ville depuis le référentiel.
///
/// Utilisé en fallback quand le producteur n'est pas physiquement sur sa
/// parcelle, ou pour corriger la ville détectée automatiquement.
/// Retourne la `Ville` choisie via `Navigator.pop`, ou `null` si annulé.
class SelectionVilleSheet extends StatefulWidget {
  const SelectionVilleSheet({
    required this.villes,
    this.initialId,
    super.key,
  });

  final List<Ville> villes;
  final String? initialId;

  @override
  State<SelectionVilleSheet> createState() => _SelectionVilleSheetState();
}

class _SelectionVilleSheetState extends State<SelectionVilleSheet> {
  String _query = '';

  List<Ville> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.villes;
    return widget.villes
        .where((v) =>
            v.nom.toLowerCase().contains(q) ||
            (v.regionNom?.toLowerCase().contains(q) ?? false))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: mq.size.height * 0.75,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.space24,
                  AppDimens.space16,
                  AppDimens.space24,
                  AppDimens.space12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choisir une ville',
                      style: AppTextStyles.titleLarge,
                    ),
                    AppDimens.vGap12,
                    TextField(
                      autofocus: true,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: const InputDecoration(
                        hintText: 'Rechercher une ville',
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                          size: AppDimens.iconM,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 1,
                thickness: AppDimens.borderThin,
                color: AppColors.border,
              ),
              Expanded(
                child: _filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppDimens.space24),
                        child: Text(
                          'Aucune ville trouvée.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimens.space8,
                        ),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          thickness: AppDimens.borderThin,
                          color: AppColors.border,
                        ),
                        itemBuilder: (ctx, i) {
                          final v = _filtered[i];
                          final isCurrent = widget.initialId == v.id;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.space24,
                              vertical: 2,
                            ),
                            title: Text(
                              v.displayWithRegion,
                              style: AppTextStyles.titleSmall,
                            ),
                            trailing: isCurrent
                                ? const Icon(
                                    Icons.check,
                                    size: AppDimens.iconM,
                                    color: AppColors.primary,
                                  )
                                : null,
                            onTap: () => Navigator.of(context).pop(v),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
