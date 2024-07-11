import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plan_sync/backend/models/timetable.dart';
import 'package:plan_sync/widgets/no_schedule_widget.dart';
import 'package:plan_sync/widgets/subject_tile.dart';

class TimeTableForDay extends StatefulWidget {
  const TimeTableForDay({super.key, required this.data, required this.day});

  final Timetable data;
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
    widget.data.data[widget.day]?.forEach((elective) {
      columns.add(DataColumn(
          label: Text(
        elective.subject ?? 'No Elective Name',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      )));
    });
  }

  void buildRow(BuildContext context) {
    List<DataCell> cells = [];
    widget.data.data[widget.day]?.forEach((elective) {
      cells.add(DataCell(Text(
        elective.room ?? 'No Elective Room',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          if (states.contains(WidgetState.selected)) {
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
    if (widget.data.meta.type != 'norm-class') {
      buildColumn(context);
      buildRow(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (widget.data.meta.type == "norm-class") {
      return _buildForTimetable(colorScheme);
    } else {
      return _buildForElectives(colorScheme);
    }
  }

  Widget _buildForTimetable(ColorScheme colorScheme) {
    if (widget.data.data[widget.day] == null) {
      return const NoScheduleWidget();
    }
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
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.24,
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          key: const ValueKey('TimeTableForDay._buildForTimetable'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => SubjectTile(
            location:
                widget.data.data[widget.day]?[index].room ?? 'Unavailable',
            time: widget.data.data[widget.day]?[index].time ?? 'Unavailable',
            subject:
                widget.data.data[widget.day]?[index].subject ?? 'Unavailable',
          ),
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemCount: widget.data.data[widget.day]?.length ?? 0,
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
                  color: colorScheme.onSurface,
                  letterSpacing: 0.6,
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
              color: Get.isDarkMode
                  ? colorScheme.onSurfaceVariant.withOpacity(0.4)
                  : colorScheme.secondary.withOpacity(0.6),
            ),
            columns: columns,
            rows: rows,
          ),
        ),
      ],
    );
  }
}
