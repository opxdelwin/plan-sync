import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../util/colors.dart';

class TimeTableForDay extends StatefulWidget {
  const TimeTableForDay({super.key, required this.data, required this.day});

  final Map data;
  final String day;
  @override
  State<TimeTableForDay> createState() => _TimeTableForDayState();
}

class _TimeTableForDayState extends State<TimeTableForDay> {
  final days = ["monday", "tuesday", "wednesday", "thursday", "friday"];
  List<DataColumn> columns = [];
  List<DataRow> rows = [];

  void buildColumn() {
    widget.data["data"][widget.day].keys.forEach((timespace) {
      columns.add(DataColumn(label: Text(timespace)));
    });
  }

  void buildRow() {
    List<DataCell> cells = [];
    widget.data["data"][widget.day].forEach((key, value) {
      cells.add(DataCell(Text(value)));
    });

    rows = [
      DataRow(
        selected: DateTime.now().weekday == days.indexOf(widget.day) + 1,
        cells: cells,
      )
    ];
  }

  @override
  void initState() {
    buildColumn();
    buildRow();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data["meta"]["type"] == "norm-class") {
      return _buildForTimetable();
    } else {
      return _buildForElectives();
    }
  }

  Column _buildForTimetable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              Text(
                widget.day.capitalizeFirst!,
                style:
                    const TextStyle(color: black, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              Text("Room ${widget.data["meta"]["room"][widget.day]}")
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            border: TableBorder.all(
                borderRadius: BorderRadius.circular(8), color: border),
            columns: columns,
            rows: rows,
          ),
        ),
      ],
    );
  }

  Column _buildForElectives() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              Text(
                widget.day.capitalizeFirst!,
                style:
                    const TextStyle(color: black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            border: TableBorder.all(
                borderRadius: BorderRadius.circular(8), color: border),
            columns: columns,
            rows: rows,
          ),
        ),
      ],
    );
  }
}
