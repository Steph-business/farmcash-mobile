// =====================================================================
//  Page : Compléter le profil rôle (récupération orphelin)
//  ---------------------------------------------------------------------
//  Quand un utilisateur s'inscrit avec succès mais que le push best-
//  effort du profil étendu post-PIN échoue (réseau, erreur backend), le
//  user reste authentifié SANS son profil rôle attendu. Le guard auth
//  l'envoie ici plutôt que de le laisser crasher sur l'accueil qui
//  référence des champs qui n'existent pas.
//
//  Le bouton « Créer mon profil » appelle l'endpoint de création (avec
//  des valeurs par défaut minimales — l'utilisateur affinera ensuite
//  depuis son profil). Si succès → me() rafraîchi → redirect home.
// =====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api_client/api_exception.dart' as api;
import '../../../features/state/auth_state.dart';
import '../../../models/enums.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/snackbars.dart';

class CompleterProfilPage extends ConsumerStatefulWidget {
  const CompleterProfilPage({super.key});

  @override
  ConsumerState<CompleterProfilPage> createState() =>
      _CompleterProfilPageState();
}

class _CompleterProfilPageState extends ConsumerState<CompleterProfilPage> {
  bool _busy = false;
  String? _error;

  Future<void> _creerProfil() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final auth = ref.read(authServiceProvider);
      final user = ref.read(authStateProvider).user;
      if (user == null) {
        throw const api.ApiException(
          message: 'Session invalide. Reconnecte-toi.',
          type: api.ApiExceptionType.unauthorized,
        );
      }
      // Crée le profil rôle avec des valeurs minimales — l'utilisateur
      // pourra affiner depuis l'écran « Mon profil ».
      await auth.updateRoleProfile(
        role: user.role,
        profile: const {},
        force: true,
      );
      // Rafraîchit l'utilisateur pour récupérer has_role_profile = true.
      final fresh = await auth.me();
      if (!mounted) return;
      ref.read(authStateProvider.notifier).setAuthenticated(fresh);
      // Le redirect global pousse automatiquement vers le home du rôle.
    } on api.ApiException catch (e) {
      if (mounted) {
        setState(() => _error = e.message);
      }
    } catch (e) {
      if (mounted) Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _logout() async {
    // `logout()` du notifier fait l'API best-effort + clear local state.
    await ref.read(authStateProvider.notifier).logout();
    if (!mounted) return;
    context.go(RouteNames.connexionPath);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final roleLabel = _roleLabel(user?.role ?? UserRole.unknown);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Un dernier pas',
                textAlign: TextAlign.center,
                style: AppTextStyles.displaySmall.copyWith(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ton compte est créé mais ton profil $roleLabel n\'a pas '
                'pu être finalisé à l\'inscription. On le crée maintenant '
                'pour que tu puisses accéder à FarmCash.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 16,
                        color: Color(0xFF991B1B),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF991B1B),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              SizedBox(
                height: AppDimens.buttonHeight,
                child: ElevatedButton(
                  onPressed: _busy ? null : _creerProfil,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppDimens.brButton,
                    ),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Créer mon profil',
                          style: AppTextStyles.button.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _busy ? null : _logout,
                child: Text(
                  'Se déconnecter',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.farmer:
        return 'producteur';
      case UserRole.buyer:
        return 'acheteur';
      case UserRole.cooperative:
        return 'coopérative';
      case UserRole.transporter:
        return 'transporteur';
      default:
        return 'utilisateur';
    }
  }
}
