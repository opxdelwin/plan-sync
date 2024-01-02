import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:plan_sync/controllers/version_controller.dart';
import 'package:plan_sync/util/constants.dart';
import 'package:plan_sync/util/external_links.dart';
import 'package:plan_sync/util/snackbar.dart';
import 'package:plan_sync/widgets/bottom-sheets/bottom_sheets_wrapper.dart';
import 'package:plan_sync/widgets/buttons/logout_button.dart';
import '../controllers/auth.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void setPrimarySections(BuildContext context) {
    BottomSheets.changeSectionPreference(context: context, save: true);
  }

  void copyUID() async {
    Auth auth = Get.find();
    final uid = auth.activeUser?.uid;

    if (uid == null) {
      CustomSnackbar.error('Error', 'No UID found. Please Login again.');
      return;
    }

    await Clipboard.setData(ClipboardData(text: uid));
    CustomSnackbar.info(
      'Copied',
      'Your UID has been copied into the clipboard.',
    );
    return;
  }

  @override
  Widget build(BuildContext context) {
    Auth auth = Get.find();
    VersionController versionController = Get.find();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: colorScheme.background,
          elevation: 0.0,
          toolbarHeight: 80,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(32),
          )),
          title: Text(
            "Account",
            style: TextStyle(
              color: colorScheme.onBackground,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 64,
                  backgroundImage: CachedNetworkImageProvider(
                    auth.activeUser!.photoURL ?? DEFAULT_USER_IMAGE,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  auth.activeUser!.displayName ?? "username",
                  style: TextStyle(
                    color: colorScheme.onBackground,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  auth.activeUser!.email ?? "connect.plansync@gmail.com",
                  style: TextStyle(
                    color: colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Plan Sync ${versionController.appVersion}+${versionController.appBuild} | ',
                      style: TextStyle(
                        color: colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      'Copy UID',
                      style: TextStyle(
                        color: colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: copyUID,
                      enableFeedback: true,
                      child: Icon(
                        Icons.copy,
                        size: 18,
                        color: colorScheme.onBackground,
                        semanticLabel: 'Copy',
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enableFeedback: true,
                  tileColor: colorScheme.primary,
                  leading: Icon(
                    Icons.downloading_rounded,
                    color: colorScheme.onPrimary,
                  ),
                  title: Text(
                    "Set Primary Sections",
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  trailing: Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: colorScheme.onPrimary,
                  ),
                  onTap: () => setPrimarySections(context),
                ),
                const SizedBox(height: 8),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enableFeedback: true,
                  tileColor: colorScheme.primary,
                  leading: Icon(
                    Icons.report,
                    color: colorScheme.onPrimary,
                  ),
                  title: Text(
                    "Report an error",
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  trailing: Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: colorScheme.onPrimary,
                  ),
                  onTap: () => BottomSheets.reportError(
                    context: context,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enableFeedback: true,
                  tileColor: colorScheme.primary,
                  leading: Icon(Icons.share, color: colorScheme.onPrimary),
                  title: Text(
                    "Share This App",
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  trailing: Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: colorScheme.onPrimary,
                  ),
                  onTap: () => ExternalLinks.shareApp(),
                ),
                const SizedBox(height: 8),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enableFeedback: true,
                  tileColor: colorScheme.primary,
                  leading: Icon(
                    Icons.add_circle_outline_rounded,
                    color: colorScheme.onPrimary,
                  ),
                  title: Text(
                    "Contribute Time Table",
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  trailing: Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: colorScheme.onPrimary,
                  ),
                  onTap: () => BottomSheets.contributeTimeTable(
                    context: context,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enableFeedback: true,
                  tileColor: colorScheme.primary,
                  leading: Icon(
                    FontAwesomeIcons.fileLines,
                    color: colorScheme.onPrimary,
                  ),
                  title: Text(
                    "Terms of Service",
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  trailing: Icon(Icons.keyboard_arrow_right_rounded,
                      color: colorScheme.onPrimary),
                  onTap: () => ExternalLinks.termsAndConditions(),
                ),
                const SizedBox(height: 8),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enableFeedback: true,
                  tileColor: colorScheme.primary,
                  leading: Icon(
                    Icons.security_rounded,
                    color: colorScheme.onPrimary,
                  ),
                  title: Text(
                    "Privacy Policy",
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  trailing: Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: colorScheme.onPrimary,
                  ),
                  onTap: () => ExternalLinks.privacyPolicy(),
                ),
                const SizedBox(height: 32),
                const LogoutButton(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ));
  }
}
