import 'package:flutter/material.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/theme_controller.dart';
import 'package:plan_sync/widgets/bottom-sheets/bottom_sheets_wrapper.dart';
import 'package:provider/provider.dart';

/// Usually on the home screen used to select
/// required time table.
class SchedulePreferenceButton extends StatefulWidget {
  const SchedulePreferenceButton({super.key});

  @override
  State<SchedulePreferenceButton> createState() =>
      _SchedulePreferenceButtonState();
}

class _SchedulePreferenceButtonState extends State<SchedulePreferenceButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appTheme = Provider.of<AppThemeController>(context, listen: false);

    return ElevatedButton(
      onPressed: () => BottomSheets.changeSectionPreference(
        context: context,
      ),
      style: ButtonStyle(
        backgroundColor: appTheme.isDarkMode
            ? WidgetStatePropertyAll(colorScheme.primary)
            : WidgetStatePropertyAll(colorScheme.onSurface),
      ),
      child: Row(
        children: [
          Selector<FilterController, String?>(
            builder: (ctx, shortCodee, child) {
              return Text(
                shortCodee ?? 'Processing',
                style: TextStyle(
                  color: appTheme.isDarkMode
                      ? colorScheme.onPrimary
                      : colorScheme.surface,
                ),
              );
            },
            selector: (context, controller) => controller.getShortCode(),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: appTheme.isDarkMode
                ? colorScheme.onPrimary
                : colorScheme.surface,
          ),
        ],
      ),
    );
  }
}
