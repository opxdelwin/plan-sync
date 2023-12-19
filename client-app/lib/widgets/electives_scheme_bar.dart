import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';

class ElectiveSchemeBar extends StatefulWidget {
  const ElectiveSchemeBar({super.key});

  @override
  State<ElectiveSchemeBar> createState() => _ElectiveSchemeBarState();
}

class _ElectiveSchemeBarState extends State<ElectiveSchemeBar> {
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
                style: TextStyle(color: colorScheme.background),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: colorScheme.background,
                ),
                value: filterController.activeElectiveScheme,
                dropdownColor: colorScheme.onBackground,
                disabledHint: Text(
                  "Select Semester First",
                  style: TextStyle(
                    color: colorScheme.background,
                  ),
                ),
                hint: Text(
                  "Scheme",
                  style: TextStyle(color: colorScheme.background, fontSize: 16),
                ),
                menuMaxHeight: 256,
                items: serviceController.electiveSchemes?.keys
                    .toList()
                    .map((e) => buildMenuItem(
                          serviceController.electiveSchemes?[e],
                          colorScheme.background,
                        ))
                    .toList(),
                onChanged: filterController.activeElectiveSemester == null
                    ? null
                    : (String? newSelection) {
                        serviceController.electiveSchemes
                            ?.forEach((key, value) {
                          if (value == newSelection) {
                            filterController.activeElectiveScheme = value;
                            filterController.activeElectiveSchemeCode = key;
                            serviceController.getElectives();
                          }
                        });
                      },
              );
            }),
          ),
        ),
      ),
    );
  }
}

DropdownMenuItem<String> buildMenuItem(String scheme, Color color) {
  return DropdownMenuItem(
    value: scheme,
    child: Text(
      scheme,
      style: TextStyle(color: color),
    ),
  );
}
