import 'package:flutter/material.dart';
import 'package:plan_sync/backend/supabase_models/section.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:provider/provider.dart';

class SectionsBar extends StatefulWidget {
  const SectionsBar({super.key});

  @override
  State<SectionsBar> createState() => _SectionsBarState();
}

class _SectionsBarState extends State<SectionsBar> {
  String? selectedValue;

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
              return DropdownButton<Section>(
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
                  serviceController.sections?.isEmpty == true
                      ? "No Sections Found"
                      : "Select Semester First",
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
                items: serviceController.sections
                    ?.map((e) => buildMenuItem(
                          e,
                          colorScheme.surface,
                        ))
                    .toList(),
                onChanged: filterController.activeSemester == null
                    ? null
                    : (Section? newSelection) {
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

DropdownMenuItem<Section> buildMenuItem(Section section, Color color) {
  return DropdownMenuItem(
    value: section,
    child: Text(
      section.sectionName,
      style: TextStyle(color: color),
    ),
  );
}
