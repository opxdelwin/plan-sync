import 'package:flutter/material.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:provider/provider.dart';

class ElectiveYearBar extends StatefulWidget {
  const ElectiveYearBar({super.key});

  @override
  State<ElectiveYearBar> createState() => _ElectiveYearBarState();
}

class _ElectiveYearBarState extends State<ElectiveYearBar> {
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
            builder: (ctx, serviceController, child) => DropdownButton<String>(
              isExpanded: true,
              elevation: 0,
              enableFeedback: true,
              style: TextStyle(color: colorScheme.onSurface),
              icon: Icon(
                Icons.arrow_drop_down,
                color: colorScheme.surface,
              ),
              value: serviceController.selectedElectiveYear?.toString(),
              dropdownColor: colorScheme.onSurface,
              hint: Text(
                "Year",
                style: TextStyle(
                  color: colorScheme.surface,
                  fontSize: 16,
                ),
              ),
              menuMaxHeight: 376,
              items: serviceController.electiveYears
                  ?.map((year) => buildMenuItem(
                        year,
                        colorScheme.surface,
                      ))
                  .toList(),
              onChanged: (String? newSelection) {
                if (newSelection == null) {
                  return;
                }
                Logger.i(newSelection);
                serviceController.selectedElectiveYear = newSelection;
                Provider.of<GitService>(
                  context,
                  listen: false,
                ).getElectiveSemesters(context);
              },
            ),
          ),
        ),
      ),
    );
  }
}

DropdownMenuItem<String> buildMenuItem(String year, Color color) {
  return DropdownMenuItem(
    value: year,
    child: Text(
      year,
      style: TextStyle(color: color),
    ),
  );
}
