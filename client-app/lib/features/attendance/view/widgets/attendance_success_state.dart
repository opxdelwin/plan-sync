import 'package:flutter/material.dart';
import 'package:plan_sync/features/attendance/view/widgets/attendance_actions_row.dart';
import 'package:plan_sync/features/attendance/view/widgets/attendance_cache_banner.dart';
import 'package:plan_sync/features/attendance/view/widgets/attendance_inline_notice.dart';
import 'package:plan_sync/features/attendance/view/widgets/overall_attendance_card.dart';
import 'package:plan_sync/features/attendance/view/widgets/subject_attendance_tile.dart';
import 'package:plan_sync/features/attendance/viewmodel/attendance_view_model.dart';
import 'package:plan_sync/widgets/animations/fade_slide_in.dart';

class AttendanceSuccessState extends StatelessWidget {
  const AttendanceSuccessState({super.key, required this.viewModel});
  final AttendanceViewModel viewModel;

  String _formatFetchedAt(DateTime dt) {
    final now = DateTime.now();
    final hour = dt.hour > 12
        ? dt.hour - 12
        : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final time = '$hour:$minute $period';

    final sameDay = now.year == dt.year &&
        now.month == dt.month &&
        now.day == dt.day;
    if (sameDay) return 'Last updated at $time';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'Last updated ${dt.day} ${months[dt.month - 1]}, $time';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final result = viewModel.result!;

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
        children: [
          AttendanceCacheBanner(viewModel: viewModel),
          FadeSlideIn(child: OverallAttendanceCard(result: result)),
          const SizedBox(height: 20),
          FadeSlideIn(
            delay: const Duration(milliseconds: 60),
            child: AttendanceActionsRow(viewModel: viewModel),
          ),
          const SizedBox(height: 4),
          Text(
            _formatFetchedAt(result.fetchedAt),
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          if (result.isEmpty)
            AttendanceInlineNotice(
              icon: Icons.inbox_outlined,
              text: 'No subjects found for ${result.academicYear} '
                  '· ${result.session}.',
            )
          else
            ...result.records.indexed.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                // Cascade the tiles in; cap the stagger so a long list doesn't
                // leave the last rows waiting.
                child: FadeSlideIn(
                  delay: Duration(
                    milliseconds: 120 + (entry.$1.clamp(0, 8) * 55),
                  ),
                  child: SubjectAttendanceTile(record: entry.$2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
