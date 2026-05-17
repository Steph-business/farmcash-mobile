import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/enums.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../storage/secure_storage.dart';
import '../../widgets/authentification/pave_pin.dart';
import '../../widgets/authentification/selecteur_langue.dart';
import '../../widgets/communs/bouton_principal.dart';
import '../../widgets/communs/vue_erreur.dart';

/// Définition d'un code PIN (4 à 6 chiffres) après OTP réussi.
///
/// Étape commune aux flows inscription et récupération PIN. Une fois le PIN
/// posé via [AuthService.setPin], on rafraîchit le profil et on marque
/// l'auth comme complète — le redirect global se chargera de pousser vers
/// le home du rôle.
class DefinirPinPage extends ConsumerStatefulWidget {
  const DefinirPinPage({super.key});

  @override
  ConsumerState<DefinirPinPage> createState() => _DefinirPinPageState();
}

class _DefinirPinPageState extends ConsumerState<DefinirPinPage> {
  static const int _minLen = 4;
  static const int _maxLen = 6;

  final _pin1Ctrl = TextEditingController();
  final _pin2Ctrl = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pin1Ctrl.addListener(_onChanged);
    _pin2Ctrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    _pin1Ctrl.removeListener(_onChanged);
    _pin2Ctrl.removeListener(_onChanged);
    _pin1Ctrl.dispose();
    _pin2Ctrl.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  /// Clé miroir de [InscriptionPage] — voir le commentaire là-bas.
  static const _kPendingProfileKey = 'fc_pending_role_profile';

  Future<void> _pushPendingProfileIfAny(
    dynamic auth,
    UserRole currentRole,
  ) async {
    final storage = ref.read(secureStorageProvider);
    final raw = await storage.read(_kPendingProfileKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final storedRole = UserRole.values.firstWhere(
        (r) => r.apiValue == (decoded['role'] as String?),
        orElse: () => UserRole.unknown,
      );
      // Sécurité : si le rôle stocké ne matche pas le user réel, on ignore.
      if (storedRole != currentRole) {
        await storage.delete(_kPendingProfileKey);
        return;
      }
      final data = (decoded['data'] as Map?)?.cast<String, dynamic>();
      if (data == null || data.isEmpty) {
        await storage.delete(_kPendingProfileKey);
        return;
      }
      await auth.updateRoleProfile(role: currentRole, profile: data);
    } catch (e) {
      debugPrint('[definirPin] push profile étendu ignoré : $e');
    } finally {
      await storage.delete(_kPendingProfileKey);
    }
  }

  bool get _pin1Valid =>
      PavePin.validate(_pin1Ctrl.text, min: _minLen, max: _maxLen) == null;

  bool get _pin2Valid =>
      PavePin.validate(_pin2Ctrl.text, min: _minLen, max: _maxLen) == null;

  bool get _pinsMatch => _pin1Ctrl.text == _pin2Ctrl.text;

  bool get _showMismatch =>
      _pin2Ctrl.text.length >= _minLen && _pin1Valid && !_pinsMatch;

  bool get _canSubmit =>
      _pin1Valid && _pin2Valid && _pinsMatch && !_loading;

  Future<void> _continuer() async {
    final err1 = PavePin.validate(_pin1Ctrl.text, min: _minLen, max: _maxLen);
    if (err1 != null) {
      setState(() => _error = err1);
      return;
    }
    final err2 = PavePin.validate(_pin2Ctrl.text, min: _minLen, max: _maxLen);
    if (err2 != null) {
      setState(() => _error = err2);
      return;
    }
    if (!_pinsMatch) {
      setState(() => _error = 'Les codes ne correspondent pas');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      await auth.setPin(
        pin: _pin1Ctrl.text,
        pinConfirm: _pin2Ctrl.text,
      );
      final user = await auth.me();

      // Best-effort : pousser le profil étendu collecté à l'inscription.
      // Si ça échoue, on ne bloque pas l'utilisateur — il pourra éditer
      // son profil plus tard depuis l'écran "Mon profil".
      await _pushPendingProfileIfAny(auth, user.role);

      if (!mounted) return;
      ref.read(authStateProvider.notifier).setAuthenticated(user);
      // Le redirect global pousse automatiquement vers le home du rôle.
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Une erreur est survenue.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pas de back navigation : la page est un point de passage obligé.
    return PopScope(
      canPop: false,
      child: Scaffold(
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
                Text('Définir un code PIN', style: AppTextStyles.displaySmall),
                AppDimens.vGap8,
                Text(
                  'Choisis un code de 4 à 6 chiffres. '
                  'Tu l\'utiliseras à chaque connexion.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                AppDimens.vGap32,
                PavePin(
                  controller: _pin1Ctrl,
                  label: 'Nouveau code PIN',
                  minLength: _minLen,
                  maxLength: _maxLen,
                  autofocus: true,
                  enabled: !_loading,
                ),
                AppDimens.vGap16,
                PavePin(
                  controller: _pin2Ctrl,
                  label: 'Confirmer le code PIN',
                  minLength: _minLen,
                  maxLength: _maxLen,
                  enabled: !_loading,
                  onSubmitted: (_) {
                    if (_canSubmit) _continuer();
                  },
                ),
                if (_showMismatch) ...[
                  AppDimens.vGap16,
                  const VueErreur(
                    message: 'Les codes ne correspondent pas',
                  ),
                ],
                if (_error != null) ...[
                  AppDimens.vGap16,
                  VueErreur(message: _error!),
                ],
                AppDimens.vGap24,
                BoutonPrincipal(
                  label: 'Continuer',
                  onPressed: _canSubmit ? _continuer : null,
                  isLoading: _loading,
                  enabled: _canSubmit,
                ),
                AppDimens.vGap32,
              ],
            ),
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
