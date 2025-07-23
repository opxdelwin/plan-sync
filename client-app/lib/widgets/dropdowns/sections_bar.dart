import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:plan_sync/util/snackbar.dart';
import 'package:provider/provider.dart';

class SectionsBar extends StatefulWidget {
  const SectionsBar({super.key});

  @override
  State<SectionsBar> createState() => _SectionsBarState();
}

class _SectionsBarState extends State<SectionsBar> {
  String? selectedValue;
  bool _hasShownSnackbar = false;

  void _showNetworkError() {
    if (!_hasShownSnackbar) {
      _hasShownSnackbar = true;
      CustomSnackbar.error(
        'Poor Internet Connection',
        'Please restart app with a better connection',
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: colorScheme.onSurface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: 128,
        height: 48,
        child: DropdownButtonHideUnderline(
          child: Consumer<GitService>(
            builder: (ctx, serviceController, child) =>
                Consumer<FilterController>(
                    builder: (ctx, filterController, child) {
              // Reset snackbar flag when data arrives
              if (filterController.activeSemester != null &&
                  serviceController.sections != null &&
                  serviceController.sections!.isNotEmpty) {
                _hasShownSnackbar = false;
              }

              // Check if data is missing and show snackbar if tapped
              if (filterController.activeSemester != null &&
                  (serviceController.sections == null ||
                      serviceController.sections!.isEmpty)) {
                return GestureDetector(
                  onTap: _showNetworkError,
                  child: Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LoadingAnimationWidget.progressiveDots(
                        color: Colors.black,
                        size: 24,
                      ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: colorScheme.surface,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return DropdownButton<String>(
                isExpanded: true,
                elevation: 0,
                enableFeedback: true,
                style: TextStyle(color: colorScheme.onSurface),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: colorScheme.surface,
                ),
                value: filterController.activeSection,
                dropdownColor: colorScheme.onSurface,
                disabledHint: Text(
                  "Select Semester First",
                  style: TextStyle(
                    color: colorScheme.surface,
                    fontSize: 16,
                  ),
                ),
                hint: Text(
                  "Section",
                  style: TextStyle(
                    color: colorScheme.surface,
                    fontSize: 16,
                  ),
                ),
                menuMaxHeight: 376,
                items: serviceController.sections?.keys
                    .toList()
                    .map((e) => buildMenuItem(
                          serviceController.sections?[e],
                          colorScheme.surface,
                        ))
                    .toList(),
                onChanged: filterController.activeSemester == null
                    ? null
                    : (String? newSelection) {
                        Logger.i('new section selected: $newSelection');
                        filterController.activeSection = newSelection;
                      },
              );
            }),
          ),
        ),
      ),
    );
  }
}

DropdownMenuItem<String> buildMenuItem(String section, Color color) {
  return DropdownMenuItem(
    value: section,
    child: Text(
      section,
      style: TextStyle(color: color),
    ),
  );
}
