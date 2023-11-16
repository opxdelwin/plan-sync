import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/util/colors.dart';

class ElectiveSchemeBar extends StatefulWidget {
  const ElectiveSchemeBar({super.key});

  @override
  State<ElectiveSchemeBar> createState() => _ElectiveSchemeBarState();
}

class _ElectiveSchemeBarState extends State<ElectiveSchemeBar> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const ShapeDecoration(
        shape: StadiumBorder(side: BorderSide(color: border)),
        color: primary,
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
                style: const TextStyle(color: black),
                icon: const Icon(Icons.arrow_drop_down, color: white),
                value: filterController.activeElectiveScheme,
                dropdownColor: primary,
                disabledHint: const Text("Select Semester First"),
                hint:
                    // serviceController.sections == null
                    // ? LoadingAnimationWidget.prograssiveDots(
                    // color: white, size: 18)
                    // :
                    const Text(
                  "Scheme",
                  style: TextStyle(color: white, fontSize: 16),
                ),
                menuMaxHeight: 256,
                items: serviceController.electiveSchemes?.keys
                    .toList()
                    .map((e) =>
                        buildMenuItem(serviceController.electiveSchemes?[e]))
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

DropdownMenuItem<String> buildMenuItem(String scheme) {
  return DropdownMenuItem(
    value: scheme,
    child: Text(
      scheme,
      style: const TextStyle(color: white),
    ),
  );
}
