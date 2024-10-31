import 'package:flutter/material.dart';
import 'package:plan_sync/controllers/analytics_controller.dart';
import 'package:plan_sync/widgets/bottom-sheets/contribute_schedule.dart';
import 'package:plan_sync/widgets/bottom-sheets/elective_preference.dart';
import 'package:plan_sync/widgets/bottom-sheets/report_error.dart';
import 'package:plan_sync/widgets/bottom-sheets/schedule_preference.dart';
import 'package:plan_sync/widgets/bottom-sheets/share_app.dart';
import 'package:provider/provider.dart';

class BottomSheets {
  static changeSectionPreference({
    required BuildContext context,
    bool save = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      backgroundColor: colorScheme.surfaceContainerHighest,
      builder: (context) => SchedulePreferenceBottomSheet(
        save: save,
      ),
    );
  }

  static reportError({
    required BuildContext context,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: colorScheme.surfaceContainerHighest,
      builder: (context) => const ReportErrorBottomSheet(),
    );
  }

  static contributeTimeTable({
    required BuildContext context,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: colorScheme.surfaceContainerHighest,
      builder: (context) => const ContributeScheduleBottomSheet(),
    );
  }

  static changeElectiveSchemePreference({
    required BuildContext context,
    bool save = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      backgroundColor: colorScheme.surfaceContainerHighest,
      builder: (context) => ElectivePreferenceBottomSheet(
        save: save,
      ),
    );
  }

  static shareAppBottomSheet({
    required BuildContext context,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    Provider.of<AnalyticsController>(
      context,
      listen: false,
    ).logShareViaExternalApps();
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      enableDrag: true,
      useRootNavigator: true,
      backgroundColor: colorScheme.surfaceContainerHighest,
      barrierColor: colorScheme.onSurface.withValues(alpha: 0.16),
      builder: (context) => const ShareAppSheet(),
    );
  }
}
