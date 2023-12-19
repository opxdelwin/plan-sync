import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class ExternalLinks {
  static const appLink = "https://github.com/opxdelwin/plan-sync";

  ExternalLinks.cardlink() {
    _launchUrl("https://cardlink.co.in");
  }

  ExternalLinks.updateApp() {
    _launchUrl('https://github.com/opxdelwin/plan-sync/releases/latest');
  }

  ExternalLinks.termsAndConditions() {
    _launchUrl("https://github.com/opxdelwin/plan-sync/blob/main/TERMS.md");
  }

  ExternalLinks.privacyPolicy() {
    _launchUrl(
        "https://github.com/opxdelwin/plan-sync/blob/main/PRIVACY-POLICY.md");
  }

  ExternalLinks.reportErrorViaGithub() {
    _launchUrl(
        "https://github.com/opxdelwin/plan-sync/blob/main/ERROR_REPORTING.md");
  }

  ExternalLinks.reportErrorViaMail() {
    const body = """Hey Plan Sync Team,

I hope this message finds you well. I've come across an issue in the schedule and wanted to report it to help improve the app. Here are the details:

**Class Details:**
- Course Name: [Enter Course Name]
- Type: Normal Schedule / Electives
- Section: [Enter Section]
- Day/Time: [Enter Day and/or Time]

**Issue Description:**
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
    final email = Uri.encodeComponent("connect.plansync@gmail.com");
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
    final email = Uri.encodeComponent("connect.plansync@gmail.com");
    _launchUrl(
      'mailto:$email?subject=$subject&body=${Uri.encodeComponent(body)}',
    );
  }

  ExternalLinks.contributeTimeTableViaGithub() {
    _launchUrl(
        "https://github.com/opxdelwin/plan-sync/blob/main/CONTRIBUTING.md");
  }

  ExternalLinks.shareApp() {
    Share.shareUri(Uri.parse("https://github.com/opxdelwin/plan-sync"));
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}
