import 'package:flutter/material.dart';

import '../../../../theme/app_dimens.dart';
import 'assistant_constants.dart';
import 'suggestion_chip_assistant.dart';

/// Liste horizontale des suggestions au-dessus du champ de saisie quand
/// la conversation est vide.
class SuggestionsAssistant extends StatelessWidget {
  const SuggestionsAssistant({required this.onTap, super.key});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space8,
      ),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: kSuggestionsAssistant.length,
          separatorBuilder: (_, _) => AppDimens.hGap8,
          itemBuilder: (_, i) {
            final s = kSuggestionsAssistant[i];
            return SuggestionChipAssistant(label: s, onTap: () => onTap(s));
          },
        ),
      ),
    );
  }
}
