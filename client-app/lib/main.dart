import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:plan_sync/controllers/analytics_controller.dart';
import 'package:plan_sync/controllers/auth.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/controllers/theme_controller.dart';
import 'package:plan_sync/controllers/version_controller.dart';
import 'package:plan_sync/router_refresh_stream.dart';
import 'package:plan_sync/views/electives_screen.dart';
import 'package:plan_sync/views/home_screen.dart';
import 'package:plan_sync/views/login_screen.dart';
import 'package:plan_sync/views/settings_screen.dart';
import 'package:plan_sync/widgets/scaffold_with_nav_bar.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _injectDependencies();

  if (kReleaseMode) {
    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    FirebaseCrashlytics.instance
        .setCustomKey("env", kReleaseMode ? "release" : "debug");
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // callfn();
    return GetMaterialApp.router(
      theme: AppThemeController.lightTheme,
      darkTheme: AppThemeController.darkTheme,
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
    );
  }
}

_injectDependencies() async {
  Get.put(Auth());
  Get.put(FilterController());
  Get.put(GitService());
  Get.put(VersionController());
  Get.put(AnalyticsController());
}

// GoRouter configuration
final _router = GoRouter(
  navigatorKey: Get.key,
  refreshListenable: GoRouterRefreshStream(),
  redirect: (context, state) => redirectHandler(context, state),
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ScaffoldWithNavBar(navigationShell: navigationShell),
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
  ],
);

redirectHandler(context, state) {
  Auth auth = Get.find();
  if (auth.activeUser != null && state.matchedLocation == '/login') {
    return '/';
  }
  if (auth.activeUser == null) {
    return "/login";
  }

  return null;
}
