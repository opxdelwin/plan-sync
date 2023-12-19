import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/util/constants.dart';
import 'package:plan_sync/util/external_links.dart';
import 'package:plan_sync/widgets/section_preferences_bottom_sheet.dart';
import '../controllers/auth.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  //TODO: implement
  void setPrimarySections(BuildContext context) {
    BottomSheets.changeSectionPreference(context: context, save: true);
  }

  @override
  Widget build(BuildContext context) {
    Auth auth = Get.find();
    FilterController filterController = Get.find();
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
                  auth.activeUser!.email ?? "example@gmail.com",
                  style: TextStyle(
                    color: colorScheme.onBackground.withOpacity(0.6),
                  ),
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
                  onTap: () => ExternalLinks.reportError(),
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
                  onTap: () => ExternalLinks.contributeTimeTable(),
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
                ElevatedButton.icon(
                  style: ButtonStyle(
                    elevation: const MaterialStatePropertyAll(0.0),
                    backgroundColor:
                        MaterialStatePropertyAll(colorScheme.error),
                  ),
                  onPressed: () => auth.logout(),
                  icon: Icon(Icons.logout, color: colorScheme.onError),
                  label: Text(
                    "Logout",
                    style: TextStyle(color: colorScheme.onError),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ));
  }
}
