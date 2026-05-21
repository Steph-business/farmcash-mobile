# Activation FCM (notifications push) — Mobile

Le backend est déjà câblé pour envoyer des pushs FCM (cf. `firebase-admin` dans
`farmcash-backend`, méthode `notifications.service.ts → sendFcm()` qui lit
`device_tokens` actifs et désactive ceux marqués `UNREGISTERED` par Firebase).

Côté mobile, le flow `flutter_local_notifications` (notifications locales en
foreground) est en place. Il reste à activer Firebase Messaging pour recevoir
les pushs en background. **Pas d'urgence** : sans FCM, l'app fonctionne en
foreground via SSE + notifs DB. Le push sert juste à réveiller l'app fermée.

## Étapes d'activation

### 1. Créer le projet Firebase
- Console Firebase : <https://console.firebase.google.com>
- Créer le projet `farmcash-ci-prod` (et un `farmcash-ci-dev` séparé)
- Ajouter une app Android (package : `com.farmcash.mobile`) → télécharger
  `google-services.json` dans `android/app/`
- Ajouter une app iOS (bundle id : `com.farmcash.mobile`) → télécharger
  `GoogleService-Info.plist` dans `ios/Runner/`

### 2. Activer Cloud Messaging
- Projet > Settings > Cloud Messaging > Activer l'API
- Générer une clé de service (Settings > Service Accounts > "Generate new
  private key") → `serviceAccount.json`
- Côté backend : exporter `FIREBASE_SERVICE_ACCOUNT_PATH=/path/serviceAccount.json`

### 3. Décommenter les deps mobile
Dans `pubspec.yaml`, remplacer :
```yaml
# firebase_core: ^3.6.0
# firebase_messaging: ^15.1.3
```
par les versions sans `#`. Puis :
```bash
flutter pub get
cd ios && pod install && cd ..
```

### 4. Initialiser Firebase dans `main.dart`
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // V1 : la notif est déjà déclenchée par Firebase en background — pas
  // besoin de logique custom ici. Pour des actions deeplink, parser
  // `message.data` et router.
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);
  await dotenv.load(fileName: '.env');
  runApp(/* ... */);
}
```

### 5. Demander la permission + enregistrer le token
Dans `lib/features/state/auth_state.dart`, après `setAuthenticated(user)` :
```dart
final messaging = FirebaseMessaging.instance;
final settings = await messaging.requestPermission(alert: true, badge: true, sound: true);
if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  final token = await messaging.getToken();
  if (token != null) {
    await _auth.registerDeviceToken(
      token: token,
      platform: defaultTargetPlatform == TargetPlatform.iOS ? 'IOS' : 'ANDROID',
    );
  }
  // Refresh automatique
  messaging.onTokenRefresh.listen((newToken) {
    _auth.registerDeviceToken(token: newToken, platform: ...);
  });
}
```

La méthode `AuthService.registerDeviceToken(token, platform)` existe déjà
et appelle `POST /auth/device-token` qui persiste dans la table
`device_tokens`. Le backend consomme ces tokens via `sendFcm()`.

### 6. Afficher en foreground via flutter_local_notifications
```dart
FirebaseMessaging.onMessage.listen((msg) {
  final n = msg.notification;
  if (n != null) {
    FlutterLocalNotificationsPlugin().show(
      n.hashCode,
      n.title,
      n.body,
      const NotificationDetails(/* ... */),
    );
  }
});
```

### 7. Deep-link au tap
```dart
FirebaseMessaging.onMessageOpenedApp.listen((msg) {
  final route = msg.data['route']; // ex: '/acheteur/commandes/abc-123'
  if (route != null) GoRouter.of(rootCtx).go(route);
});
```

Le backend envoie déjà `data: { type, context_id, ... }` dans
`sendEachForMulticast` — adapter selon le type.

## Tests
- Sans `google-services.json` : le build Android casse à l'init Firebase.
  Donc toujours installer le fichier AVANT de décommenter les deps.
- Test push manuel : Console Firebase > Cloud Messaging > "Send your first
  message" avec le token enregistré dans `device_tokens`.

## En attendant l'activation
- Notifs en foreground via SSE (`/notifications/stream`)
- Notifs en background : aucune (l'app dort, l'utilisateur ne voit rien
  jusqu'à réouverture). C'est acceptable pour V1 ; à activer dès que les
  comptes Firebase sont prêts.
