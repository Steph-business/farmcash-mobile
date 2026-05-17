import 'package:go_router/go_router.dart';

import '../features/state/auth_state.dart';
import '../models/enums.dart';
import 'route_names.dart';

/// Redirige selon l'état d'auth.
///
/// Règles :
/// - statut UNKNOWN → reste sur splash (on n'a pas fini de charger)
/// - UNAUTHENTICATED + tente accès à zone protégée → /connexion
/// - AUTHENTICATED + tente accès à splash/connexion/inscription → home du rôle
String? authRedirect(GoRouterState state, AuthState auth) {
  final loc = state.matchedLocation;
  final isAuthRoute = _isAuthRoute(loc);

  // Phase de chargement initiale — bloquer sur splash uniquement.
  if (auth.isUnknown) {
    return loc == RouteNames.splashPath ? null : RouteNames.splashPath;
  }

  if (!auth.isAuthenticated) {
    // Pas authentifié : seules les routes auth sont accessibles.
    if (isAuthRoute) return null;
    return RouteNames.connexionPath;
  }

  // Authentifié : toutes les routes auth (splash inclus) ramènent au home
  // du rôle. C'est ce qui sort l'app du splash après une connexion réussie
  // ou après le bootstrap initial avec une session déjà valide.
  if (isAuthRoute) {
    return _homeForRole(auth.user!.role);
  }

  return null;
}

bool _isAuthRoute(String path) {
  return path == RouteNames.splashPath ||
      path == RouteNames.bienvenuePath ||
      path == RouteNames.connexionPath ||
      path == RouteNames.choixRolePath ||
      path == RouteNames.inscriptionPath ||
      path == RouteNames.otpPath ||
      path == RouteNames.definirPinPath ||
      path == RouteNames.pinOubliePath;
}

String _homeForRole(UserRole role) {
  switch (role) {
    case UserRole.farmer:
      return RouteNames.accueilProducteurPath;
    case UserRole.buyer:
      return RouteNames.accueilAcheteurPath;
    case UserRole.cooperative:
      return RouteNames.accueilCooperativePath;
    case UserRole.transporter:
      return RouteNames.accueilTransporteurPath;
    case UserRole.admin:
    case UserRole.exporter:
    case UserRole.unknown:
      // Pas de home mobile pour ces rôles — on les renvoie sur connexion.
      return RouteNames.connexionPath;
  }
}
