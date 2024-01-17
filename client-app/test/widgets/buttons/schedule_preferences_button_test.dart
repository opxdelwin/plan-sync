import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/widgets/buttons/schedule_preferences_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../../mock_controllers/filter_controller_mock.dart';

void main() {
  Future<void> pumpBaseWidget(
    WidgetTester tester,
  ) async {
    return tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: SchedulePreferenceButton(),
        ),
      ),
    ));
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    injectMockDependencies();
  });

  testWidgets(
    'SchedulePreferenceButton when section and semester are null',
    (WidgetTester tester) async {
      // initial state
      await pumpBaseWidget(tester);
      await tester.pump();
      expect(find.text('Select Sections'), findsOneWidget);
      return;
    },
  );

  testWidgets(
    'SchedulePreferenceButton when section is null',
    (WidgetTester tester) async {
      final controller = Get.find<FilterController>() as MockFilterController;
      controller.activeSemester = "SEM1";

      // initial state
      await pumpBaseWidget(tester);
      await tester.pump();
      expect(find.text('Select Sections'), findsNothing);
      expect(find.text('SEM1'), findsOneWidget);
      return;
    },
  );

  testWidgets(
    'SchedulePreferenceButton when semester is null',
    (WidgetTester tester) async {
      final controller = Get.find<FilterController>() as MockFilterController;
      controller.activeSectionCode = "B16";
      controller.activeSemester = null;

      // initial state
      await pumpBaseWidget(tester);
      await tester.pump();
      expect(find.text('Select Sections'), findsNothing);
      expect(find.text('B16'), findsOneWidget);
      return;
    },
  );

  testWidgets(
    'SchedulePreferenceButton when both sem and section is set',
    (WidgetTester tester) async {
      final controller = Get.find<FilterController>() as MockFilterController;
      controller.activeSectionCode = "B16";
      controller.activeSemester = "SEM1";

      // initial state
      await pumpBaseWidget(tester);
      await tester.pump();
      expect(find.text('Select Sections'), findsNothing);
      expect(find.textContaining('B16'), findsOneWidget);
      expect(find.textContaining('SEM1'), findsOneWidget);
      return;
    },
  );
}
