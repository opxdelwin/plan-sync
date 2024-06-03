import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TimeTableForDay extends StatefulWidget {
  const TimeTableForDay({super.key, required this.data, required this.day});

  final Map data;
  final String day;
  @override
  State<TimeTableForDay> createState() => _TimeTableForDayState();
}

class _TimeTableForDayState extends State<TimeTableForDay> {
  final days = [
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday"
  ];
  List<DataColumn> columns = [];
  List<DataRow> rows = [];

  void buildColumn(BuildContext context) {
    columns.clear();
    widget.data["data"][widget.day].keys.forEach((timespace) {
      columns.add(DataColumn(
          label: Text(
        timespace,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      )));
    });
  }

  void buildRow(BuildContext context) {
    List<DataCell> cells = [];
    widget.data["data"][widget.day].forEach((key, value) {
      cells.add(DataCell(Text(
        value,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      )));
    });

    rows = [
      DataRow(
        selected: DateTime.now().weekday == days.indexOf(widget.day) + 1,
        cells: cells,

        // set highlight color for selected (current) day
        color:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(MaterialState.selected)) {
            return Theme.of(context).colorScheme.secondary.withOpacity(0.12);
          }
          return null;
        }),
      )
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    buildColumn(context);
    buildRow(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (widget.data["meta"]["type"] == "norm-class") {
      return _buildForTimetable(colorScheme);
    } else {
      return _buildForElectives(colorScheme);
    }
  }

  Column _buildForTimetable(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              Text(
                widget.day.capitalizeFirst!,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "Room ${widget.data["meta"]["room"][widget.day]}",
                style: TextStyle(
                  color: colorScheme.onPrimary,
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          key: const ValueKey('TimeTableForDay._buildForTimetable'),
          scrollDirection: Axis.horizontal,
          child: DataTable(
            dividerThickness: 0.5,
            border: TableBorder.all(
              borderRadius: BorderRadius.circular(8),
              color: colorScheme.secondary.withOpacity(0.6),
            ),
            columns: columns,
            rows: rows,
          ),
        ),
      ],
    );
  }

  Column _buildForElectives(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              Text(
                widget.day.capitalizeFirst!,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            dividerThickness: 0.5,
            border: TableBorder.all(
              borderRadius: BorderRadius.circular(8),
              color: colorScheme.secondary.withOpacity(0.6),
            ),
            columns: columns,
            rows: rows,
          ),
        ),
      ],
    );
  }
}
