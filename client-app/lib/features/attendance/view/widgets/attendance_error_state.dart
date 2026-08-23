import 'package:flutter/material.dart';
import 'package:plan_sync/features/attendance/model/scrape_exception.dart';
import 'package:plan_sync/features/attendance/view/widgets/attendance_error_config.dart';
import 'package:plan_sync/features/attendance/view/widgets/attendance_fix_it_steps.dart';
import 'package:plan_sync/features/attendance/view/widgets/attendance_report_disclosure.dart';
import 'package:plan_sync/features/attendance/viewmodel/attendance_view_model.dart';
import 'package:plan_sync/widgets/animations/fade_slide_in.dart';
import 'package:plan_sync/widgets/popups/popups_wrapper.dart';

/// Full-screen failure view: what went wrong, what to try, and a retry.
class AttendanceErrorState extends StatefulWidget {
  const AttendanceErrorState({super.key, required this.viewModel});

  final AttendanceViewModel viewModel;

  @override
  State<AttendanceErrorState> createState() => _AttendanceErrorStateState();
}

class _AttendanceErrorStateState extends State<AttendanceErrorState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop;

  /// Acknowledges the tap in the same frame; the view model switches to the
  /// loading screen a frame later.
  bool _retrying = false;

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  Future<void> _retry() async {
    setState(() => _retrying = true);
    try {
      await widget.viewModel.refresh();
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final kind = widget.viewModel.errorKind ?? ScrapeErrorKind.unknown;
    final config = AttendanceErrorConfig.forKind(
      kind,
      colorScheme,
      fallbackMessage: widget.viewModel.errorMessage,
    );
    final accent = config.accent;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 120),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeSlideIn(
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.78, end: 1.0).animate(
                  CurvedAnimation(parent: _pop, curve: Curves.elasticOut),
                ),
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.12),
                  ),
                  child: Icon(config.icon, size: 48, color: accent),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeSlideIn(
              delay: const Duration(milliseconds: 80),
              child: Text(
                config.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeSlideIn(
              delay: const Duration(milliseconds: 160),
              child: Text(
                config.body,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeSlideIn(
              delay: const Duration(milliseconds: 200),
              child: AttendanceFixItSteps(
                steps: config.steps,
                accent: accent,
              ),
            ),
            const SizedBox(height: 24),
            FadeSlideIn(
              delay: const Duration(milliseconds: 240),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  FilledButton.icon(
                    onPressed: _retrying ? null : _retry,
                    icon: _retrying
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.refresh_rounded),
                    label: Text(_retrying ? 'Trying…' : config.retryLabel),
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: colorScheme.onPrimary,
                      disabledBackgroundColor: accent.withValues(alpha: 0.5),
                      disabledForegroundColor:
                          colorScheme.onPrimary.withValues(alpha: 0.8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  if (widget.viewModel.canReportIssue)
                    AttendanceReportDisclosure(
                      onReport: () =>
                          PopupsWrapper.reportAttendanceIssue(context: context),
                    ),
                ],
              ),
            ),
            if (widget.viewModel.consecutiveFailures > 1)
              FadeSlideIn(
                delay: const Duration(milliseconds: 280),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Failed ${widget.viewModel.consecutiveFailures} times in '
                    'a row.',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.45),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            // The wrong year/session is the usual cause, not a real failure.
            if (kind == ScrapeErrorKind.noData)
              FadeSlideIn(
                delay: const Duration(milliseconds: 320),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton.icon(
                    onPressed: widget.viewModel.chooseAnotherPeriod,
                    icon: const Icon(Icons.event_repeat_outlined),
                    label: const Text('Change year & session'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
