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
import '../../widgets/producteur/profil/header_profil_editer.dart';
import '../../widgets/producteur/profil/label_profil_editer.dart';
import '../../widgets/producteur/profil/text_field_profil_editer.dart';
import '../../widgets/producteur/profil/ville_dropdown_profil_editer.dart';

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
            HeaderProfilEditer(busy: _saving, onSave: _onSave),
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
                    const LabelProfilEditer('Nom complet'),
                    AppDimens.vGap8,
                    TextFieldProfilEditer(
                      controller: _nomCtrl,
                      hint: 'Prénom Nom',
                      enabled: !_saving,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requis' : null,
                    ),
                    AppDimens.vGap16,
                    const LabelProfilEditer('Téléphone'),
                    AppDimens.vGap8,
                    TextFieldProfilEditer(
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
                    const LabelProfilEditer('Email (optionnel)'),
                    AppDimens.vGap8,
                    TextFieldProfilEditer(
                      controller: _emailCtrl,
                      hint: 'nom@exemple.ci',
                      enabled: !_saving,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    AppDimens.vGap16,
                    const LabelProfilEditer('Ville / Région'),
                    AppDimens.vGap8,
                    VilleDropdownProfilEditer(
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
