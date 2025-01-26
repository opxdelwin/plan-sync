import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plan_sync/widgets/dropdowns/electives_scheme_bar.dart';
import 'package:plan_sync/widgets/dropdowns/electives_sem_bar.dart';
import 'package:plan_sync/widgets/dropdowns/elective_year_bar.dart';
import 'package:plan_sync/util/snackbar.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:provider/provider.dart';

class ElectivePreferenceBottomSheet extends StatefulWidget {
  const ElectivePreferenceBottomSheet({this.save = false, super.key});

  final bool save;

  @override
  State<ElectivePreferenceBottomSheet> createState() =>
      ElectivePreferenceBottomSheetState();
}

@visibleForTesting
class ElectivePreferenceBottomSheetState
    extends State<ElectivePreferenceBottomSheet> {
  late bool savePreferencesOnExit;

  @override
  void initState() {
    super.initState();
    savePreferencesOnExit = widget.save;
  }

  void exitBottomSheet() {
    if (savePreferencesOnExit) {
      FilterController controller = Provider.of<FilterController>(
        context,
        listen: false,
      );
      controller.storePrimaryElectiveYear(context);
      controller.storePrimaryElectiveSemester(context);
      controller.storePrimaryElectiveScheme(context);
      CustomSnackbar.info(
        'Primary Preferences Stored!',
        "Your timetable will be selected by default.",
        context,
      );
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(
          left: size.width * 0.04,
          right: size.width * 0.04,
        ),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              // preference switch
              ListTile(
                enableFeedback: true,
                leading: Icon(
                  Icons.downloading_rounded,
                  color: colorScheme.onSurface,
                ),
                title: Text(
                  "Save Preferences",
                  style: TextStyle(
                    color: colorScheme.onSurface,
                  ),
                ),
                trailing: Switch.adaptive(
                  value: savePreferencesOnExit,
                  activeTrackColor: colorScheme.secondary.withOpacity(
                    0.88,
                  ),
                  inactiveTrackColor: Colors.transparent,
                  trackOutlineColor: WidgetStatePropertyAll(
                    savePreferencesOnExit
                        ? colorScheme.secondary.withOpacity(
                            0.8,
                          )
                        : colorScheme.primary.withOpacity(0.48),
                  ),
                  trackOutlineWidth: const WidgetStatePropertyAll(1),
                  onChanged: (value) {
                    setState(() {
                      savePreferencesOnExit = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),

              // preference description
              Padding(
                padding: EdgeInsets.only(
                  left: size.width * 0.04,
                  right: size.width * 0.04,
                ),
                child: Text(
                  'We will store these, so that  next time you open Plan Sync, your classes are selected automatically!',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Program selection
              ListTile(
                enableFeedback: true,
                leading: Icon(
                  Icons.book_rounded,
                  color: colorScheme.onSurface,
                ),
                title: Text(
                  'Program',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                  ),
                ),
                trailing: Text(
                  'BTech.',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),

              // year selection
              ListTile(
                enableFeedback: true,
                leading: Icon(
                  Icons.book_rounded,
                  color: colorScheme.onSurface,
                ),
                title: Text(
                  'Year',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                  ),
                ),
                trailing: const ElectiveYearBar(),
              ),

              // semester selection
              ListTile(
                enableFeedback: true,
                leading: Icon(
                  Icons.book_rounded,
                  color: colorScheme.onSurface,
                ),
                title: Text(
                  'Semester',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                  ),
                ),
                trailing: const ElectiveSemesterBar(),
              ),

              // section selection
              ListTile(
                enableFeedback: true,
                leading: Icon(
                  Icons.book_rounded,
                  color: colorScheme.onSurface,
                ),
                title: Text(
                  'Scheme',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                  ),
                ),
                trailing: const ElectiveSchemeBar(),
              ),
              const SizedBox(height: 32),

              // save and exit button
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStatePropertyAll(colorScheme.secondary),
                  foregroundColor:
                      WidgetStatePropertyAll(colorScheme.onSecondary),
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: size.width * 0.08),
                  ),
                ),
                onPressed: exitBottomSheet,
                child: Text(
                  'Done',
                  style: TextStyle(
                    color: colorScheme.onSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16)
            ],
          ),
        ),
      ),
    );
  }
}
