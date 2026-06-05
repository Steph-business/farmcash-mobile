import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api_client/api_exception.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../widgets/authentification/auth_premium_bg.dart';
import '../../widgets/authentification/champ_telephone.dart';
import '../../widgets/authentification/cta_auth_premium.dart';
import '../../widgets/authentification/logo_farmcash.dart';
import '../../widgets/authentification/pave_pin.dart';
import '../../widgets/authentification/selecteur_langue.dart';
import '../../widgets/communs/vue_erreur.dart';

/// Connexion par téléphone + code PIN — design premium (mesh gradient,
/// logo brand, champs sur cartes flottantes, CTA avec flèche + shadow).
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
      body: Stack(
        children: [
          const AuthPremiumBg(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: SelecteurLangue(),
                  ),
                  const SizedBox(height: 20),
                  const LogoFarmcash(),
                  const SizedBox(height: 28),

                  // Hero titre + sous-titre (même rythme typo que welcome)
                  Text(
                    'Content de te revoir !',
                    style: AppTextStyles.displayLarge.copyWith(
                      fontSize: 28,
                      height: 1.2,
                      letterSpacing: -0.6,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Connecte-toi avec ton numéro et ton code PIN.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Carte champ téléphone ─────────────────────────
                  _CarteChamp(
                    libelle: 'Numéro de téléphone',
                    enfant: ChampTelephone(
                      controller: _phoneCtrl,
                      autofocus: true,
                      onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Carte code PIN ────────────────────────────────
                  _CarteChamp(
                    libelle: 'Code PIN',
                    libelleAction: 'PIN oublié ?',
                    onAction: () =>
                        context.go(RouteNames.pinOubliePath),
                    enfant: PavePin(
                      controller: _pinCtrl,
                      onSubmitted: (_) {
                        if (_canSubmit) _seConnecter();
                      },
                    ),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    VueErreur(message: _error!),
                  ],

                  const SizedBox(height: 28),
                  CtaAuthPremium(
                    label: 'Se connecter',
                    onTap: _canSubmit ? _seConnecter : null,
                    loading: _loading,
                    enabled: _canSubmit,
                  ),
                  const SizedBox(height: 18),

                  // Lien création de compte (RichText premium).
                  Center(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => context.go(RouteNames.choixRolePath),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              const TextSpan(text: 'Pas encore de compte ?  '),
                              TextSpan(
                                text: 'Créer un compte',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _MentionsLegales(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Carte regroupant un label + un champ (look premium) ─────────────

class _CarteChamp extends StatelessWidget {
  const _CarteChamp({
    required this.libelle,
    required this.enfant,
    this.libelleAction,
    this.onAction,
  });

  final String libelle;
  final Widget enfant;
  final String? libelleAction;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  libelle,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              if (libelleAction != null && onAction != null)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onAction,
                  child: Text(
                    libelleAction!,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          enfant,
        ],
      ),
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
