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

  // Garde profil rôle : si le backend signale qu'il manque le profil
  // étendu (cas rare où le push best-effort post-PIN a échoué), on force
  // la page de récupération. Évite un crash dans les écrans qui supposent
  // un profil joint. Exception : on autorise la page de complétion
  // elle-même (sinon boucle infinie).
  final role = auth.user!.role;
  final roleRequiresProfile = _roleRequiresProfile(role);
  final needsCompletion = roleRequiresProfile && !auth.user!.hasRoleProfile;
  if (needsCompletion && loc != RouteNames.completerProfilPath) {
    return RouteNames.completerProfilPath;
  }
  // Sinon : si l'utilisateur arrive sur completer-profil mais qu'il a
  // déjà son profil → on le renvoie au home.
  if (!needsCompletion && loc == RouteNames.completerProfilPath) {
    return _homeForRole(role);
  }

  // Garde onboarding obligatoire : le profil rôle existe (has_role_profile
  // = true) mais les champs essentiels (région, cultures, zones d'achat,
  // numéro d'agrément…) ne sont pas renseignés. On bloque l'accès à l'app
  // tant que le wizard n'est pas terminé. Le backend renvoie le flag
  // `essential_fields_complete` sur `/auth/me`. TRANSPORTER est exclu
  // (onboarding séparé : route active obligatoire).
  if (roleRequiresProfile &&
      !needsCompletion &&
      !auth.user!.essentialFieldsComplete) {
    final onboardingPath = _onboardingPathForRole(role);
    if (onboardingPath != null && loc != onboardingPath) {
      return onboardingPath;
    }
  }

  // Inverse : si l'utilisateur arrive sur une page onboarding mais que
  // son profil est complet → on le renvoie au home pour ne pas le bloquer
  // sur un écran sans utilité.
  if (auth.user!.essentialFieldsComplete && _isOnboardingRoute(loc)) {
    return _homeForRole(role);
  }

  // Authentifié : toutes les routes auth (splash inclus) ramènent au home
  // du rôle. C'est ce qui sort l'app du splash après une connexion réussie
  // ou après le bootstrap initial avec une session déjà valide.
  if (isAuthRoute) {
    return _homeForRole(role);
  }

  return null;
}

/// Rôles pour lesquels le profil étendu est obligatoire pour entrer
/// dans l'app. TRANSPORTER est exclu : il a son propre onboarding
/// (route active obligatoire) géré ailleurs.
bool _roleRequiresProfile(UserRole role) {
  return role == UserRole.farmer ||
      role == UserRole.buyer ||
      role == UserRole.cooperative;
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

/// Les pages onboarding sont accessibles UNIQUEMENT après authentification
/// (le user a déjà un compte + un profil rôle vide). On NE les ajoute pas
/// à `_isAuthRoute` pour éviter une boucle (un user non authentifié serait
/// alors autorisé à les voir, mais le guard d'auth les renverrait
/// immédiatement vers /connexion en upstream).
bool _isOnboardingRoute(String path) {
  return path == RouteNames.onboardingProducteurPath ||
      path == RouteNames.onboardingAcheteurPath ||
      path == RouteNames.onboardingCooperativePath;
}

String? _onboardingPathForRole(UserRole role) {
  switch (role) {
    case UserRole.farmer:
      return RouteNames.onboardingProducteurPath;
    case UserRole.buyer:
      return RouteNames.onboardingAcheteurPath;
    case UserRole.cooperative:
      return RouteNames.onboardingCooperativePath;
    default:
      return null;
  }
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
