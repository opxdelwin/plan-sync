import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:plan_sync/controllers/app_tour_controller.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/util/snackbar.dart';
import 'package:plan_sync/widgets/dropdowns/sections_bar.dart';
import 'package:plan_sync/widgets/dropdowns/semester_bar.dart';
import 'package:plan_sync/widgets/dropdowns/year_bar.dart';

class SchedulePreferenceBottomSheet extends StatefulWidget {
  const SchedulePreferenceBottomSheet({this.save = false, super.key});

  final bool save;
  @override
  State<SchedulePreferenceBottomSheet> createState() =>
      SchedulePreferenceBottomSheetState();
}

@visibleForTesting
class SchedulePreferenceBottomSheetState
    extends State<SchedulePreferenceBottomSheet> {
  late bool savePreferencesOnExit;

  @override
  void initState() {
    super.initState();
    savePreferencesOnExit = widget.save;
  }

  void exitBottomSheet() {
    if (savePreferencesOnExit) {
      FilterController controller = Get.find();
      controller.storePrimarySemester();
      controller.storePrimarySection();
      controller.storePrimaryYear();
      CustomSnackbar.info(
        'Primary Preferences Stored!',
        "Your timetable will be selected by default.",
      );
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    AppTourController appTourController = Get.find();

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
                key: appTourController.savePreferenceSwitchKey,
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
                  activeTrackColor: colorScheme.secondary.withValues(
                    alpha: 0.72,
                  ),
                  inactiveTrackColor: Colors.transparent,
                  trackOutlineColor: WidgetStatePropertyAll(
                    colorScheme.secondary.withValues(alpha: 0.24),
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
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                trailing: const YearBar(),
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
                trailing: const SemesterBar(),
              ),

              // section selection
              ListTile(
                key: appTourController.sectionBarKey,
                enableFeedback: true,
                leading: Icon(
                  Icons.book_rounded,
                  color: colorScheme.onSurface,
                ),
                title: Text(
                  'Section',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                  ),
                ),
                trailing: const SectionsBar(),
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
