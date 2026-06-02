import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api_client/api_exception.dart';
import '../../models/utilisateur.dart';
import '../../services/auth_service.dart';
import '../../services/providers.dart';

part 'auth_state.freezed.dart';

/// État global de l'authentification.
///
/// Trois statuts utiles côté UI :
/// - [AuthStatus.unknown] : on n'a pas encore vérifié, splash affiche un loader
/// - [AuthStatus.authenticated] : user présent, on peut aller au home du rôle
/// - [AuthStatus.unauthenticated] : on n'a pas de session, login requis
enum AuthStatus { unknown, authenticated, unauthenticated }

@freezed
class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState({
    @Default(AuthStatus.unknown) AuthStatus status,
    Utilisateur? user,
    String? errorMessage,
  }) = _AuthState;

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isUnknown => status == AuthStatus.unknown;
}

/// Notifier principal — chargé au démarrage par `bootstrap()`.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _auth;

  AuthNotifier(this._auth) : super(const AuthState());

  /// Tente de récupérer le user via le token stocké.
  /// Appelé par la SplashPage au démarrage.
  Future<void> bootstrap() async {
    final hasSession = await _auth.hasValidSession();
    if (!hasSession) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final user = await _auth.me();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } on ApiException {
      // Token invalide / révoqué — on retombe sur unauthenticated proprement.
      await _auth.clearLocalSession();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Stocke le résultat d'une connexion réussie (PIN ou OTP).
  void setAuthenticated(Utilisateur user) {
    state = AuthState(status: AuthStatus.authenticated, user: user);
  }

  Future<void> logout() async {
    try {
      await _auth.logout();
    } finally {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Rafraîchit le profil après update.
  Future<void> refreshMe() async {
    try {
      final user = await _auth.me();
      state = state.copyWith(user: user);
    } on ApiException {
      // Silencieux — le state reste cohérent.
    }
  }

  /// Met à jour directement le user en mémoire à partir d'un payload
  /// déjà reçu (ex. après upload avatar, après update profile). Évite
  /// un aller-retour `me()` réseau quand on a déjà la valeur fraîche.
  void updateUser(Utilisateur user) {
    state = state.copyWith(user: user);
  }
}

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

/// Sélecteurs pratiques.
final currentUserProvider = Provider<Utilisateur?>((ref) {
  return ref.watch(authStateProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});
