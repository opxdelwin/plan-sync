import 'package:flutter/material.dart';
import 'package:plan_sync/backend/models/timetable_schedule_entry.dart';
import 'package:plan_sync/controllers/app_preferences_controller.dart';

class SubjectTile extends StatelessWidget {
  const SubjectTile({
    super.key,
    required this.entry,
    required this.academicYear,
    required this.semester,
    required this.scheme,
    this.showStar = false,
    required this.starred,
    required this.onStarToggle,
  });

  final ScheduleEntry entry;
  final String academicYear;
  final String semester;
  final String scheme;
  final bool showStar;
  final bool starred;
  final Function(bool)? onStarToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final id = AppPreferencesController.electiveId(
      academicYear: academicYear,
      semester: semester,
      scheme: scheme,
      subjectName: entry.subject ?? '',
    );

    return Card(
      key: ValueKey('subject-star0tile-$id'),
      elevation: 2.0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          strokeAlign: 2.0,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (showStar) ...[
                        Tooltip(
                          message: 'Toggle Quick Access',
                          enableFeedback: true,
                          textStyle: TextStyle(
                            color: colorScheme.onPrimary,
                          ),
                          decoration: ShapeDecoration(
                            color: colorScheme.primary,
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: colorScheme.primary,
                                width: 1.2,
                              ),
                            ),
                          ),
                          child: GestureDetector(
                            onTap: onStarToggle == null
                                ? null
                                : () {
                                    onStarToggle?.call(!starred);
                                  },
                            child: Icon(
                              key: ValueKey('star-icon$id'),
                              starred
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: starred
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant
                                      .withOpacity(0.4),
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          entry.subject ?? 'Unavailable',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: colorScheme.onSurfaceVariant,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.room ?? 'Unavailable',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Text(
              entry.time ?? 'Unavailable',
              style: TextStyle(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
