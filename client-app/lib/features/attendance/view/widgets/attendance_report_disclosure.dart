import 'package:flutter/material.dart';

/// Keeps "Report issue" two taps away: the user first has to say the retries
/// didn't help, which is also the point where a report is useful.
class AttendanceReportDisclosure extends StatefulWidget {
  const AttendanceReportDisclosure({super.key, required this.onReport});

  final VoidCallback onReport;

  @override
  State<AttendanceReportDisclosure> createState() =>
      _AttendanceReportDisclosureState();
}

class _AttendanceReportDisclosureState
    extends State<AttendanceReportDisclosure> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final muted = colorScheme.onSurface.withValues(alpha: 0.5);

    return AnimatedSize(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      alignment: Alignment.centerLeft,
      child: _open
          ? TextButton.icon(
              onPressed: widget.onReport,
              icon: const Icon(Icons.mail_outline_rounded, size: 16),
              label: const Text('Report issue', style: TextStyle(fontSize: 13)),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.error,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            )
          : TextButton(
              onPressed: () => setState(() => _open = true),
              style: TextButton.styleFrom(
                foregroundColor: muted,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text(
                'Tried everything?',
                style: TextStyle(fontSize: 12),
              ),
            ),
    );
  }
}
