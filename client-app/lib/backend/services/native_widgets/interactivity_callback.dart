import 'package:plan_sync/util/logger.dart';

@pragma("vm:entry-point")
void homeWidgetInteractivityCallback(Uri? data) {
  Logger.w("data: ${data.toString()}");
  return;
}
