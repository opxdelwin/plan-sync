import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:plan_sync/util/snackbar.dart';
import 'package:provider/provider.dart';

class ElectiveSemesterBar extends StatefulWidget {
  const ElectiveSemesterBar({super.key});

  @override
  State<ElectiveSemesterBar> createState() => _ElectiveSemesterBarState();
}

class _ElectiveSemesterBarState extends State<ElectiveSemesterBar> {
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
          child: Consumer<GitService>(builder: (ctx, serviceController, child) {
            return Consumer<FilterController>(
                builder: (ctx, filterController, child) {
              // Reset snackbar flag when data arrives
              if (serviceController.selectedElectiveYear != null &&
                  serviceController.electivesSemesters != null &&
                  serviceController.electivesSemesters!.isNotEmpty) {
                _hasShownSnackbar = false;
              }

              // Check if data is missing and show snackbar if tapped
              if (serviceController.selectedElectiveYear != null &&
                  (serviceController.electivesSemesters == null ||
                      serviceController.electivesSemesters!.isEmpty)) {
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
                style: TextStyle(color: colorScheme.surface),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: colorScheme.surface,
                ),
                disabledHint: Text(
                  "Select Semester First",
                  style: TextStyle(
                    color: colorScheme.surface,
                  ),
                ),
                value: filterController.activeElectiveSemester,
                dropdownColor: colorScheme.onSurface,
                menuMaxHeight: 256,
                hint: serviceController.electivesSemesters == null
                    ? LoadingAnimationWidget.progressiveDots(
                        color: colorScheme.surface, size: 18)
                    : Text(
                        "Elective Semester",
                        style: TextStyle(
                          color: colorScheme.surface,
                          fontSize: 16,
                        ),
                      ),
                items: serviceController.electivesSemesters
                    ?.map((e) => _buildMenuItem(
                          e,
                          colorScheme.surface,
                        ))
                    .toList(),
                onChanged: (String? newSelection) {
                  Logger.i("new elective semester: $newSelection");
                  filterController.activeElectiveSemester = newSelection;
                  Provider.of<GitService>(
                    context,
                    listen: false,
                  ).getElectiveSchemes(context: context);
                },
              );
            });
          }),
        ),
      ),
    );
  }
}

DropdownMenuItem<String> _buildMenuItem(String semester, Color color) {
  return DropdownMenuItem(
    value: semester,
    child: Text(
      semester,
      style: TextStyle(color: color),
    ),
  );
}
