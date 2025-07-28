import 'package:workmanager/workmanager.dart';

@pragma("vm:entry-point")
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    print(
      "Native called background task: $task",
    );
    return Future.value(true);
  });
}

void registerWorkManager() {
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerOneOffTask("task-identifier", "simpleTask");
}
