import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';

class ElectiveSemesterBar extends StatefulWidget {
  const ElectiveSemesterBar({super.key});

  @override
  State<ElectiveSemesterBar> createState() => _ElectiveSemesterBarState();
}

class _ElectiveSemesterBarState extends State<ElectiveSemesterBar> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: colorScheme.onBackground,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: 128,
        height: 48,
        child: DropdownButtonHideUnderline(
          child: GetBuilder<GitService>(builder: (serviceController) {
            return GetBuilder<FilterController>(builder: (filterController) {
              return DropdownButton<String>(
                isExpanded: true,
                elevation: 0,
                enableFeedback: true,
                style: TextStyle(color: colorScheme.background),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: colorScheme.background,
                ),
                value: filterController.activeElectiveSemester,
                dropdownColor: colorScheme.onBackground,
                menuMaxHeight: 256,
                hint: serviceController.electivesSemesters == null
                    ? LoadingAnimationWidget.prograssiveDots(
                        color: colorScheme.onBackground, size: 18)
                    : Text(
                        "Elective Semester",
                        style: TextStyle(
                          color: colorScheme.background,
                          fontSize: 16,
                        ),
                      ),
                items: serviceController.electivesSemesters
                    ?.map((e) => _buildMenuItem(
                          e,
                          colorScheme.background,
                        ))
                    .toList(),
                onChanged: (String? newSelection) {
                  print("new elective semester: $newSelection");
                  filterController.activeElectiveSemester = newSelection;
                  serviceController.getElectiveSchemes();
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
