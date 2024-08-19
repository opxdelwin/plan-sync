import 'dart:io';

import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class ExternalLinks {
  static const appLink = "https://plansync.in";

  ExternalLinks.cardlink() {
    _launchUrl("https://cardlink.co.in");
  }

  ExternalLinks.store() {
    if (Platform.isAndroid) {
      _launchUrl(
        "https://play.google.com/store/apps/details?id=in.co.cardlink.plansync",
      );
      return;
    } else if (Platform.isIOS) {
      // TODO: update store link
      _launchUrl(
        "https://play.google.com/store/apps/details?id=in.co.cardlink.plansync",
      );
      return;
    }
  }

  ExternalLinks.termsAndConditions() {
    _launchUrl("https://plansync.in/terms-of-service");
  }

  ExternalLinks.privacyPolicy() {
    _launchUrl("https://plansync.in/privacy-policy");
  }

  /// TODO: Disabled, as repo is private
  ExternalLinks.reportErrorViaGithub() {
    _launchUrl(
        "https://github.com/opxdelwin/plan-sync/blob/main/ERROR_REPORTING.md");
  }

  ExternalLinks.reportErrorViaMail({
    String? academicYear,
    String? course,
    String? section,
  }) {
    String body = """Hey Plan Sync Team,

I hope this message finds you well. I've come across an issue in the schedule and wanted to report it to help improve the app. Here are the details:

**Class Details:**
- Academic Year: ${academicYear ?? '[Enter Academic Year]'}
- Course Name: ${course ?? '[Enter Course Name]'}
- Type: Normal Schedule / Electives
- Section: ${section ?? '[Enter Section]'}
- Day/Time: [Enter Day and/or Time]

ISSUE DESCRIPTION:
[Describe the issue concisely and clearly. Include any relevant details.]

**Screenshots (if applicable):**
[Attach screenshots to illustrate the problem, if possible.]

**Additional Comments:**
[Include any additional comments or information that might be helpful.]

Thanks for your attention to this matter. Your commitment to enhancing Plan Sync is truly appreciated.

Best regards,
[Your Name]
""";

    final subject = Uri.encodeComponent("[Schedule Error Report] - Plan Sync");
    final email = Uri.encodeComponent("connect@plansync.in");
    _launchUrl(
      'mailto:$email?subject=$subject&body=${Uri.encodeComponent(body)}',
    );
  }

  ExternalLinks.contributeTimeTableViaMail() {
    const body = """Hey Plan Sync Team,

I hope this email finds you well. I'm interested in contributing a new timetable for a specific section. Here are my details:

**Personal Information:**
- Full Name: [Your Full Name]
- College/University: [Name of your College/University]
- Section I Want to Contribute to: [Enter Section]
- Contact Details: (optional, for faster communication)

**Additional Comments:**
[Include any additional comments or information that might be helpful.]

I'm excited about the opportunity to contribute to Plan Sync and help fellow students. Please let me know the next steps or if there's any specific format you'd like me to follow.

Looking forward to being part of the Plan Sync community!

Best regards,
[Your Name]
""";

    final subject = Uri.encodeComponent("[Contribution Interest] - Plan Sync");
    final email = Uri.encodeComponent("connect@plansync.in");
    _launchUrl(
      'mailto:$email?subject=$subject&body=${Uri.encodeComponent(body)}',
    );
  }

  ExternalLinks.contributeTimeTableViaGithub() {
    _launchUrl(
        "https://github.com/opxdelwin/plan-sync/blob/main/CONTRIBUTING.md");
  }

  ExternalLinks.shareApp() {
    var text = "Check out the Plan Sync app! "
        "🚀 It's a game-changer for managing my classes. "
        "Makes life so much easier.";

    text += "\n\nGive it a try: https://plansync.in/#download";
    Share.share(text);
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}
