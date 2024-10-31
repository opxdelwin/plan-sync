import 'package:flutter/material.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/widgets/bottom-sheets/bottom_sheets_wrapper.dart';
import 'package:provider/provider.dart';

/// Usually on the home screen used to select
/// required time table.
class ElectivePreferenceButton extends StatefulWidget {
  const ElectivePreferenceButton({super.key});

  @override
  State<ElectivePreferenceButton> createState() =>
      _ElectivePreferenceButtonState();
}

class _ElectivePreferenceButtonState extends State<ElectivePreferenceButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton(
      onPressed: () => BottomSheets.changeElectiveSchemePreference(
        context: context,
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(colorScheme.onSurface),
      ),
      child: Row(
        children: [
          Selector<FilterController, String?>(
            builder: (ctx, electiveSemesterShortCode, child) {
              return Text(
                electiveSemesterShortCode ?? 'Processing',
                style: TextStyle(color: colorScheme.surface),
              );
            },
            selector: (context, controller) =>
                controller.getElectiveShortCode(),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colorScheme.surface,
          ),
        ],
      ),
    );
  }
}
