import 'package:flutter/material.dart';

import '../../../../models/sollicitation.dart';
import '../../../../theme/app_dimens.dart';
import 'sollicitation_recue_card.dart';

/// Liste verticale des sollicitations recues — separe en cartes individuelles.
class ListeSollicitationsRecues extends StatelessWidget {
  const ListeSollicitationsRecues({required this.items, super.key});

  final List<Sollicitation> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: SollicitationRecueCard(sol: items[i]),
      ),
    );
  }
}
