import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/app_preferences_controller.dart';
import 'package:plan_sync/controllers/theme_controller.dart';
import 'package:plan_sync/views/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../../mock_controllers/app_preferences_controller_mock.dart';

void main() {
  Future<void> pumpTutorialWidget(WidgetTester tester) async {
    await tester.pumpFrames(
      MaterialApp(
        theme: AppThemeController.lightTheme,
        home: const HomeScreen(),
      ),
      const Duration(seconds: 3),
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'app-tutorial-status': true,
    });
    injectMockDependencies();
  });

  testWidgets(
    'Tutorial doesn\'t starts if already completed',
    (WidgetTester tester) async {
      await pumpTutorialWidget(tester);

      expect(find.text('Select your section here'), findsNothing);
      expect(find.text('SKIP'), findsNothing);
    },
  );

  testWidgets(
    'Tutorial stops when skip button is pressed',
    (WidgetTester tester) async {
      final perfs =
          Get.find<AppPreferencesController>() as MockAppPreferencesController;
      perfs.saveTutorialStatus(false);

      await pumpTutorialWidget(tester);

      expect(find.text('Select your section here'), findsOneWidget);
      expect(find.text('SKIP'), findsOneWidget);

      // press skip button
      await tester.tapAt(tester.getCenter(find.text("SKIP")));
      await pumpTutorialWidget(tester);

      expect(find.text('Select your section here'), findsNothing);
      expect(find.text('SKIP'), findsNothing);
    },
  );

  testWidgets(
    'Tutorial starts if user has not completed',
    (WidgetTester tester) async {
      final perfs =
          Get.find<AppPreferencesController>() as MockAppPreferencesController;

      await perfs.resetPreferencesToNull();

      // using pumpFrames as the tutorial has infinite
      // animation which leads to pumpAndSettle to
      // run infinitely.

      await pumpTutorialWidget(tester);

      // see if animation starts
      expect(find.text('Select your section here'), findsOneWidget);
      expect(find.text('SKIP'), findsOneWidget);

      // Continue into bottomSheet
      await tester.tapAt(tester.getCenter(find.text('Select Sections')));
      await pumpTutorialWidget(tester);
      expect(find.byType(Switch), findsOneWidget);
      expect(find.text("Save Preferences"), findsOneWidget);

      // continue to highlight SectionBar
      await tester.tapAt(tester.getCenter(find.text("Save Preferences")));
      await pumpTutorialWidget(tester);

      await tester.tapAt(tester.getCenter(find.text("Section")));
      await pumpTutorialWidget(tester);
    },
  );
}
