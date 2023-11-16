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

  ExternalLinks.reportError() {
    _launchUrl(
        "https://github.com/opxdelwin/plan-sync/blob/main/ERROR_REPORTING.md");
  }

  ExternalLinks.contributeTimeTable() {
    _launchUrl(
        "https://github.com/opxdelwin/plan-sync/blob/main/CONTRIBUTING.md");
  }

  ExternalLinks.shareApp() {
    Share.shareUri(Uri.parse("https://github.com/opxdelwin/plan-sync"));
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}
