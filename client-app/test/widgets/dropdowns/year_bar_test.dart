import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plan_sync/widgets/dropdowns/year_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import 'package:get/get.dart';

void main() {
  Future<void> pumpBaseWidget(
    WidgetTester tester,
  ) async {
    return tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: Center(
            child: YearBar(),
          ),
        ),
      ),
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    injectMockDependencies();
  });

  testWidgets('Year Bar loads properly', (WidgetTester tester) async {
    // initial state
    await pumpBaseWidget(tester);
    await tester.pumpAndSettle();
    expect(find.text('Year'), findsOneWidget);

    // expect all options
    await tester.tap(find.byIcon(Icons.arrow_drop_down));
    await tester.pumpAndSettle();
    expect(find.text('2024'), findsOneWidget);
    expect(find.text('2023'), findsOneWidget);
    expect(find.text('2022'), findsOneWidget);
  });

  testWidgets('Year Bar sets new value', (WidgetTester tester) async {
    // initial state
    await pumpBaseWidget(tester);
    await tester.pumpAndSettle();
    expect(find.text('Year'), findsOneWidget);

    // tap on year
    await tester.tap(find.byIcon(Icons.arrow_drop_down));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2024'));
    await tester.pumpAndSettle();

    // check if new value is updated
    expect(find.byType(DropdownButton<String>), findsOneWidget);
    expect(find.widgetWithText(DropdownButton<String>, "2024"), findsOneWidget);
  });
}
