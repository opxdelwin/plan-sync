import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/auth.dart';
import 'package:plan_sync/widgets/buttons/logout_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../../mock_controllers/auth_mock.dart';

void main() {
  Future<void> pumpBaseWidget(
    WidgetTester tester,
  ) async {
    return tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: LogoutButton(),
        ),
      ),
    ));
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    injectMockDependencies();
  });

  testWidgets('LogoutButton loads with icon', (WidgetTester tester) async {
    await pumpBaseWidget(tester);
    await tester.pumpAndSettle();

    expect(find.text('Logout'), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsOneWidget);
  });

  testWidgets('LogoutButton logs out user', (WidgetTester tester) async {
    await pumpBaseWidget(tester);
    await tester.pumpAndSettle();

    final controller = Get.find<Auth>() as MockAuth;
    await controller.loginWithGoogle();

    expect(controller.activeUser, isNotNull);

    // start logout
    await tester.tap(find.text('Logout'));
    expect(controller.activeUser, isNull);
  });
}
