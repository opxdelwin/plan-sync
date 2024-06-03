import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/widgets/bottom-sheets/bottom_sheets_wrapper.dart';

/// Usually on the home screen used to select
/// required time table.
class SchedulePreferenceButton extends StatefulWidget {
  const SchedulePreferenceButton({super.key});

  @override
  State<SchedulePreferenceButton> createState() =>
      _SchedulePreferenceButtonState();
}

class _SchedulePreferenceButtonState extends State<SchedulePreferenceButton> {
  FilterController filterController = Get.find();
  String? sectionSemesterShortCode;

  @override
  void initState() {
    super.initState();
    filterController.getShortCode().then(
          (code) => setState(() {
            sectionSemesterShortCode = code;
          }),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton(
      onPressed: () => BottomSheets.changeSectionPreference(
        context: context,
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(colorScheme.onSurface),
      ),
      child: Row(
        children: [
          GetBuilder<FilterController>(
            builder: (filterController) {
              filterController.getShortCode().then(
                    (code) => setState(() {
                      sectionSemesterShortCode = code;
                    }),
                  );
              return Text(
                sectionSemesterShortCode ?? 'Processing',
                style: TextStyle(color: colorScheme.background),
              );
            },
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colorScheme.background,
          ),
        ],
      ),
    );
  }
}
