import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/util/colors.dart';

class FiltersBar extends StatefulWidget {
  const FiltersBar({super.key});

  @override
  State<FiltersBar> createState() => _FiltersBarState();
}

class _FiltersBarState extends State<FiltersBar> {
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
                value: filterController.activeSection,
                dropdownColor: primary,
                disabledHint: const Text("Select Semester First"),
                hint:
                    // serviceController.sections == null
                    // ? LoadingAnimationWidget.prograssiveDots(
                    // color: white, size: 18)
                    // :
                    const Text(
                  "Section",
                  style: TextStyle(color: white, fontSize: 16),
                ),
                menuMaxHeight: 376,
                items: serviceController.sections?.keys
                    .toList()
                    .map((e) => buildMenuItem(serviceController.sections?[e]))
                    .toList(),
                onChanged: filterController.activeSemester == null
                    ? null
                    : (String? newSelection) {
                        print(newSelection);
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

DropdownMenuItem<String> buildMenuItem(String section) {
  return DropdownMenuItem(
    value: section,
    child: Text(
      section,
      style: const TextStyle(color: white),
    ),
  );
}
