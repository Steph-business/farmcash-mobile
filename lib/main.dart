import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/storage/prefs_storage.dart';
import 'routing/app_router.dart';
import 'services/providers.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Env (override possible via --dart-define=ENV_FILE=env/prod.env).
  const envFile =
      String.fromEnvironment('ENV_FILE', defaultValue: 'env/dev.env');
  await dotenv.load(fileName: envFile);

  // Init locale fr_FR pour les DateFormat (intl). Sans ça, tout widget
  // qui fait `DateFormat('xxx', 'fr_FR')` lève LocaleDataException.
  await initializeDateFormatting('fr_FR', null);

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        prefsStorageProvider.overrideWithValue(PrefsStorage(prefs)),
      ],
      child: const FarmCashApp(),
    ),
  );
}

class FarmCashApp extends ConsumerStatefulWidget {
  const FarmCashApp({super.key});

  @override
  ConsumerState<FarmCashApp> createState() => _FarmCashAppState();
}

class _FarmCashAppState extends ConsumerState<FarmCashApp> {
  @override
  void initState() {
    super.initState();
    // Branche la callback d'auth-failure sur le router : quand le refresh
    // échoue dans l'interceptor, on remet l'utilisateur sur /connexion.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(appRouterProvider);
      ref
          .read(apiClientProvider)
          .dio
          .options
          .extra['_onAuthFailureRouter'] = () => router.go('/connexion');
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'FarmCash',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
