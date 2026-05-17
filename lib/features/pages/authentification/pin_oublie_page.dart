import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/enums.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/authentification/champ_telephone.dart';
import '../../widgets/authentification/selecteur_langue.dart';
import '../../widgets/communs/bouton_principal.dart';
import '../../widgets/communs/bouton_secondaire.dart';
import '../../widgets/communs/vue_erreur.dart';

/// Récupération du code PIN — étape 1 : saisie du téléphone.
///
/// Déclenche l'envoi d'un OTP via [AuthService.sendOtp], puis navigue vers
/// `/otp?phone=...&purpose=reset_pin`. La même [OtpPage] gère ensuite la
/// vérification et la redirection vers `/pin/definir`.
class PinOubliePage extends ConsumerStatefulWidget {
  const PinOubliePage({super.key});

  @override
  ConsumerState<PinOubliePage> createState() => _PinOubliePageState();
}

class _PinOubliePageState extends ConsumerState<PinOubliePage> {
  final _phoneCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _phoneCtrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    _phoneCtrl.removeListener(_onChanged);
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  bool get _canSubmit =>
      ChampTelephone.validate(_phoneCtrl.text) == null && !_loading;

  Future<void> _envoyer() async {
    final err = ChampTelephone.validate(_phoneCtrl.text);
    if (err != null) {
      setState(() => _error = err);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final phoneE164 = ChampTelephone.composeE164(_phoneCtrl.text);
    try {
      await ref.read(authServiceProvider).sendOtp(
            phone: phoneE164,
            purpose: OtpPurpose.resetPin,
          );
      if (!mounted) return;
      context.go(
        '${RouteNames.otpPath}?phone=${Uri.encodeQueryComponent(phoneE164)}'
        '&purpose=reset_pin',
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Une erreur est survenue.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => context.go(RouteNames.connexionPath),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(
                alignment: Alignment.centerRight,
                child: SelecteurLangue(),
              ),
              AppDimens.vGap16,
              const _Logo(),
              AppDimens.vGap32,
              Text('Code PIN oublié', style: AppTextStyles.displaySmall),
              AppDimens.vGap8,
              Text(
                'Entre ton numéro pour recevoir un code de vérification.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppDimens.vGap32,
              ChampTelephone(
                controller: _phoneCtrl,
                autofocus: true,
                onSubmitted: (_) {
                  if (_canSubmit) _envoyer();
                },
              ),
              if (_error != null) ...[
                AppDimens.vGap16,
                VueErreur(message: _error!),
              ],
              AppDimens.vGap24,
              BoutonPrincipal(
                label: 'Recevoir un code',
                onPressed: _canSubmit ? _envoyer : null,
                isLoading: _loading,
                enabled: _canSubmit,
              ),
              AppDimens.vGap24,
              Center(
                child: LienTexte(
                  prefixe: 'Tu te souviens ?',
                  lien: 'Se connecter',
                  onPressed: () => context.go(RouteNames.connexionPath),
                ),
              ),
              AppDimens.vGap32,
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
        const Icon(Icons.eco_outlined, size: 28, color: AppColors.primary),
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
