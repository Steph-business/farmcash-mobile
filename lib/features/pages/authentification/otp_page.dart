import 'dart:async';

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
import '../../widgets/authentification/bloc_renvoi_otp.dart';
import '../../widgets/authentification/logo_otp.dart';
import '../../widgets/authentification/saisie_otp.dart';
import '../../widgets/authentification/selecteur_langue.dart';
import '../../widgets/authentification/sous_titre_otp.dart';
import '../../widgets/communs/bouton_principal.dart';
import '../../widgets/communs/bouton_secondaire.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/communs/vue_erreur.dart';

/// Vérification du code OTP envoyé par SMS.
///
/// Gère deux flows :
///  - `purpose == 'register'` : après inscription, on bascule vers /pin/definir
///    (le user n'a pas encore de PIN à ce stade).
///  - `purpose == 'reset_pin'` : récupération PIN, on bascule également vers
///    /pin/definir pour permettre la redéfinition.
class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({
    required this.phone,
    required this.purpose,
    super.key,
  });

  /// Téléphone E.164, ex: `+22507123456`.
  final String phone;

  /// `'register'` ou `'reset_pin'`.
  final String purpose;

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  static const int _resendCooldown = 30;
  final GlobalKey<SaisieOtpState> _otpKey = GlobalKey<SaisieOtpState>();

  String _otp = '';
  bool _loading = false;
  bool _resending = false;
  String? _error;

  Timer? _timer;
  int _secondsLeft = _resendCooldown;

  bool get _isResetPin => widget.purpose == 'reset_pin';

  /// Mappe le `purpose` reçu en query param (string lowercase) vers l'enum
  /// envoyé au backend (`REGISTER` / `RESET_PIN` / `LOGIN`).
  OtpPurpose get _otpPurpose {
    switch (widget.purpose) {
      case 'reset_pin':
        return OtpPurpose.resetPin;
      case 'login':
        return OtpPurpose.login;
      case 'register':
      default:
        return OtpPurpose.register;
    }
  }

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendCooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  void _onOtpChanged(String value) {
    setState(() {
      _otp = value;
      if (_error != null) _error = null;
    });
  }

  Future<void> _verifier() async {
    if (_otp.length != 6 || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(authServiceProvider).verifyOtp(
            phone: widget.phone,
            code: _otp,
            purpose: _otpPurpose,
          );

      if (!mounted) return;

      // register et reset_pin : on enchaîne sur la définition du PIN.
      // À ce stade le user n'a pas (encore) de PIN actif. Les tokens sont
      // déjà persistés par AuthService, mais on ne marque pas l'auth
      // comme complète tant que le PIN n'est pas défini.
      context.go(RouteNames.definirPinPath);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
      _otpKey.currentState?.reset();
      setState(() => _otp = '');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Une erreur est survenue.';
        _loading = false;
      });
      _otpKey.currentState?.reset();
      setState(() => _otp = '');
    }
  }

  Future<void> _renvoyer() async {
    if (_secondsLeft > 0 || _resending) return;
    setState(() {
      _resending = true;
      _error = null;
    });

    try {
      await ref.read(authServiceProvider).sendOtp(
            phone: widget.phone,
            purpose: _otpPurpose,
          );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Code renvoyé');
      _startCooldown();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Impossible de renvoyer le code.');
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _retour() {
    if (_isResetPin) {
      context.go(RouteNames.connexionPath);
    } else {
      context.go(RouteNames.choixRolePath);
    }
  }

  void _changerNumero() {
    if (_isResetPin) {
      context.go(RouteNames.pinOubliePath);
    } else {
      context.go(RouteNames.choixRolePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _otp.length == 6 && !_loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: _retour,
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
              const LogoOtp(),
              AppDimens.vGap32,
              Text('Vérification', style: AppTextStyles.displaySmall),
              AppDimens.vGap8,
              SousTitreOtp(phone: widget.phone),
              AppDimens.vGap32,
              SaisieOtp(
                key: _otpKey,
                enabled: !_loading,
                onChanged: _onOtpChanged,
                onCompleted: (_) {
                  if (!_loading) _verifier();
                },
              ),
              AppDimens.vGap16,
              BlocRenvoiOtp(
                secondsLeft: _secondsLeft,
                resending: _resending,
                onRenvoyer: _renvoyer,
              ),
              if (_error != null) ...[
                AppDimens.vGap16,
                VueErreur(message: _error!),
              ],
              AppDimens.vGap24,
              BoutonPrincipal(
                label: 'Vérifier',
                onPressed: canSubmit ? _verifier : null,
                isLoading: _loading,
                enabled: canSubmit,
              ),
              AppDimens.vGap24,
              Center(
                child: BoutonSecondaire(
                  label: 'Changer de numéro',
                  onPressed: _changerNumero,
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
