import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:plan_sync/backend/supabase_models/branches.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:provider/provider.dart';

class BranchBar extends StatefulWidget {
  const BranchBar({super.key});

  @override
  State<BranchBar> createState() => _SemesterBarState();
}

class _SemesterBarState extends State<BranchBar> {
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
            return Consumer<FilterController>(
                builder: (ctx, filterController, child) {
              return DropdownButton<Branches>(
                isExpanded: true,
                elevation: 0,
                enableFeedback: true,
                style: TextStyle(color: colorScheme.onSurface),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: colorScheme.surface,
                ),
                value: filterController.selectedBranch,
                dropdownColor: colorScheme.onSurface,
                menuMaxHeight: 256,
                disabledHint: Text(
                  "Select Program First",
                  style: TextStyle(
                    color: colorScheme.surface,
                    fontSize: 16,
                  ),
                ),
                hint: serviceController.branches == null
                    ? LoadingAnimationWidget.progressiveDots(
                        color: colorScheme.onPrimary,
                        size: 18,
                      )
                    : Text(
                        "Branch",
                        style: TextStyle(
                          color: colorScheme.surface,
                          fontSize: 16,
                        ),
                      ),
                items: serviceController.branches
                    ?.map((e) => _buildMenuItem(e, colorScheme.surface))
                    .toList(),
                onChanged: (Branches? newSelection) {
                  Logger.i("new branch: $newSelection");
                  filterController.selectedBranch = newSelection;
                  serviceController.getSemesters(context);
                },
              );
            });
          }),
        ),
      ),
    );
  }
}

DropdownMenuItem<Branches> _buildMenuItem(Branches branch, Color color) {
  return DropdownMenuItem(
    value: branch,
    child: Text(
      branch.branchName,
      style: TextStyle(color: color),
    ),
  );
}
