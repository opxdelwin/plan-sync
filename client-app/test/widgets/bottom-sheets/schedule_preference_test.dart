import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:plan_sync/controllers/app_preferences_controller.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/controllers/theme_controller.dart';
import 'package:plan_sync/widgets/bottom-sheets/schedule_preference.dart';
import 'package:plan_sync/widgets/dropdowns/sections_bar.dart';
import 'package:plan_sync/widgets/dropdowns/semester_bar.dart';
import 'package:plan_sync/widgets/dropdowns/year_bar.dart';
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
                  child: SchedulePreferenceBottomSheet(),
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
  testWidgets('SchedulePreferenceBottomSheet switch toggles',
      (WidgetTester tester) async {
    await pumpBaseWidget(tester);
    final SchedulePreferenceBottomSheetState widgetState = tester.state(
      find.byType(SchedulePreferenceBottomSheet),
    );

    await tester.pump();
    expect(widgetState.savePreferencesOnExit, false);

    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(widgetState.savePreferencesOnExit, true);
  });

  testWidgets('SchedulePreferenceBottomSheet opens yearbar',
      (WidgetTester tester) async {
    final gitController = Get.find<GitService>() as MockGitService;

    await pumpBaseWidget(tester);

    await tester.pump();
    await tester.tap(find.byType(YearBar));
    await tester.pumpAndSettle();

    expect(find.text('2024'), findsOneWidget);
    expect(find.text('2023'), findsOneWidget);
    expect(find.text('2022'), findsOneWidget);

    await tester.tap(find.text('2024'));
    await tester.pumpAndSettle();

    expect(gitController.selectedYear, 2024);
  });

  testWidgets('SchedulePreferenceBottomSheet opens SemestersBar',
      (WidgetTester tester) async {
    final filterController =
        Get.find<FilterController>() as MockFilterController;

    await pumpBaseWidget(tester);

    await tester.pump();
    await tester.tap(find.byType(SemesterBar));
    await tester.pumpAndSettle();

    expect(find.text('SEM1'), findsOneWidget);
    expect(find.text('SEM2'), findsOneWidget);
    await tester.tap(find.text('SEM1'));
    await tester.pumpAndSettle();

    expect(filterController.activeSemester, 'SEM1');
  });

  testWidgets('SchedulePreferenceBottomSheet opens SectionBar',
      (WidgetTester tester) async {
    final gitController = Get.find<GitService>() as MockGitService;
    final filterController =
        Get.find<FilterController>() as MockFilterController;

    gitController.sections = {
      "b13": "B13 CSE",
      "b16": "B16 CSE",
      "b18": "B18 CSE",
    };

    await pumpBaseWidget(tester);
    await tester.pump();

    await tester.tap(find.byType(SectionsBar));
    await tester.pumpAndSettle();

    // ensure 3 items are visible
    expect(find.textContaining('B13'), findsOneWidget);
    expect(find.textContaining('B16'), findsOneWidget);
    expect(find.textContaining('B18'), findsOneWidget);

    await tester.tap(find.textContaining('B13'));
    await tester.pumpAndSettle();

    // ensure controller field is updated
    expect(filterController.activeSection, 'B13 CSE');
  });

  testWidgets('SchedulePreferenceBottomSheet saves config to SharedPreferences',
      (WidgetTester tester) async {
    final gitController = Get.find<GitService>() as MockGitService;
    final perfs =
        Get.find<AppPreferencesController>() as MockAppPreferencesController;
    final filterController =
        Get.find<FilterController>() as MockFilterController;

    gitController.sections = {
      "b13": "B13 CSE",
      "b16": "B16 CSE",
      "b18": "B18 CSE",
    };
    gitController.selectedYear = 2023;
    filterController.activeSection = 'B18 CSE';
    filterController.activeSectionCode = 'b18';
    filterController.activeSemester = 'SEM2';

    // pump widget with above config
    await pumpBaseWidget(tester);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    final SchedulePreferenceBottomSheetState widgetState = tester.state(
      find.byType(SchedulePreferenceBottomSheet),
    );

    // test controller mutation
    expect(widgetState.savePreferencesOnExit, true);
    expect(filterController.activeSection, 'B18 CSE');
    expect(filterController.activeSectionCode, 'b18');
    expect(filterController.activeSemester, 'SEM2');
    expect(gitController.selectedYear, 2023);

    // verify existing perfs
    expect(perfs.getPrimarySectionPreference(), isNull);
    expect(perfs.getPrimarySemesterPreference(), isNull);
    expect(perfs.getPrimaryYearPreference(), isNull);

    // save
    await tester.tap(find.text('Done'));
    Get.closeAllSnackbars();
    await tester.pumpAndSettle();

    // verify post saving perfs
    expect(perfs.getPrimarySectionPreference(), 'b18');
    expect(perfs.getPrimarySemesterPreference(), 'SEM2');
    expect(perfs.getPrimaryYearPreference(), '2023');
  });

  //
  testWidgets(
      'SchedulePreferenceBottomSheet does not save config to SharedPreferences',
      (WidgetTester tester) async {
    final gitController = Get.find<GitService>() as MockGitService;
    final perfs =
        Get.find<AppPreferencesController>() as MockAppPreferencesController;
    final filterController =
        Get.find<FilterController>() as MockFilterController;

    // reset existing SharedPreferences data from previous test
    perfs.resetPreferencesToNull();

    gitController.sections = {
      "b13": "B13 CSE",
      "b16": "B16 CSE",
      "b18": "B18 CSE",
    };
    gitController.selectedYear = 2023;
    filterController.activeSection = 'B18 CSE';
    filterController.activeSectionCode = 'b18';
    filterController.activeSemester = 'SEM2';

    // pump widget with above config
    await pumpBaseWidget(tester);
    await tester.pumpAndSettle();

    final SchedulePreferenceBottomSheetState widgetState = tester.state(
      find.byType(SchedulePreferenceBottomSheet),
    );

    // test controller mutation
    expect(widgetState.savePreferencesOnExit, false);
    expect(filterController.activeSection, 'B18 CSE');
    expect(filterController.activeSectionCode, 'b18');
    expect(filterController.activeSemester, 'SEM2');
    expect(gitController.selectedYear, 2023);

    // verify existing perfs
    expect(perfs.getPrimarySectionPreference(), isNull);
    expect(perfs.getPrimarySemesterPreference(), isNull);
    expect(perfs.getPrimaryYearPreference(), isNull);

    // save
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // verify post saving perfs
    expect(perfs.getPrimarySectionPreference(), isNull);
    expect(perfs.getPrimarySemesterPreference(), isNull);
    expect(perfs.getPrimaryYearPreference(), isNull);
  });
}
