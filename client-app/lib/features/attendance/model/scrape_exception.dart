/// The category of a failure while scraping the KIIT portal.
///
/// The UI uses this to decide whether to prompt for re-login, show a retry, or
/// surface a "portal is down" message.
enum ScrapeErrorKind {
  /// Registration number / password rejected by the portal.
  invalidCredentials,

  /// The portal kept returning HTTP 500 / never served the login form.
  portalUnavailable,

  /// Logged in, but the Student Self Service tree / attendance link could not
  /// be reached.
  navigationFailed,

  /// Reached the attendance form but no attendance rows were produced (e.g. no
  /// records for the chosen year + session).
  noData,

  /// The attendance table's columns no longer match what the portal normally
  /// sends — a column was removed or renamed in the user's own SAP layout.
  columnsChanged,

  /// A network stall / overall timeout.
  timeout,

  /// No internet connection (offline at start, or connection dropped mid-fetch).
  networkUnavailable,

  /// The WebView renderer process was killed (OOM / GPU) mid-scrape.
  rendererCrashed,

  /// Anything we didn't classify.
  unknown;

  static ScrapeErrorKind fromKey(String? key) {
    return ScrapeErrorKind.values.firstWhere(
      (e) => e.name == key,
      orElse: () => ScrapeErrorKind.unknown,
    );
  }
}

class ScrapeException implements Exception {
  final ScrapeErrorKind kind;
  final String message;

  const ScrapeException(this.kind, this.message);

  /// A short, user-facing title for the error screen.
  String get title {
    switch (kind) {
      case ScrapeErrorKind.invalidCredentials:
        return 'Incorrect credentials';
      case ScrapeErrorKind.portalUnavailable:
        return 'Portal unavailable';
      case ScrapeErrorKind.navigationFailed:
        return "Couldn't open attendance";
      case ScrapeErrorKind.noData:
        return 'No attendance found';
      case ScrapeErrorKind.columnsChanged:
        return 'Attendance table changed';
      case ScrapeErrorKind.timeout:
        return 'Request timed out';
      case ScrapeErrorKind.networkUnavailable:
        return 'No internet connection';
      case ScrapeErrorKind.rendererCrashed:
        return 'In-app browser crashed';
      case ScrapeErrorKind.unknown:
        return 'Something went wrong';
    }
  }

  @override
  String toString() => 'ScrapeException(${kind.name}): $message';
}
