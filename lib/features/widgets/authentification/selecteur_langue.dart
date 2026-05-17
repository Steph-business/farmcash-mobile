import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../storage/prefs_storage.dart';

/// Sélecteur de langue sobre : `FR ▾`.
///
/// PAS de drapeau, PAS de pilule colorée. Conforme DESIGN.md.
class SelecteurLangue extends ConsumerStatefulWidget {
  const SelecteurLangue({super.key});

  @override
  ConsumerState<SelecteurLangue> createState() => _SelecteurLangueState();
}

class _SelecteurLangueState extends ConsumerState<SelecteurLangue> {
  String _langue = 'FR';

  @override
  void initState() {
    super.initState();
    final saved = ref.read(prefsStorageProvider).locale;
    if (saved != null) _langue = saved.toUpperCase();
  }

  Future<void> _choisir() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Français'),
              trailing: _langue == 'FR'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.of(ctx).pop('FR'),
            ),
            ListTile(
              title: const Text('English'),
              trailing: _langue == 'EN'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.of(ctx).pop('EN'),
            ),
          ],
        ),
      ),
    );
    if (selected != null && selected != _langue) {
      setState(() => _langue = selected);
      await ref.read(prefsStorageProvider).setLocale(selected.toLowerCase());
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _choisir,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _langue,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
