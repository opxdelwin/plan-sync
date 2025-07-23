import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:plan_sync/util/snackbar.dart';
import 'package:provider/provider.dart';

class YearBar extends StatefulWidget {
  const YearBar({super.key});

  @override
  State<YearBar> createState() => _YearBarState();
}

class _YearBarState extends State<YearBar> {
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
            // Reset snackbar flag when data arrives
            if (serviceController.years != null &&
                serviceController.years!.isNotEmpty) {
              _hasShownSnackbar = false;
            }

            // Check if data is missing and show snackbar if tapped
            if (serviceController.years == null ||
                serviceController.years!.isEmpty) {
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
              },
            );
          }),
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
