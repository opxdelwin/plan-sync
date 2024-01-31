import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plan_sync/widgets/bottom-sheets/report_error.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  Future<void> pumpBaseWidget(
    WidgetTester tester,
  ) async {
    return tester.pumpWidget(const GetMaterialApp(
      home: Scaffold(
        body: Center(
          child: ReportErrorBottomSheet(),
        ),
      ),
    ));
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    injectMockDependencies();
  });

  testWidgets('ReportErrorBottomSheet mail is available',
      (WidgetTester tester) async {
    await pumpBaseWidget(tester);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.mail_outline_rounded), findsOneWidget);
    expect(find.text('Report via mail'), findsOneWidget);
  });

  testWidgets('ReportErrorBottomSheet github is available',
      (WidgetTester tester) async {
    await pumpBaseWidget(tester);
    await tester.pumpAndSettle();

    expect(find.byIcon(FontAwesomeIcons.github), findsOneWidget);
    expect(find.text('Report via GitHub'), findsOneWidget);
  });
}
