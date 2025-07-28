import 'package:home_widget/home_widget.dart';
import 'package:plan_sync/backend/services/native_widgets/bg_schedule_worker.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:workmanager/workmanager.dart';
import 'package:plan_sync/backend/services/native_widgets/interactivity_callback.dart';

@pragma("vm:entry-point")
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == "getSchedule") {
      await HomeWidget.registerInteractivityCallback(
        homeWidgetInteractivityCallback,
      );

      Logger.i("[WorkManager] Executing task: $task");
      try {
        await getSchedule();
      } catch (e, stack) {
        Logger.e("[WorkManager] Error executing task: $e\n$stack");
        return Future.error(e, stack);
      }
      return Future.value(true);
    }
    return Future.value(false);
  });
}

void registerWorkManager() async {
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  await Workmanager().registerOneOffTask(
    "getSchedule-${DateTime.now().millisecondsSinceEpoch}",
    "getSchedule",
    initialDelay: const Duration(seconds: 5),
  );
}
