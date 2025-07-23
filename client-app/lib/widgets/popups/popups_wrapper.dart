import 'package:flutter/material.dart';
import 'package:plan_sync/util/enums.dart';
import 'package:plan_sync/widgets/popups/delete_account_popup.dart';
import 'package:plan_sync/widgets/popups/inapp_upate_failed_popup.dart';
import 'package:plan_sync/widgets/popups/report_error_mail_popup.dart';
import 'package:plan_sync/widgets/popups/request_features_popup.dart';

class PopupsWrapper {
  static void reportError({
    bool autoFill = true,
    required BuildContext context,
    ScheduleType? scheduleType,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    showAdaptiveDialog(
      context: context,
      builder: (context) => ReportErrorMailPopup(
        autoFill: autoFill,
        scheduleType: scheduleType,
      ),
      barrierDismissible: true,
      barrierColor: colorScheme.onSurface.withOpacity(0.32),
    );
  }

  static deleteAccount({
    required BuildContext context,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    showAdaptiveDialog(
      context: context,
      builder: (context) => const DeleteAccountPopup(),
      barrierDismissible: false,
      barrierColor: colorScheme.onSurface.withOpacity(0.32),
    );
  }

  static void requestFeature({
    required BuildContext context,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    showAdaptiveDialog(
      context: context,
      builder: (context) => const RequestFeaturesPopup(),
      barrierDismissible: true,
      barrierColor: colorScheme.onSurface.withOpacity(0.32),
    );
  }

  static void showInAppUpateFailedPopup({
    required BuildContext context,
  }) {
    showAdaptiveDialog(
      context: context,
      builder: (context) => const InAppUpateFailedPopup(),
      barrierDismissible: true,
    );
  }
}
