import 'package:flutter/material.dart';
import 'package:plan_sync/backend/models/timetable.dart';
import 'package:plan_sync/util/extensions.dart';
import 'package:plan_sync/widgets/no_schedule_widget.dart';
import 'package:plan_sync/widgets/indicators/schedule_freshness_indicator.dart';
import 'package:plan_sync/widgets/subject_tile.dart';

class TimeTableForDay extends StatefulWidget {
  const TimeTableForDay(
      {super.key,
      required this.data,
      required this.day,
      this.searchEnabled = false});

  final Timetable data;
  final String day;
  final bool searchEnabled;

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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _getFilteredSchedule() {
    final scheduleData = widget.data.data[widget.day];
    if (scheduleData == null || !widget.searchEnabled || _searchQuery.isEmpty) {
      return scheduleData ?? [];
    }

    // Split search query into keywords by space and remove empty strings
    final searchKeywords = _searchQuery
        .split(' ')
        .map((keyword) => keyword.trim().toLowerCase())
        .where((keyword) => keyword.isNotEmpty)
        .toList();

    if (searchKeywords.isEmpty) {
      return scheduleData;
    }

    return scheduleData.where((entry) {
      final subject = entry.subject?.toLowerCase() ?? '';

      // Normalize subject by replacing common separators with spaces
      final normalizedSubject = subject
          .replaceAll(RegExp(r'[_\-]'), ' ')
          .replaceAll(
              RegExp(r'\s+'), ' '); // Replace multiple spaces with single space

      // Check if ALL keywords match ANY part of the normalized subject
      return searchKeywords
          .every((keyword) => normalizedSubject.contains(keyword));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return _buildForTimetable(colorScheme);
  }

  Widget _buildForTimetable(ColorScheme colorScheme) {
    final filteredSchedule = _getFilteredSchedule();

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
                widget.day.capitalizeFirst(),
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.24,
                ),
              ),
              const Spacer(),
              ScheduleFreshnessIndicator(
                isFresh: widget.data.isFresh,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Search bar (only show if search is enabled)
        if (widget.searchEnabled) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search subjects...',
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.outline,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.outline,
                    width: 1.0,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.onSurfaceVariant,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Show filtered results or no results message
        if (filteredSchedule.isEmpty &&
            widget.searchEnabled &&
            _searchQuery.isNotEmpty)
          _buildNoSearchResults(colorScheme)
        else
          ListView.separated(
            key: const ValueKey('TimeTableForDay._buildForTimetable'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => SubjectTile(
              location: filteredSchedule[index].room ?? 'Unavailable',
              time: filteredSchedule[index].time ?? 'Unavailable',
              subject: filteredSchedule[index].subject ?? 'Unavailable',
            ),
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemCount: filteredSchedule.length,
          ),
      ],
    );
  }

  Widget _buildNoSearchResults(ColorScheme colorScheme) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
          const SizedBox(height: 8),
          Text(
            'No classes found',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try searching with different keywords',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
