import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:plan_sync/util/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

enum _Type { info, error }

void main() {
  Future<void> pumpBaseWidget(
    WidgetTester tester,
    _Type type,
  ) async {
    return tester.pumpWidget(
      GetMaterialApp(
        popGesture: true,
        home: ElevatedButton(
          child: const Text('Open Snackbar'),
          onPressed: () => type == _Type.info
              ? CustomSnackbar.info('foo title', 'foo message')
              : CustomSnackbar.info('foo error title', 'foo error message'),
        ),
      ),
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    injectMockDependencies();
  });

  testWidgets(
    'CustomSnackbar.info loads snackbar',
    (WidgetTester tester) async {
      await pumpBaseWidget(tester, _Type.info);
      await tester.pump();

      expect(Get.isSnackbarOpen, false);
      await tester.tap(find.text('Open Snackbar'));

      expect(Get.isSnackbarOpen, true);
      await tester.pump();

      expect(find.text('foo title'), findsOneWidget);
      expect(find.text('foo message'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 4));
      expect(Get.isSnackbarOpen, false);
    },
  );

  testWidgets(
    'CustomSnackbar.errpr loads snackbar',
    (WidgetTester tester) async {
      await pumpBaseWidget(tester, _Type.error);
      await tester.pump();

      expect(Get.isSnackbarOpen, false);
      await tester.tap(find.text('Open Snackbar'));

      expect(Get.isSnackbarOpen, true);
      await tester.pump();

      expect(find.text('foo error title'), findsOneWidget);
      expect(find.text('foo error message'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 4));
      expect(Get.isSnackbarOpen, false);
    },
  );
}
