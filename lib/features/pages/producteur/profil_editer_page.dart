import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/ville.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/snackbars.dart';

/// Charge la liste des villes CI une fois — sert pour le dropdown ville.
final _villesProfilProvider =
    FutureProvider.autoDispose<List<Ville>>((ref) async {
  try {
    return await ref.read(marketplaceServiceProvider).listVilles();
  } catch (_) {
    return const <Ville>[];
  }
});

/// Édition du profil producteur. Sauvegarde via `auth/profile/update`
/// (nom, email) — la ville est un champ "extra" remonté côté back dans
/// le profil étendu producteur.
class ProfilEditerPage extends ConsumerStatefulWidget {
  const ProfilEditerPage({super.key});

  @override
  ConsumerState<ProfilEditerPage> createState() => _ProfilEditerPageState();
}

class _ProfilEditerPageState extends ConsumerState<ProfilEditerPage> {
  late final TextEditingController _nomCtrl;
  late final TextEditingController _emailCtrl;
  String? _villeIdSelectionnee;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nomCtrl = TextEditingController(text: user?.fullName ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      // 1. Update profile de base (nom + email).
      await ref.read(authServiceProvider).updateProfile(
            fullName: _nomCtrl.text.trim(),
            email: _emailCtrl.text.trim().isEmpty
                ? null
                : _emailCtrl.text.trim(),
            extra: _villeIdSelectionnee != null
                ? {'ville_id': _villeIdSelectionnee}
                : null,
          );
      // 2. Rafraîchit le user dans l'état global.
      await ref.read(authStateProvider.notifier).refreshMe();
      if (!mounted) return;
      Snackbars.showSucces(context, 'Profil mis à jour');
      if (context.canPop()) context.pop();
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final asyncVilles = ref.watch(_villesProfilProvider);
    final villes = asyncVilles.value ?? const <Ville>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(busy: _saving, onSave: _onSave),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.pagePaddingH,
                    AppDimens.space16,
                    AppDimens.pagePaddingH,
                    AppDimens.space24,
                  ),
                  children: [
                    const _Label('Nom complet'),
                    AppDimens.vGap8,
                    _TextField(
                      controller: _nomCtrl,
                      hint: 'Prénom Nom',
                      enabled: !_saving,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requis' : null,
                    ),
                    AppDimens.vGap16,
                    const _Label('Téléphone'),
                    AppDimens.vGap8,
                    _TextField(
                      controller: TextEditingController(
                        text: user?.phone ?? '',
                      ),
                      hint: '+225 ...',
                      enabled: false,
                      keyboardType: TextInputType.phone,
                      helperText:
                          'Le numéro est rattaché à ton compte et ne peut pas être changé ici.',
                    ),
                    AppDimens.vGap16,
                    const _Label('Email (optionnel)'),
                    AppDimens.vGap8,
                    _TextField(
                      controller: _emailCtrl,
                      hint: 'nom@exemple.ci',
                      enabled: !_saving,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    AppDimens.vGap16,
                    const _Label('Ville / Région'),
                    AppDimens.vGap8,
                    _VilleDropdown(
                      villes: villes,
                      loading: asyncVilles.isLoading,
                      enabled: !_saving,
                      selectedId: _villeIdSelectionnee,
                      onChanged: (id) =>
                          setState(() => _villeIdSelectionnee = id),
                    ),
                    AppDimens.vGap24,
                    Text(
                      'Ces informations sont visibles uniquement par ta '
                      'coopérative et la plateforme FarmCash.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.busy, required this.onSave});
  final bool busy;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space16,
        AppDimens.space8,
        AppDimens.space16,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Modifier le profil',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (busy)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          else
            TextButton(
              onPressed: onSave,
              child: Text(
                'Enregistrer',
                style: AppTextStyles.link.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.validator,
    this.enabled = true,
    this.helperText,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSubtle,
        ),
        helperText: helperText,
        helperStyle: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          color: AppColors.textSubtle,
        ),
        filled: true,
        fillColor: enabled ? AppColors.surface : AppColors.surfaceSoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: AppDimens.brInput,
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimens.brInput,
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimens.brInput,
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: AppDimens.borderMedium,
          ),
        ),
      ),
    );
  }
}

class _VilleDropdown extends StatelessWidget {
  const _VilleDropdown({
    required this.villes,
    required this.loading,
    required this.enabled,
    required this.selectedId,
    required this.onChanged,
  });

  final List<Ville> villes;
  final bool loading;
  final bool enabled;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppDimens.brInput,
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Text(
              'Chargement des villes…',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSubtle,
              ),
            ),
          ],
        ),
      );
    }
    return DropdownButtonFormField<String>(
      initialValue: selectedId,
      isExpanded: true,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        hintText: 'Choisir une ville',
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSubtle,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: AppDimens.brInput,
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimens.brInput,
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimens.brInput,
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: AppDimens.borderMedium,
          ),
        ),
      ),
      items: [
        for (final v in villes)
          DropdownMenuItem<String>(
            value: v.id,
            child: Text(v.nom),
          ),
      ],
    );
  }
}
