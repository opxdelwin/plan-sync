import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/widgets/bottom_sheets.dart';
import 'package:plan_sync/widgets/electives_scheme_bar.dart';
import 'package:plan_sync/widgets/electives_sem_bar.dart';
import 'package:plan_sync/widgets/time_table_for_day.dart';

class ElectiveScreen extends StatefulWidget {
  const ElectiveScreen({super.key});

  @override
  State<ElectiveScreen> createState() => _ElectiveScreenState();
}

class _ElectiveScreenState extends State<ElectiveScreen> {
  void reportError() {
    BottomSheets.reportError(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: colorScheme.background,
        elevation: 0.0,
        toolbarHeight: 80,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32),
        )),
        title: Text(
          "Elective Classes",
          style: TextStyle(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),
                const SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElectiveSemesterBar(),
                      SizedBox(width: 16),
                      ElectiveSchemeBar(),
                    ],
                  ),
                ),
                GetBuilder<FilterController>(builder: (filterController) {
                  GitService service = Get.find();
                  return FutureBuilder(
                    future: service.getElectives(),
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
                                  color: colorScheme.onBackground,
                                ),
                              )
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
                          children: [
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(Icons.info_outline_rounded,
                                    color: colorScheme.tertiary),
                                const SizedBox(width: 8),
                                Text(
                                  "Effective from ${snapshot.data!["meta"]["effective-date"]}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onBackground,
                                  ),
                                ),
                                Spacer(),
                                InkWell(
                                  onTap: () => reportError(),
                                  child: Row(
                                    children: [
                                      Icon(Icons.flag_rounded,
                                          color: colorScheme.error),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Report Error',
                                        style:
                                            TextStyle(color: colorScheme.error),
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
