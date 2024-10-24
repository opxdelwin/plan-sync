import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plan_sync/util/enums.dart';
import 'package:plan_sync/widgets/popups/delete_account_popup.dart';
import 'package:plan_sync/widgets/popups/inapp_upate_failed_popup.dart';
import 'package:plan_sync/widgets/popups/report_error_mail_popup.dart';

class PopupsWrapper {
  static void reportError({
    bool autoFill = true,
    required BuildContext context,
    ScheduleType? scheduleType,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    Get.dialog(
      ReportErrorMailPopup(
        autoFill: autoFill,
        scheduleType: scheduleType,
      ),
      transitionDuration: const Duration(milliseconds: 150),
      transitionCurve: Curves.easeInOut,
      barrierColor: colorScheme.onSurface.withValues(alpha: 0.32),
    );
  }

  static deleteAccount({
    required BuildContext context,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    Get.dialog(
      const DeleteAccountPopup(),
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 150),
      transitionCurve: Curves.easeInOut,
      barrierColor: colorScheme.onSurface.withValues(alpha: 0.32),
    );
  }

  static void showInAppUpateFailedPopup() {
    Get.dialog(
      const InAppUpateFailedPopup(),
      transitionDuration: const Duration(milliseconds: 150),
      transitionCurve: Curves.easeInOut,
      barrierDismissible: true,
    );
  }
}
