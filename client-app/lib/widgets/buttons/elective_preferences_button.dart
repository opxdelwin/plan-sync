import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  late FilterController filterController;
  String? electiveSemesterShortCode;

  @override
  void initState() {
    super.initState();
    filterController = Provider.of<FilterController>(context, listen: false);
    filterController.getShortCode().then(
          (code) => setState(() {
            electiveSemesterShortCode = code;
          }),
        );
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
          Consumer<FilterController>(
            builder: (ctx, filterController, child) {
              filterController.getElectiveShortCode().then(
                    (code) => setState(() {
                      electiveSemesterShortCode = code;
                    }),
                  );
              return Text(
                electiveSemesterShortCode ?? 'Processing',
                style: TextStyle(color: colorScheme.surface),
              );
            },
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
