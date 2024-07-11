import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:plan_sync/controllers/app_preferences_controller.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/controllers/theme_controller.dart';
import 'package:plan_sync/widgets/bottom-sheets/elective_preference.dart';
import 'package:plan_sync/widgets/dropdowns/elective_year_bar.dart';
import 'package:plan_sync/widgets/dropdowns/electives_scheme_bar.dart';
import 'package:plan_sync/widgets/dropdowns/electives_sem_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../../mock_controllers/app_preferences_controller_mock.dart';
import '../../mock_controllers/filter_controller_mock.dart';
import '../../mock_controllers/git_service_mock.dart';

void main() {
  Future<void> pumpBaseWidget(
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      navigatorKey: Get.key,
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/',
          routes: [
            GoRoute(
              path: 'home',
              builder: (context, state) => const Scaffold(
                body: Center(
                  child: ElectivePreferenceBottomSheet(),
                ),
              ),
            )
          ],
          builder: (context, state) => const Scaffold(
              body: SizedBox.expand(
            child: ColoredBox(color: Colors.red),
          )),
        )
      ],
    );
    return tester.pumpWidget(GetMaterialApp.router(
      theme: AppThemeController.lightTheme,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      routerDelegate: router.routerDelegate,
    ));
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    injectMockDependencies();
  });
  testWidgets('ElectivePreferenceBottomSheet switch toggles when clicked',
      (WidgetTester tester) async {
    await pumpBaseWidget(tester);
    final ElectivePreferenceBottomSheetState widgetState = tester.state(
      find.byType(ElectivePreferenceBottomSheet),
    );

    await tester.pump();
    expect(widgetState.savePreferencesOnExit, false);

    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(widgetState.savePreferencesOnExit, true);
  });

  testWidgets('ElectivePreferenceBottomSheet opens yearbar',
      (WidgetTester tester) async {
    final gitController = Get.find<GitService>() as MockGitService;

    await pumpBaseWidget(tester);

    await tester.pump();
    await tester.tap(find.byType(ElectiveYearBar));
    await tester.pumpAndSettle();

    expect(find.text('2024'), findsOneWidget);
    expect(find.text('2023'), findsOneWidget);
    expect(find.text('2022'), findsOneWidget);

    await tester.tap(find.text('2024'));
    await tester.pumpAndSettle();

    expect(gitController.selectedElectiveYear, '2024');
  });

  testWidgets('ElectivePreferenceBottomSheet opens SemestersBar',
      (WidgetTester tester) async {
    final filterController =
        Get.find<FilterController>() as MockFilterController;

    await pumpBaseWidget(tester);

    await tester.pump();
    await tester.tap(find.byType(ElectiveSemesterBar));
    await tester.pumpAndSettle();

    expect(find.text('SEM1'), findsOneWidget);
    expect(find.text('SEM2'), findsOneWidget);
    await tester.tap(find.text('SEM1'));
    await tester.pumpAndSettle();

    expect(filterController.activeElectiveSemester, 'SEM1');
  });

  testWidgets('ElectivePreferenceBottomSheet opens SectionBar',
      (WidgetTester tester) async {
    final gitController = Get.find<GitService>() as MockGitService;
    final filterController =
        Get.find<FilterController>() as MockFilterController;

    gitController.electiveSchemes = {
      "a": "Scheme A",
      "b": "Scheme B",
    }.obs;

    await pumpBaseWidget(tester);
    await tester.pump();

    await tester.tap(find.byType(ElectiveSchemeBar));
    await tester.pumpAndSettle();

    // ensure 3 items are visible
    expect(find.text('Scheme A'), findsOneWidget);
    expect(find.text('Scheme B'), findsOneWidget);

    await tester.tap(find.text('Scheme B'));
    await tester.pumpAndSettle();

    // ensure controller field is updated
    expect(filterController.activeElectiveScheme, 'Scheme B');
  });

  testWidgets(
      'ElectivePreferenceBottomSheet does not save config to SharedPreferences',
      (WidgetTester tester) async {
    final gitController = Get.find<GitService>() as MockGitService;
    final perfs =
        Get.find<AppPreferencesController>() as MockAppPreferencesController;
    final filterController =
        Get.find<FilterController>() as MockFilterController;

    // reset existing SharedPreferences data from previous test
    perfs.resetPreferencesToNull();

    gitController.selectedElectiveYear = '2024';
    filterController.activeElectiveSemester = 'SEM1';
    filterController.activeElectiveScheme = 'Scheme B';
    filterController.activeElectiveSchemeCode = 'b';

    // pump widget with above config
    await pumpBaseWidget(tester);
    await tester.pumpAndSettle();

    final ElectivePreferenceBottomSheetState widgetState = tester.state(
      find.byType(ElectivePreferenceBottomSheet),
    );

    // test controller mutation
    expect(widgetState.savePreferencesOnExit, false);
    expect(filterController.activeElectiveSemester, 'SEM1');
    expect(filterController.activeElectiveScheme, 'Scheme B');
    expect(filterController.activeElectiveSchemeCode, 'b');
    expect(gitController.selectedElectiveYear, '2024');

    // verify existing perfs
    expect(perfs.getPrimaryElectiveSchemePreference(), isNull);
    expect(perfs.getPrimaryElectiveSemesterPreference(), isNull);
    expect(perfs.getPrimaryElectiveYearPreference(), isNull);

    // save
    await tester.tap(find.text('Done'));
    await pumpBaseWidget(tester);

    // verify post saving perfs
    expect(perfs.getPrimaryElectiveSchemePreference(), isNull);
    expect(perfs.getPrimaryElectiveSemesterPreference(), isNull);
    expect(perfs.getPrimaryElectiveYearPreference(), isNull);
  });

  testWidgets('ElectivePreferenceBottomSheet saves config to SharedPreferences',
      (WidgetTester tester) async {
    final gitController = Get.find<GitService>() as MockGitService;
    final perfs =
        Get.find<AppPreferencesController>() as MockAppPreferencesController;
    final filterController =
        Get.find<FilterController>() as MockFilterController;

    // reset existing SharedPreferences data from previous test
    perfs.resetPreferencesToNull();

    gitController.selectedElectiveYear = '2024';
    filterController.activeElectiveSemester = 'SEM1';
    filterController.activeElectiveScheme = 'Scheme B';
    filterController.activeElectiveSchemeCode = 'b';

    // pump widget with above config
    await pumpBaseWidget(tester);
    await tester.pumpAndSettle();

    final ElectivePreferenceBottomSheetState widgetState = tester.state(
      find.byType(ElectivePreferenceBottomSheet),
    );

    widgetState.savePreferencesOnExit = true;

    // test controller mutation
    expect(widgetState.savePreferencesOnExit, true);
    expect(filterController.activeElectiveSemester, 'SEM1');
    expect(filterController.activeElectiveScheme, 'Scheme B');
    expect(filterController.activeElectiveSchemeCode, 'b');
    expect(gitController.selectedElectiveYear, '2024');

    // verify existing perfs
    expect(perfs.getPrimaryElectiveSchemePreference(), isNull);
    expect(perfs.getPrimaryElectiveSemesterPreference(), isNull);
    expect(perfs.getPrimaryElectiveYearPreference(), isNull);

    // save
    await tester.tap(find.text('Done'));
    Get.closeAllSnackbars();
    await tester.pumpAndSettle();

    // verify post saving perfs
    expect(perfs.getPrimaryElectiveSchemePreference(), 'b');
    expect(perfs.getPrimaryElectiveSemesterPreference(), 'SEM1');
    expect(perfs.getPrimaryElectiveYearPreference(), '2024');
  });
}
