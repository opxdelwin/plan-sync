import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:plan_sync/widgets/bottom-sheets/bottom_sheets_wrapper.dart';
import 'package:plan_sync/widgets/bottom-sheets/contribute_schedule.dart';
import 'package:plan_sync/widgets/bottom-sheets/elective_preference.dart';
import 'package:plan_sync/widgets/bottom-sheets/report_error.dart';
import 'package:plan_sync/widgets/bottom-sheets/schedule_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    injectMockDependencies();
  });
  testWidgets(
    'BottomSheetsWrapper.changeSectionPreference returns correct widget',
    (WidgetTester tester) async {
      late BuildContext savedContext;

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                savedContext = context;
                return Container();
              },
            ),
          ),
        ),
      );

      BottomSheets.changeSectionPreference(context: savedContext);

      await tester.pumpAndSettle();
      expect(find.byType(SchedulePreferenceBottomSheet), findsOneWidget);
      expect(find.byType(ReportErrorBottomSheet), findsNothing);
      expect(find.byType(ContributeScheduleBottomSheet), findsNothing);
      expect(find.byType(ElectivePreferenceBottomSheet), findsNothing);
    },
  );

  testWidgets(
    'BottomSheetsWrapper.reportError returns correct widget',
    skip: true,
    tags: 'not used anymore',
    (WidgetTester tester) async {
      late BuildContext savedContext;

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                savedContext = context;
                return Container();
              },
            ),
          ),
        ),
      );

      BottomSheets.reportError(context: savedContext);

      await tester.pumpAndSettle();
      expect(find.byType(SchedulePreferenceBottomSheet), findsNothing);
      expect(find.byType(ReportErrorBottomSheet), findsOneWidget);
      expect(find.byType(ContributeScheduleBottomSheet), findsNothing);
      expect(find.byType(ElectivePreferenceBottomSheet), findsNothing);
    },
  );

  testWidgets(
    'BottomSheetsWrapper.contributeTimeTable returns correct widget',
    (WidgetTester tester) async {
      late BuildContext savedContext;

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                savedContext = context;
                return Container();
              },
            ),
          ),
        ),
      );

      BottomSheets.contributeTimeTable(context: savedContext);

      await tester.pumpAndSettle();
      expect(find.byType(SchedulePreferenceBottomSheet), findsNothing);
      expect(find.byType(ReportErrorBottomSheet), findsNothing);
      expect(find.byType(ContributeScheduleBottomSheet), findsOneWidget);
      expect(find.byType(ElectivePreferenceBottomSheet), findsNothing);
    },
  );

  testWidgets(
    'BottomSheetsWrapper.changeElectiveSchemePreference returns correct widget',
    (WidgetTester tester) async {
      late BuildContext savedContext;

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                savedContext = context;
                return Container();
              },
            ),
          ),
        ),
      );

      BottomSheets.changeElectiveSchemePreference(context: savedContext);

      await tester.pumpAndSettle();
      expect(find.byType(SchedulePreferenceBottomSheet), findsNothing);
      expect(find.byType(ReportErrorBottomSheet), findsNothing);
      expect(find.byType(ContributeScheduleBottomSheet), findsNothing);
      expect(find.byType(ElectivePreferenceBottomSheet), findsOneWidget);
    },
  );
}
