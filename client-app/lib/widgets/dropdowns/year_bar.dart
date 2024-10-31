import 'package:flutter/material.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:provider/provider.dart';

class YearBar extends StatefulWidget {
  const YearBar({super.key});

  @override
  State<YearBar> createState() => _YearBarState();
}

class _YearBarState extends State<YearBar> {
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
                  DropdownButton<String>(
                      isExpanded: true,
                      elevation: 0,
                      enableFeedback: true,
                      style: TextStyle(color: colorScheme.onSurface),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: colorScheme.surface,
                      ),
                      value: serviceController.selectedYear?.toString(),
                      dropdownColor: colorScheme.onSurface,
                      hint: Text(
                        "Year",
                        style: TextStyle(
                          color: colorScheme.surface,
                          fontSize: 16,
                        ),
                      ),
                      menuMaxHeight: 376,
                      items: serviceController.years
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
                        serviceController.selectedYear = newSelection;
                        Provider.of<GitService>(
                          ctx,
                          listen: false,
                        ).getSemesters(ctx);
                      })),
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
