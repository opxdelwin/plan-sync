import 'package:flutter/material.dart';
import 'package:plan_sync/features/attendance/viewmodel/attendance_view_model.dart';

/// Sits above the attendance list whenever what's on screen isn't live data:
/// a saved copy restored from the cache, or one being refreshed.
class AttendanceCacheBanner extends StatefulWidget {
  const AttendanceCacheBanner({super.key, required this.viewModel});
  final AttendanceViewModel viewModel;

  @override
  State<AttendanceCacheBanner> createState() => _AttendanceCacheBannerState();
}

class _AttendanceCacheBannerState extends State<AttendanceCacheBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void didUpdateWidget(AttendanceCacheBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSpin();
  }

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _syncSpin();
  }

  /// The icon only spins while a refresh is actually in flight.
  void _syncSpin() {
    if (widget.viewModel.isRefreshing) {
      if (!_spin.isAnimating) _spin.repeat();
    } else if (_spin.isAnimating) {
      _spin
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final refreshing = vm.isRefreshing;
    // Nothing to say once live data is on screen.
    if (!refreshing && !vm.loadedFromCache) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final accent = refreshing ? colorScheme.primary : colorScheme.tertiary;
    final hours = vm.freshnessWindow.inHours;

    final title = refreshing
        ? 'Updating from the KIIT portal…'
        : vm.resultIsStale
            ? 'Saved copy · out of date'
            : 'Saved copy';
    final subtitle = refreshing
        ? 'Your saved copy stays on screen until the new one lands.'
        : vm.resultIsStale
            ? 'This is older than $hours hours. Refresh for current numbers.'
            : 'Loaded from this device. Refreshes itself after $hours hours.';

    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            RotationTransition(
              turns: _spin,
              child: Icon(
                refreshing ? Icons.sync_rounded : Icons.offline_pin_outlined,
                size: 20,
                color: accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.62),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (!refreshing)
              TextButton(
                onPressed: vm.refresh,
                style: TextButton.styleFrom(
                  foregroundColor: accent,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Refresh'),
              ),
          ],
        ),
      ),
    );
  }
}
