import 'package:flutter/material.dart';
import 'package:plan_sync/features/attendance/model/scrape_exception.dart';

/// What the failure screen shows for one [ScrapeErrorKind].
class AttendanceErrorConfig {
  const AttendanceErrorConfig({
    required this.icon,
    required this.title,
    required this.body,
    required this.retryLabel,
    required this.accent,
    this.extraSteps = const [],
  });

  final IconData icon;
  final String title;
  final String body;
  final String retryLabel;
  final Color accent;

  /// Failure-specific things to try, shown above the retry button.
  final List<String> extraSteps;

  /// The headless browser and the portal session live as long as the app does,
  /// so a restart clears state no retry can — every failure ends with it.
  List<String> get steps => [
        ...extraSteps,
        'Still stuck? Close Plan Sync completely and open it again.',
      ];

  factory AttendanceErrorConfig.forKind(
    ScrapeErrorKind kind,
    ColorScheme colors, {
    String? fallbackMessage,
  }) {
    switch (kind) {
      case ScrapeErrorKind.networkUnavailable:
        return AttendanceErrorConfig(
          icon: Icons.wifi_off_rounded,
          title: 'You\'re offline',
          body: 'We couldn\'t reach the internet, so the KIIT portal was never '
              'contacted.',
          retryLabel: 'Retry',
          accent: colors.error,
          extraSteps: const [
            'Turn Wi-Fi or mobile data back on, or step out of aeroplane mode.',
            'On campus Wi-Fi, open any website once to clear the login page.',
          ],
        );
      case ScrapeErrorKind.timeout:
        return AttendanceErrorConfig(
          icon: Icons.hourglass_empty_rounded,
          title: 'This took too long',
          body: 'The KIIT portal was slow to respond and we stopped waiting. '
              'This is usually temporary.',
          retryLabel: 'Try again',
          accent: colors.tertiary,
          extraSteps: const [
            'Check your connection is stable — a weak signal stalls the portal.',
            'Wait a minute before retrying; the portal is slowest at peak hours.',
          ],
        );
      case ScrapeErrorKind.portalUnavailable:
        return AttendanceErrorConfig(
          icon: Icons.cloud_off_rounded,
          title: 'Portal is down',
          body: 'The KIIT portal isn\'t serving pages right now. This one is on '
              'their side, not yours.',
          retryLabel: 'Try again',
          accent: colors.tertiary,
          extraSteps: const [
            'Open kiitportal.kiituniversity.net in a browser — if it fails '
                'there too, the portal is down for everyone.',
            'Give it a few minutes before retrying.',
          ],
        );
      case ScrapeErrorKind.navigationFailed:
        return AttendanceErrorConfig(
          icon: Icons.explore_off_rounded,
          title: 'Couldn\'t open attendance',
          body: 'We signed in, but the attendance page never finished loading.',
          retryLabel: 'Try again',
          accent: colors.primary,
          extraSteps: const [
            'Retry once — the portal often serves the page on a second attempt.',
            'Check the portal isn\'t asking you to change your password.',
          ],
        );
      case ScrapeErrorKind.rendererCrashed:
        return AttendanceErrorConfig(
          icon: Icons.memory_rounded,
          title: 'In-app browser crashed',
          body: 'The browser we use to read the portal ran out of memory.',
          retryLabel: 'Try again',
          accent: colors.error,
          extraSteps: const [
            'Close a few background apps to free up memory, then retry.',
          ],
        );
      case ScrapeErrorKind.noData:
        return AttendanceErrorConfig(
          icon: Icons.event_busy_rounded,
          title: 'No attendance found',
          body: 'There\'s nothing recorded for the selected term.',
          retryLabel: 'Try again',
          accent: colors.primary,
          extraSteps: const [
            'Check the year and session below — Autumn and Spring are stored '
                'separately.',
            'Early in a semester the portal may not publish attendance yet.',
          ],
        );
      case ScrapeErrorKind.columnsChanged:
        return AttendanceErrorConfig(
          icon: Icons.view_column_outlined,
          title: 'Attendance table changed',
          body: fallbackMessage ??
              'Your attendance table on the portal is missing columns we need '
                  'to read it.',
          retryLabel: 'Try again',
          accent: colors.tertiary,
          extraSteps: const [
            'Open Student Attendance Details on the KIIT portal in a browser.',
            'Right-click the table header, open Settings, and restore the '
                'hidden columns (Subject, Absent, Present, Total Days).',
            'Save that layout as the default, then retry here.',
          ],
        );
      case ScrapeErrorKind.invalidCredentials:
      case ScrapeErrorKind.unknown:
        return AttendanceErrorConfig(
          icon: Icons.error_outline_rounded,
          title: 'Something went wrong',
          body: fallbackMessage ??
              'We hit an unexpected snag fetching your attendance.',
          retryLabel: 'Try again',
          accent: colors.error,
          extraSteps: const [
            'Retry once — most of these clear on a second attempt.',
            'Check your connection, then retry.',
          ],
        );
    }
  }
}
