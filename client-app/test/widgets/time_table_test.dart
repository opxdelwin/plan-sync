import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/widgets/time_table.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../mock_controllers/git_service_mock.dart';

void main() {
  Future<void> pumpBaseWidget(WidgetTester tester) async {
    return tester.pumpWidget(const GetMaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: TimeTableWidget(),
        ),
      ),
    ));
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    injectMockDependencies();
  });

  testWidgets('TimeTableWidget renders schedule if available',
      (WidgetTester tester) async {
    final controller = Get.find<GitService>() as MockGitService;
    controller.stage = MockGitServiceStages.success;

    await pumpBaseWidget(tester);
    await tester.pumpAndSettle();

    // if all days are available
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('Tuesday'), findsOneWidget);
    expect(find.text('Wednesday'), findsOneWidget);
    expect(find.text('Thursday'), findsOneWidget);
    expect(find.text('Friday'), findsOneWidget);
  });

  testWidgets('TimeTableWidget renders info page if schedule is updating',
      (WidgetTester tester) async {
    final controller = Get.find<GitService>() as MockGitService;
    controller.stage = MockGitServiceStages.scheduleUpdating;

    await pumpBaseWidget(tester);
    await tester.pumpAndSettle();

    expect(find.text('Monday'), findsNothing);
    expect(find.text('Tuesday'), findsNothing);
    expect(find.text('Wednesday'), findsNothing);
    expect(find.text('Thursday'), findsNothing);
    expect(find.text('Friday'), findsNothing);

    //returns info page when updating
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.text("We're working on this timetable,"), findsOneWidget);
    expect(find.text('Check back in soon!'), findsOneWidget);
  });

  testWidgets('TimeTableWidget renders error if no internet',
      (WidgetTester tester) async {
    final controller = Get.find<GitService>() as MockGitService;
    controller.stage = MockGitServiceStages.noInternet;

    await pumpBaseWidget(tester);
    await tester.pumpAndSettle();

    // //returns error page when no connectivity
    expect(find.byIcon(Icons.error), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is MarkdownBody && widget.data.contains('No Internet'),
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'A status report has been sent, this issue will be looked into.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('TimeTableWidget renders info page if no section is selected',
      (WidgetTester tester) async {
    final controller = Get.find<GitService>() as MockGitService;
    controller.stage = MockGitServiceStages.noneSelected;

    await pumpBaseWidget(tester);
    await tester.pumpAndSettle();

    expect(find.text('Monday'), findsNothing);
    expect(find.text('Tuesday'), findsNothing);
    expect(find.text('Wednesday'), findsNothing);
    expect(find.text('Thursday'), findsNothing);
    expect(find.text('Friday'), findsNothing);

    //returns info page when no data is returned
    expect(find.byIcon(Icons.info), findsOneWidget);
    expect(find.text("No section selected."), findsOneWidget);
  });
}
