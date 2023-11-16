import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/widgets/time_tabel_for_day.dart';
import '../util/colors.dart';

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
  @override
  Widget build(BuildContext context) {
    return GetBuilder<FilterController>(builder: (filterController) {
      GitService serviceController = Get.find();
      serviceController.getTimeTable();

      return GetBuilder<GitService>(builder: (serviceController) {
        if (serviceController.isWorking.value) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 32),
              Center(child: CircularProgressIndicator()),
            ],
          );
        } else if (serviceController.isError.value) {
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
                      data: "```${serviceController.errorDetails}```")),
              const SizedBox(height: 16),
              const Text(
                  "A status report has been sent, this issue will be looked into.")
            ],
          );
        } else if (serviceController.latestTimeTable == null) {
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
                Text("No section selected.")
              ],
            ),
          );
        } else {
          final days = ["monday", "tuesday", "wednesday", "thursday", "friday"];

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: secondary),
                  const SizedBox(width: 8),
                  Text(
                    "Effective from ${serviceController.latestTimeTable!["meta"]["effective-date"]}",
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
                      data: serviceController.latestTimeTable!),
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 16,
                  ),
                ),
              )
            ],
          );
        }
      });
    });
  }

  onSort(int columnIndex, bool ascending) {
    setState(() {
      sortColumnIndex = columnIndex;
      sortAscending = ascending;
    });
  }
}
