import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:plan_sync/backend/models/timetable.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/util/enums.dart';
import 'package:plan_sync/widgets/buttons/elective_preferences_button.dart';
import 'package:plan_sync/widgets/popups/popups_wrapper.dart';
import 'package:plan_sync/widgets/time_table_for_day.dart';
import 'package:provider/provider.dart';

class ElectiveScreen extends StatefulWidget {
  const ElectiveScreen({super.key});

  @override
  State<ElectiveScreen> createState() => _ElectiveScreenState();
}

class _ElectiveScreenState extends State<ElectiveScreen> {
  late FilterController filterController;
  String? sectionSemesterShortCode;

  void reportError() {
    PopupsWrapper.reportError(
      context: context,
      scheduleType: ScheduleType.electives,
    );
  }

  @override
  void initState() {
    super.initState();
    filterController = Provider.of<FilterController>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerHighest,
        elevation: 0.0,
        toolbarHeight: 80,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32),
        )),
        title: Text(
          "Elective Classes",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        actions: const [
          ElectivePreferenceButton(),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Consumer<FilterController>(
                    builder: (ctx, filterController, child) {
                  GitService service =
                      Provider.of<GitService>(context, listen: false);
                  return StreamBuilder(
                    key: ValueKey(filterController.getElectiveShortCode()),
                    stream: service.getElectives(),
                    builder: (context, AsyncSnapshot<Timetable?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 32),
                            Center(
                                child: CircularProgressIndicator(
                              color: colorScheme.secondary,
                            )),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 32),
                            const Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 40,
                            ),
                            const SizedBox(height: 16),
                            Flexible(
                                child: MarkdownBody(
                                    data: "```${snapshot.error}```")),
                            const SizedBox(height: 16),
                            const Text(
                                "A status report has been sent, this issue will be looked into.")
                          ],
                        );
                      } else if (!snapshot.hasData &&
                          snapshot.connectionState == ConnectionState.done) {
                        return Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 32),
                              Icon(
                                Icons.info,
                                color: colorScheme.secondary,
                                size: 40,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No Data Available",
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                ),
                              )
                            ],
                          ),
                        );
                      } else if (snapshot.data?.meta.isTimetableUpdating ??
                          false) {
                        return Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 32),
                              Icon(
                                Icons.settings_outlined,
                                color: colorScheme.secondary,
                                size: 40,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "We're working on this timetable,",
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                              Text(
                                "Check back in soon!",
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        final days = [
                          "monday",
                          "tuesday",
                          "wednesday",
                          "thursday",
                          "friday",
                          "saturday"
                        ];

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        color: colorScheme.tertiary,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          "Effective from ${snapshot.data!.meta.effectiveDate}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                TextButton.icon(
                                  onPressed: () => reportError(),
                                  label: Text(
                                    'Report Error',
                                    style: TextStyle(color: colorScheme.error),
                                  ),
                                  icon: Icon(
                                    Icons.flag_rounded,
                                    color: colorScheme.error,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ListView.separated(
                                scrollDirection: Axis.vertical,
                                itemCount: snapshot.data!.data.keys.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) =>
                                    TimeTableForDay(
                                  day: days[index],
                                  data: snapshot.data!,
                                ),
                                separatorBuilder: (context, index) =>
                                    const SizedBox(
                                  height: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        );
                      }
                    },
                  );
                }),
              ],
            ),
          )),
    );
  }
}
