import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plan_sync/widgets/popups/report_error_mail_popup.dart';

class PopupsWrapper {
  static void reportError({
    bool autoFill = true,
    required BuildContext context,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    Get.dialog(
      ReportErrorMailPopup(
        autoFill: autoFill,
      ),
      barrierColor: colorScheme.onSurface.withOpacity(0.32),
    );
  }
}
