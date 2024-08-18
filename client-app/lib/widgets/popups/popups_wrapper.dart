import 'package:get/get.dart';
import 'package:plan_sync/widgets/popups/report_error_mail_popup.dart';

class PopupsWrapper {
  static void reportError({bool autoFill = true}) {
    Get.dialog(
      ReportErrorMailPopup(
        autoFill: autoFill,
      ),
    );
  }
}
