import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:plan_sync/backend/supabase_models/programs.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:provider/provider.dart';

class ProgramBar extends StatefulWidget {
  const ProgramBar({super.key});

  @override
  State<ProgramBar> createState() => _ProgramBarState();
}

class _ProgramBarState extends State<ProgramBar> {
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
            builder: (ctx, serviceController, child) {
              return Consumer<FilterController>(
                  builder: (ctx, filterController, child) {
                return DropdownButton<Program>(
                  isExpanded: true,
                  elevation: 0,
                  enableFeedback: true,
                  style: TextStyle(color: colorScheme.onSurface),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: colorScheme.surface,
                  ),
                  value: filterController.selectedProgram,
                  dropdownColor: colorScheme.onSurface,
                  menuMaxHeight: 256,
                  hint: serviceController.programs == null
                      ? LoadingAnimationWidget.progressiveDots(
                          color: colorScheme.onPrimary,
                          size: 18,
                        )
                      : Text(
                          "Program",
                          style: TextStyle(
                            color: colorScheme.surface,
                            fontSize: 16,
                          ),
                        ),
                  items: serviceController.programs
                      ?.map((e) => _buildMenuItem(e, colorScheme.surface))
                      .toList(),
                  onChanged: (Program? newSelection) {
                    Logger.i("new program: $newSelection");
                    filterController.selectedProgram = newSelection;
                    serviceController.getBranch(context);
                  },
                );
              });
            },
          ),
        ),
      ),
    );
  }
}

DropdownMenuItem<Program> _buildMenuItem(Program program, Color color) {
  return DropdownMenuItem(
    value: program,
    child: Text(
      program.name,
      style: TextStyle(color: color),
    ),
  );
}
