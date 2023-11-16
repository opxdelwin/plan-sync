import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/util/colors.dart';

class SemesterBar extends StatefulWidget {
  const SemesterBar({super.key});

  @override
  State<SemesterBar> createState() => _SemesterBarState();
}

class _SemesterBarState extends State<SemesterBar> {
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
          child: GetBuilder<GitService>(builder: (serviceController) {
            return GetBuilder<FilterController>(builder: (filterController) {
              return DropdownButton<String>(
                isExpanded: true,
                elevation: 0,
                enableFeedback: true,
                style: const TextStyle(color: black),
                icon: const Icon(Icons.arrow_drop_down, color: white),
                value: filterController.activeSemester,
                dropdownColor: primary,
                menuMaxHeight: 256,
                hint: serviceController.semesters == null
                    ? LoadingAnimationWidget.prograssiveDots(
                        color: white, size: 18)
                    : const Text(
                        "Semester",
                        style: TextStyle(color: white, fontSize: 16),
                      ),
                items: serviceController.semesters
                    ?.map((e) => _buildMenuItem(e))
                    .toList(),
                onChanged: (String? newSelection) {
                  print("new semester: $newSelection");
                  filterController.activeSemester = newSelection;
                },
              );
            });
          }),
        ),
      ),
    );
  }
}

DropdownMenuItem<String> _buildMenuItem(String semester) {
  return DropdownMenuItem(
    value: semester,
    child: Text(
      semester,
      style: const TextStyle(color: white),
    ),
  );
}
