import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/widgets/bottom-sheets/bottom_sheets_wrapper.dart';
import 'package:plan_sync/widgets/time_table_for_day.dart';

class TimeTableWidget extends StatefulWidget {
  const TimeTableWidget({super.key});

  @override
  State<TimeTableWidget> createState() => _TimeTableWidgetState();
}

class _TimeTableWidgetState extends State<TimeTableWidget> {
  int? sortColumnIndex;
  bool sortAscending = false;

  List sortedUniqueTime = [];
  List<DataRow> rowList = [];
  List<DataColumn> columnsList = [];

  void showMoreInfo(Map<String, dynamic> data, ColorScheme colorScheme) {
    Widget dialog = Dialog(
      backgroundColor: colorScheme.background,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 24.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                'About this schedule',
                style: TextStyle(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // section details
            RichText(
              text: TextSpan(
                  text: 'Section:',
                  style: TextStyle(
                    color: colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '  ${data['meta']['section']}'.toUpperCase(),
                      style: TextStyle(
                        color: colorScheme.onBackground,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  ]),
            ),
            const SizedBox(height: 8),
            // class type
            RichText(
              text: TextSpan(
                  text: 'Schedule Type:',
                  style: TextStyle(
                    color: colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '  ${data['meta']['type']}'.toUpperCase(),
                      style: TextStyle(
                        color: colorScheme.onBackground,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  ]),
            ),
            const SizedBox(height: 8),
            // revision
            RichText(
              text: TextSpan(
                  text: 'Schedule Version:',
                  style: TextStyle(
                    color: colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '  ${data['meta']['revision']}',
                      style: TextStyle(
                        color: colorScheme.onBackground,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  ]),
            ),
            const SizedBox(height: 8),
            // effective
            RichText(
              text: TextSpan(
                  text: 'Effective from:',
                  style: TextStyle(
                    color: colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '  ${data['meta']['effective-date']}',
                      style: TextStyle(
                        color: colorScheme.onBackground,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  ]),
            ),
            const SizedBox(height: 8),
            // contributor
            RichText(
              text: TextSpan(
                  text: 'Contributor:',
                  style: TextStyle(
                    color: colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '  ${data['meta']['contributor']}',
                      style: TextStyle(
                        color: colorScheme.onBackground,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  ]),
            ),
          ],
        ),
      ),
    );

    Get.dialog(
      dialog,
      barrierColor: colorScheme.onBackground.withOpacity(0.32),
    );
  }

  void reportError() {
    BottomSheets.reportError(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GetBuilder<FilterController>(builder: (filterController) {
      GitService serviceController = Get.find();

      return FutureBuilder(
        future: serviceController.getTimeTable(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
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
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasError) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 32),
                Icon(
                  Icons.error,
                  color: colorScheme.error,
                  size: 40,
                ),
                const SizedBox(height: 16),
                Flexible(child: MarkdownBody(data: "```${snapshot.error}```")),
                const SizedBox(height: 16),
                const Text(
                    "A status report has been sent, this issue will be looked into.")
              ],
            );
          } else if (!snapshot.hasData) {
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
                    "No section selected.",
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                    ),
                  )
                ],
              ),
            );
          } else if (snapshot.data?['meta']['isTimetableUpdating'] ?? false) {
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
              "friday"
            ];

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Effective from ${snapshot.data!["meta"]["effective-date"]}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => showMoreInfo(snapshot.data!, colorScheme),
                      child: Row(
                        children: [
                          Icon(Icons.info_rounded, color: colorScheme.tertiary),
                          const SizedBox(width: 8),
                          Text(
                            'More Info',
                            style: TextStyle(color: colorScheme.tertiary),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => reportError(),
                      child: Row(
                        children: [
                          Icon(Icons.flag_rounded, color: colorScheme.error),
                          const SizedBox(width: 8),
                          Text(
                            'Report Error',
                            style: TextStyle(color: colorScheme.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ListView.separated(
                    scrollDirection: Axis.vertical,
                    itemCount: 5,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) =>
                        TimeTableForDay(day: days[index], data: snapshot.data!),
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 16,
                    ),
                  ),
                )
              ],
            );
          }
        },
      );
    });
  }

  onSort(int columnIndex, bool ascending) {
    setState(() {
      sortColumnIndex = columnIndex;
      sortAscending = ascending;
    });
  }
}
