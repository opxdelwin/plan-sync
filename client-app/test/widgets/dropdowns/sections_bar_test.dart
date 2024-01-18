import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/widgets/dropdowns/sections_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../../mock_controllers/filter_controller_mock.dart';
import '../../mock_controllers/git_service_mock.dart';

void main() {
  Future<void> pumpBaseWidget(
    WidgetTester tester,
  ) async {
    return tester.pumpWidget(const GetMaterialApp(
      home: Scaffold(
        body: Center(
          child: SectionsBar(),
        ),
      ),
    ));
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    injectMockDependencies();
  });

  test('description', () => null);

  testWidgets('Semester Bar loads properly', (WidgetTester tester) async {
    final gitController = Get.find<GitService>() as MockGitService;
    final filterController =
        Get.find<FilterController>() as MockFilterController;

    gitController.sections = {
      "b13": "B13 CSE",
      "b16": "B16 CSE",
      "b18": "B18 CSE",
    };

    // initial state
    await pumpBaseWidget(tester);
    await tester.pumpAndSettle();
    expect(find.text('Select Semester First'), findsOneWidget);

    // expect all options
    // filterController.activeSection = "B13 CSE";
    filterController.activeSemester = "SEM1";
    await tester.pumpAndSettle();

    // enabled state with dropdown items
    expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    expect(find.text('Section'), findsOneWidget);

    // expect(find.text('2024'), findsOneWidget);
    // expect(find.text('2023'), findsOneWidget);
    // expect(find.text('2022'), findsOneWidget);
  });

  testWidgets(
    'Semester Bar loads and update controller dropdown items',
    (WidgetTester tester) async {
      final gitController = Get.find<GitService>() as MockGitService;
      final filterController =
          Get.find<FilterController>() as MockFilterController;

      gitController.sections = {
        "b13": "B13 CSE",
        "b16": "B16 CSE",
        "b18": "B18 CSE",
      };
      filterController.activeSemester = "SEM1";

      await pumpBaseWidget(tester);
      await tester.tap(find.byIcon(Icons.arrow_drop_down));
      await tester.pumpAndSettle();

      // ensure 3 items are visible
      expect(find.byType(DropdownMenuItem<String>), findsExactly(3));

      await tester.tap(find.textContaining('B13'));
      await tester.pumpAndSettle();

      // ensure controller field is updated
      expect(filterController.activeSection, 'B13 CSE');
    },
  );
}
