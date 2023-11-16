import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/util/colors.dart';
import 'package:plan_sync/widgets/electives_scheme_bar.dart';
import 'package:plan_sync/widgets/electives_sem_bar.dart';
import 'package:plan_sync/widgets/time_tabel_for_day.dart';

class ElectiveScreen extends StatefulWidget {
  const ElectiveScreen({super.key});

  @override
  State<ElectiveScreen> createState() => _ElectiveScreenState();
}

class _ElectiveScreenState extends State<ElectiveScreen> {
  // @override
  // void initState() {
  //   super.initState();
  //   GitService service = Get.find();
  //   service.getElectives();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: black,
        elevation: 0.0,
        toolbarHeight: 80,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32),
        )),
        title: const Text(
          "Elective Classes",
          style: TextStyle(
            color: white,
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
                GetBuilder<GitService>(
                  builder: (serviceController) {
                    if (serviceController.isWorking.value) {
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 32),
                          Center(child: CircularProgressIndicator()),
                        ],
                      );
                    } else if (serviceController.isElectivesError.value) {
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
                                  data:
                                      "```${serviceController.errorDetails}```")),
                          const SizedBox(height: 16),
                          const Text(
                              "A status report has been sent, this issue will be looked into.")
                        ],
                      );
                    } else if (serviceController.latestElectives == null &&
                        serviceController.isWorking.isFalse) {
                      return const Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 32),
                            Icon(
                              Icons.info,
                              color: border,
                              size: 40,
                            ),
                            SizedBox(height: 16),
                            Text("No Data Available")
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
                              const Icon(Icons.info_outline_rounded,
                                  color: secondary),
                              const SizedBox(width: 8),
                              Text(
                                "Effective from ${serviceController.latestElectives!["meta"]["effective-date"]}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: black,
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
                              itemBuilder: (context, index) => TimeTableForDay(
                                day: days[index],
                                data: serviceController.latestElectives!,
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
                ),
              ],
            ),
          )),
    );
  }
}
