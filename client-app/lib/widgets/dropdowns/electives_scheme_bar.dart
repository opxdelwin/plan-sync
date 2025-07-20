import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/util/snackbar.dart';
import 'package:provider/provider.dart';

class ElectiveSchemeBar extends StatefulWidget {
  const ElectiveSchemeBar({super.key});

  @override
  State<ElectiveSchemeBar> createState() => _ElectiveSchemeBarState();
}

class _ElectiveSchemeBarState extends State<ElectiveSchemeBar> {
  String? selectedValue;
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
          child: Consumer<GitService>(
            builder: (ctx, serviceController, child) =>
                Consumer<FilterController>(
                    builder: (ctx, filterController, child) {
              // Reset snackbar flag when data arrives
              if (filterController.activeElectiveSemester != null &&
                  serviceController.electiveSchemes != null &&
                  serviceController.electiveSchemes!.isNotEmpty) {
                _hasShownSnackbar = false;
              }

              // Check if data is missing and show snackbar if tapped
              if (filterController.activeElectiveSemester != null &&
                  (serviceController.electiveSchemes == null ||
                      serviceController.electiveSchemes!.isEmpty)) {
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
                style: TextStyle(color: colorScheme.surface),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: colorScheme.surface,
                ),
                value: filterController.activeElectiveScheme,
                dropdownColor: colorScheme.onSurface,
                disabledHint: Text(
                  "Select Semester First",
                  style: TextStyle(
                    color: colorScheme.surface,
                  ),
                ),
                hint: Text(
                  "Scheme",
                  style: TextStyle(color: colorScheme.surface, fontSize: 16),
                ),
                menuMaxHeight: 256,
                items: serviceController.electiveSchemes?.keys
                    .toList()
                    .map((e) => buildMenuItem(
                          serviceController.electiveSchemes?[e],
                          colorScheme.surface,
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
