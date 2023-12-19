import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/util/external_links.dart';
import 'package:plan_sync/util/snackbar.dart';
import 'package:plan_sync/widgets/filters_bar.dart';
import 'package:plan_sync/widgets/semester_bar.dart';

class BottomSheets {
  static changeSectionPreference({
    required BuildContext context,
    bool save = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: colorScheme.background,
      builder: (context) => PreferenceBottomSheet(
        save: save,
      ),
    );
  }

  static reportError({
    required BuildContext context,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: colorScheme.background,
      builder: (context) => const ReportErrorBottomSheet(),
    );
  }

  static contributeTimeTable({
    required BuildContext context,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: colorScheme.background,
      builder: (context) => const ContributeTimetableBottomSheet(),
    );
  }
}

class PreferenceBottomSheet extends StatefulWidget {
  const PreferenceBottomSheet({this.save = false, super.key});

  final bool save;
  @override
  State<PreferenceBottomSheet> createState() => _PreferenceBottomSheetState();
}

class _PreferenceBottomSheetState extends State<PreferenceBottomSheet> {
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

    return Padding(
      padding: EdgeInsets.only(
        left: size.width * 0.04,
        right: size.width * 0.04,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 16),

            // top drag handle
            Container(
              height: 8,
              width: size.width * 0.24,
              decoration: ShapeDecoration(
                color: colorScheme.onBackground,
                shape: const StadiumBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // preference switch
            ListTile(
              enableFeedback: true,
              leading: Icon(
                Icons.downloading_rounded,
                color: colorScheme.onPrimary,
              ),
              title: Text(
                "Save Preferences",
                style: TextStyle(
                  color: colorScheme.onPrimary,
                ),
              ),
              trailing: Switch.adaptive(
                value: savePreferencesOnExit,
                activeTrackColor: colorScheme.secondary.withOpacity(0.72),
                inactiveTrackColor: Colors.transparent,
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
                  color: colorScheme.onPrimary.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Program selection
            ListTile(
              enableFeedback: true,
              leading: Icon(
                Icons.book_rounded,
                color: colorScheme.onPrimary,
              ),
              title: Text(
                'Program',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                ),
              ),
              trailing: Text(
                'BTech.',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                ),
              ),
            ),

            // semester selection
            ListTile(
              enableFeedback: true,
              leading: Icon(
                Icons.book_rounded,
                color: colorScheme.onPrimary,
              ),
              title: Text(
                'Semester',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                ),
              ),
              trailing: const SemesterBar(),
            ),

            // section selection
            ListTile(
              enableFeedback: true,
              leading: Icon(
                Icons.book_rounded,
                color: colorScheme.onPrimary,
              ),
              title: Text(
                'Section',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                ),
              ),
              trailing: const FiltersBar(),
            ),
            const SizedBox(height: 32),

            // save and exit button
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStatePropertyAll(colorScheme.secondary),
                foregroundColor:
                    MaterialStatePropertyAll(colorScheme.onSecondary),
                padding: MaterialStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: size.width * 0.08),
                ),
              ),
              onPressed: exitBottomSheet,
              child: Text(
                'Done',
                style: TextStyle(
                  color: colorScheme.background,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ReportErrorBottomSheet extends StatelessWidget {
  const ReportErrorBottomSheet({super.key});

  void launchMail() {
    ExternalLinks.reportErrorViaMail();
  }

  void launchGithub() {
    ExternalLinks.reportErrorViaGithub();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: size.width * 0.04,
        right: size.width * 0.04,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // via mail
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Report via mail",
                style: TextStyle(
                  color: colorScheme.onBackground,
                ),
              ),
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(colorScheme.onBackground),
                  ),
                  onPressed: () => launchMail(),
                  child: Row(
                    children: [
                      Text(
                        'Launch Mail',
                        style: TextStyle(
                          color: colorScheme.background,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.mail_outline_rounded,
                        color: colorScheme.background,
                      )
                    ],
                  ))
            ],
          ),

          // via github
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Report via GitHub",
                style: TextStyle(
                  color: colorScheme.onBackground,
                ),
              ),
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(colorScheme.onBackground),
                  ),
                  onPressed: () => launchGithub(),
                  child: Row(
                    children: [
                      Text(
                        'Launch GitHub',
                        style: TextStyle(
                          color: colorScheme.background,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        FontAwesomeIcons.github,
                        color: colorScheme.background,
                      )
                    ],
                  ))
            ],
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class ContributeTimetableBottomSheet extends StatelessWidget {
  const ContributeTimetableBottomSheet({super.key});

  void launchMail() {
    ExternalLinks.contributeTimeTableViaMail();
  }

  void launchGithub() {
    ExternalLinks.contributeTimeTableViaGithub();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: size.width * 0.04,
        right: size.width * 0.04,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // via mail
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Contribute via mail",
                style: TextStyle(
                  color: colorScheme.onBackground,
                ),
              ),
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(colorScheme.onBackground),
                  ),
                  onPressed: () => launchMail(),
                  child: Row(
                    children: [
                      Text(
                        'Launch Mail',
                        style: TextStyle(
                          color: colorScheme.background,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.mail_outline_rounded,
                        color: colorScheme.background,
                      )
                    ],
                  ))
            ],
          ),

          // via github
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Contribute via GitHub",
                style: TextStyle(
                  color: colorScheme.onBackground,
                ),
              ),
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(colorScheme.onBackground),
                  ),
                  onPressed: () => launchGithub(),
                  child: Row(
                    children: [
                      Text(
                        'Launch GitHub',
                        style: TextStyle(
                          color: colorScheme.background,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        FontAwesomeIcons.github,
                        color: colorScheme.background,
                      )
                    ],
                  ))
            ],
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
