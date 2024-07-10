import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/widgets/dropdowns/elective_year_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../../mock_controllers/git_service_mock.dart';

void main() {
  Future<void> pumpBaseWidget(
    WidgetTester tester,
  ) async {
    return tester.pumpWidget(const GetMaterialApp(
      home: Scaffold(
        body: Center(
          child: ElectiveYearBar(),
        ),
      ),
    ));
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    injectMockDependencies();
  });

  testWidgets(
    'ElectiveYearBar loads when data is availble but not selected',
    (WidgetTester tester) async {
      // initial state
      await pumpBaseWidget(tester);
      await tester.pumpAndSettle();
      expect(find.text('Year'), findsOneWidget);
    },
  );

  testWidgets(
    'ElectiveYearBar updates data when clicked on item',
    (WidgetTester tester) async {
      final gitController = Get.find<GitService>() as MockGitService;

      gitController.electiveYears = ["2024", "2023"];
      gitController.selectedElectiveYear = null;

      // initial state
      await pumpBaseWidget(tester);
      await tester.pumpAndSettle();
      expect(find.text('Year'), findsOneWidget);

      // enabled state with dropdown items
      await tester.tap(find.byIcon(Icons.arrow_drop_down));
      await tester.pumpAndSettle();

      // check if supplied data is found
      expect(find.byType(DropdownMenuItem<String>), findsExactly(2));

      await tester.tap(find.text("2024"));
      await tester.pumpAndSettle();

      // check if controller value updates
      expect(gitController.selectedElectiveYear, '2024');
    },
  );
}
