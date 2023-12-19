import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/util/logger.dart';

class FiltersBar extends StatefulWidget {
  const FiltersBar({super.key});

  @override
  State<FiltersBar> createState() => _FiltersBarState();
}

class _FiltersBarState extends State<FiltersBar> {
  String? selectedValue;

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
          child: GetBuilder<GitService>(
            builder: (serviceController) =>
                GetBuilder<FilterController>(builder: (filterController) {
              return DropdownButton<String>(
                isExpanded: true,
                elevation: 0,
                enableFeedback: true,
                style: TextStyle(color: colorScheme.onBackground),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: colorScheme.background,
                ),
                value: filterController.activeSection,
                dropdownColor: colorScheme.onBackground,
                disabledHint: const Text("Select Semester First"),
                hint: Text(
                  "Section",
                  style: TextStyle(
                    color: colorScheme.background,
                    fontSize: 16,
                  ),
                ),
                menuMaxHeight: 376,
                items: serviceController.sections?.keys
                    .toList()
                    .map((e) => buildMenuItem(
                          serviceController.sections?[e],
                          colorScheme.background,
                        ))
                    .toList(),
                onChanged: filterController.activeSemester == null
                    ? null
                    : (String? newSelection) {
                        Logger.i(newSelection);
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
