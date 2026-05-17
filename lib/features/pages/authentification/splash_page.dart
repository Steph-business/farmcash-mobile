import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/chargement.dart';

/// Écran de démarrage minimal — affiche la marque pendant que l'on
/// vérifie la session locale.
///
/// La redirection (login OR home du rôle) est gérée par GoRouter via
/// `authRedirect` dans route_guards.dart. Ici on déclenche juste le
/// bootstrap puis on laisse le router faire son travail.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authStateProvider.notifier).bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si on est unauthenticated et qu'on n'a jamais vu l'onboarding,
    // diriger vers bienvenue. Sinon le redirect global gère le reste.
    ref.listen<AuthState>(authStateProvider, (prev, next) {
      if (next.status == AuthStatus.unauthenticated &&
          prev?.status != AuthStatus.unauthenticated) {
        context.go(RouteNames.bienvenuePath);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const _LogoFarmCash(),
            const SizedBox(height: AppDimens.space48),
            const Chargement(size: 22),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

/// Logo simple : icône feuille + texte "FarmCash" sur une ligne.
///
/// Conforme DESIGN.md : pas de gradient, pas de halo, pas de badge.
class _LogoFarmCash extends StatelessWidget {
  const _LogoFarmCash();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.eco_outlined, size: 32, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          'FarmCash',
          style: AppTextStyles.headlineLarge.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            fontSize: 22,
          ),
        ),
      ],
    );
  }
}
