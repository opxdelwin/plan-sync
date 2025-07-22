import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:plan_sync/app_initializer.dart';
import 'package:plan_sync/controllers/analytics_controller.dart';
import 'package:plan_sync/controllers/app_tour_controller.dart';
import 'package:plan_sync/controllers/app_preferences_controller.dart';
import 'package:plan_sync/controllers/auth.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/controllers/notification_controller.dart';
import 'package:plan_sync/controllers/remote_config_controller.dart';
import 'package:plan_sync/controllers/theme_controller.dart';
import 'package:plan_sync/controllers/version_controller.dart';
import 'package:plan_sync/router_refresh_stream.dart';
import 'package:plan_sync/views/campus_navigator/campus_navigator_view.dart';
import 'package:plan_sync/views/electives_screen.dart';
import 'package:plan_sync/views/forced_update_screen.dart';
import 'package:plan_sync/views/home_screen.dart';
import 'package:plan_sync/views/login_screen.dart';
import 'package:plan_sync/views/settings_screen.dart';
import 'package:plan_sync/widgets/scaffold_with_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await dotenv.load(fileName: 'env/.prod.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  if (kReleaseMode) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    FirebaseCrashlytics.instance
        .setCustomKey("env", kReleaseMode ? "release" : "debug");
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  runApp(const AppProvider());
}

class AppProvider extends StatelessWidget {
  const AppProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GitService()),
        ChangeNotifierProvider(create: (_) => FilterController()),
        ChangeNotifierProvider(create: (_) => AnalyticsController()),
        ChangeNotifierProvider(create: (_) => AppPreferencesController()),
        ChangeNotifierProvider(create: (_) => AppTourController()),
        ChangeNotifierProvider(create: (_) => Auth()),
        ChangeNotifierProvider(create: (_) => RemoteConfigController()),
        ChangeNotifierProvider(create: (_) => VersionController()),
        ChangeNotifierProvider(create: (_) => AppThemeController()),
        ChangeNotifierProvider(create: (_) => NotificationController()),
      ],
      child: const MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initialize();
  }

  Future<void> _initialize() async {
    try {
      await AppInitializer.initializeApp(context);
    } finally {
      // Remove splash screen once initialization is done, even if there's an error
      FlutterNativeSplash.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Selector<AppThemeController, ThemeMode>(
            selector: (context, controller) => controller.themeMode,
            builder: (context, mode, child) => MaterialApp(
              theme: AppThemeController.lightTheme,
              darkTheme: AppThemeController.darkTheme,
              themeMode: mode,
              home: const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Selector<AppThemeController, ThemeMode>(
            selector: (context, controller) => controller.themeMode,
            builder: (context, mode, child) => MaterialApp(
              theme: AppThemeController.lightTheme,
              darkTheme: AppThemeController.darkTheme,
              themeMode: mode,
              home: Scaffold(
                body: Center(
                  child: Text('Error initializing app: ${snapshot.error}'),
                ),
              ),
            ),
          );
        }

        return ToastificationWrapper(
          child: Selector<AppThemeController, ThemeMode>(
            builder: (context, mode, child) => MaterialApp.router(
              debugShowCheckedModeBanner: kDebugMode ? true : false,
              theme: AppThemeController.lightTheme,
              darkTheme: AppThemeController.darkTheme,
              themeMode: mode,
              routerDelegate: _router.routerDelegate,
              routeInformationParser: _router.routeInformationParser,
              routeInformationProvider: _router.routeInformationProvider,
            ),
            selector: (context, controller) => controller.themeMode,
          ),
        );
      },
    );
  }
}

// GoRouter configuration
final _router = GoRouter(
  refreshListenable: GoRouterRefreshStream(),
  redirect: (context, state) => redirectHandler(context, state),
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => ScaffoldWithNavBar(
        navigationShell: navigationShell,
      ),
      branches: [
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              name: 'home_screen',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/electives',
              name: 'electives_screen',
              builder: (context, state) => const ElectiveScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/navigator',
              name: 'navigator',
              builder: (context, state) => const CampusNavigatorView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/settings',
              name: 'settings_screen',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      name: 'login_screen',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/forced_update',
      name: 'forced_update',
      builder: (context, state) => const ForcedUpdateScreen(),
    ),
  ],
);

String? redirectHandler(BuildContext context, GoRouterState state) {
  // Handle notification route from terminated state
  final notifRoute = NotificationController.initialNotificationRoute;
  if (notifRoute != null && notifRoute != state.matchedLocation) {
    NotificationController.initialNotificationRoute = null; // Clear after use
    return notifRoute;
  }

  Auth auth = Provider.of<Auth>(context, listen: false);
  if (auth.activeUser != null && state.matchedLocation == '/login') {
    return '/';
  }
  if (auth.activeUser == null) {
    return "/login";
  }

  AppPreferencesController perfs =
      Provider.of<AppPreferencesController>(context, listen: false);
  if (perfs.isAppBelowMinVersion() &&
      state.matchedLocation != '/forced_update') {
    return '/forced_update';
  }
  return null;
}
