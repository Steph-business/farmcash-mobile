import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api_client/api_exception.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../widgets/authentification/champ_telephone.dart';
import '../../widgets/authentification/pave_pin.dart';
import '../../widgets/authentification/selecteur_langue.dart';
import '../../widgets/communs/bouton_principal.dart';
import '../../widgets/communs/bouton_secondaire.dart';
import '../../widgets/communs/vue_erreur.dart';

/// Connexion par téléphone + code PIN — alignée maquette login.html.
class ConnexionPage extends ConsumerStatefulWidget {
  const ConnexionPage({super.key});

  @override
  ConsumerState<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends ConsumerState<ConnexionPage> {
  final _phoneCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _phoneCtrl.addListener(_onChanged);
    _pinCtrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    _phoneCtrl.removeListener(_onChanged);
    _pinCtrl.removeListener(_onChanged);
    _phoneCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  bool get _canSubmit {
    final phoneOk = ChampTelephone.validate(_phoneCtrl.text) == null;
    final pinOk = PavePin.validate(_pinCtrl.text) == null;
    return phoneOk && pinOk && !_loading;
  }

  Future<void> _seConnecter() async {
    final phoneErr = ChampTelephone.validate(_phoneCtrl.text);
    final pinErr = PavePin.validate(_pinCtrl.text);
    if (phoneErr != null) {
      setState(() => _error = phoneErr);
      return;
    }
    if (pinErr != null) {
      setState(() => _error = pinErr);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final phoneE164 = ChampTelephone.composeE164(_phoneCtrl.text);
    try {
      final tokens = await ref
          .read(authServiceProvider)
          .loginWithPin(phone: phoneE164, pin: _pinCtrl.text);

      final user = tokens.user ?? await ref.read(authServiceProvider).me();
      ref.read(authStateProvider.notifier).setAuthenticated(user);

      if (!mounted) return;
      // Le redirect global enverra automatiquement vers le home du rôle.
      // On force quand même pour fluidité.
      context.go('/');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e, st) {
      debugPrint('[connexion] exception inattendue : $e');
      debugPrint('$st');
      if (!mounted) return;
      setState(() => _error = 'Erreur de traitement : $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppDimens.vGap16,
              const Align(
                alignment: Alignment.centerRight,
                child: SelecteurLangue(),
              ),
              AppDimens.vGap24,
              const _Logo(),
              AppDimens.vGap32,
              Text('Connexion', style: AppTextStyles.displaySmall),
              AppDimens.vGap8,
              Text(
                'Entre ton numéro de téléphone et ton code PIN.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppDimens.vGap32,
              ChampTelephone(
                controller: _phoneCtrl,
                autofocus: true,
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
              AppDimens.vGap16,
              PavePin(
                controller: _pinCtrl,
                onSubmitted: (_) {
                  if (_canSubmit) _seConnecter();
                },
              ),
              AppDimens.vGap8,
              Align(
                alignment: Alignment.centerRight,
                child: BoutonSecondaire(
                  label: 'Code PIN oublié ?',
                  onPressed: () => context.go(RouteNames.pinOubliePath),
                ),
              ),
              if (_error != null) ...[
                AppDimens.vGap16,
                VueErreur(message: _error!),
              ],
              AppDimens.vGap24,
              BoutonPrincipal(
                label: 'Se connecter',
                onPressed: _canSubmit ? _seConnecter : null,
                isLoading: _loading,
                enabled: _canSubmit,
              ),
              AppDimens.vGap24,
              Center(
                child: LienTexte(
                  prefixe: 'Pas encore de compte ?',
                  lien: 'Créer un compte',
                  onPressed: () => context.go(RouteNames.choixRolePath),
                ),
              ),
              AppDimens.vGap32,
              const _MentionsLegales(),
              AppDimens.vGap16,
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.eco_outlined, size: 28, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          'FarmCash',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}

class _MentionsLegales extends StatelessWidget {
  const _MentionsLegales();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'En continuant, tu acceptes les Conditions et la Politique de confidentialité.',
        textAlign: TextAlign.center,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSubtle,
          fontSize: 11,
        ),
      ),
    );
  }
}
