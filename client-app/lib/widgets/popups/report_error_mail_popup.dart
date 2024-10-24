import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/util/external_links.dart';

class ReportErrorMailPopup extends StatelessWidget {
  const ReportErrorMailPopup({super.key, required this.autoFill});

  final bool autoFill;

  Future<void> onPressed() async {
    if (!autoFill) {
      ExternalLinks.reportErrorViaMail();
      return;
    }

    FilterController controller = Get.find();
    GitService git = Get.find();
    FilterController filterController = Get.find();
    ExternalLinks.reportErrorViaMail(
      academicYear: git.selectedYear,
      course: controller.activeSemester,
      section: controller.activeSectionCode,
      weekday: filterController.weekday.key,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: colorScheme.surface,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Send us a mail, and we\'ll get to it',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Oops! Things don't always go as planned, but no worries - we're here to fix it! 😊"
              "\n\n"
              "We've got your back. We'll prefill the email with all the important stuff "
              "like your section and academic year. "
              "\n\n"
              "All you need to do is give it a quick edit and hit that send button. Easy peasy!",
              style: TextStyle(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onPressed,
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      backgroundColor: WidgetStatePropertyAll(
                        colorScheme.primary,
                      ),
                      foregroundColor: WidgetStatePropertyAll(
                        colorScheme.onPrimary,
                      ),
                    ),
                    label: const Text("Open Mail App"),
                    icon: const Icon(Icons.mail_outline_rounded),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
