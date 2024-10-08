import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:plan_sync/backend/models/timetable.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/widgets/time_table_for_day.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../mock_controllers/git_service_mock.dart';

void main() {
  Future<void> pumpBaseWidget(
    WidgetTester tester,
    Timetable data,
    String day,
  ) async {
    return tester.pumpWidget(GetMaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: TimeTableForDay(
            data: data,
            day: day,
          ),
        ),
      ),
    ));
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    injectMockDependencies();
  });

  testWidgets('TimeTableForDay Horizontal schedule is rendered', (
    WidgetTester tester,
  ) async {
    final controller = Get.find<GitService>() as MockGitService;
    controller.stage = MockGitServiceStages.success;

    final data = controller.getTimeTable();
    const day = 'monday';

    await pumpBaseWidget(tester, (await data.first)!, day);
    await tester.pump(const Duration(seconds: 1));

    // drag until last element is visible
    await tester.dragUntilVisible(
      find.text('Sc LS.'),
      find.byKey(const ValueKey('TimeTableForDay._buildForTimetable')),
      const Offset(0, 500),
    );
    await tester.pump(const Duration(seconds: 1));

    // no error should be raised
    expect(tester.takeException(), null);
  });
}
