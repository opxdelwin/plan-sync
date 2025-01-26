import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:plan_sync/controllers/analytics_controller.dart';
import 'package:plan_sync/controllers/version_controller.dart';
import 'package:plan_sync/util/constants.dart';
import 'package:plan_sync/util/external_links.dart';
import 'package:plan_sync/util/snackbar.dart';
import 'package:plan_sync/widgets/bottom-sheets/bottom_sheets_wrapper.dart';
import 'package:plan_sync/widgets/buttons/logout_button.dart';
import 'package:plan_sync/widgets/popups/popups_wrapper.dart';
import 'package:provider/provider.dart';
import '../controllers/auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void setPrimarySections(BuildContext context) {
    BottomSheets.changeSectionPreference(context: context, save: true);
  }

  late Auth auth;
  late VersionController versionController;
  bool isPunActivated = false;

  @override
  void initState() {
    super.initState();
    auth = Provider.of<Auth>(context, listen: false);
    versionController = Provider.of<VersionController>(context, listen: false);
  }

  void copyUID(BuildContext context) async {
    final uid = auth.activeUser?.uid;

    if (uid == null) {
      CustomSnackbar.error(
        'Error',
        'No UID found. Please Login again.',
        context,
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: uid));
    CustomSnackbar.info(
      'Copied',
      'Your UID has been copied into the clipboard.',
      context,
    );
    return;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final userImage = CachedNetworkImageProvider(
      auth.activeUser?.photoURL ?? DEFAULT_USER_IMAGE,
      cacheKey: auth.activeUser?.uid ?? 'DEFAULT_USER_IMAGE',
    );

    const chillGuyImage = CachedNetworkImageProvider(
      CHILL_GUY_IMAGE,
      cacheKey: 'CHILL_GUY_IMAGE',
    );

    return Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.surfaceContainerHighest,
          elevation: 0.0,
          toolbarHeight: 80,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(32),
          )),
          title: Text(
            "Account",
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          actions: const [
            LogoutButton(),
            SizedBox(width: 16),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // TODO: maybe remove this pun?
                GestureDetector(
                  onLongPress: () => setState(() {
                    isPunActivated = !isPunActivated;
                  }),
                  child: CircleAvatar(
                    radius: 64,
                    // main image
                    foregroundImage: isPunActivated ? chillGuyImage : userImage,
                    // fallback image
                    backgroundImage: const AssetImage('assets/favicon.png'),
                    backgroundColor: colorScheme.surface,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  auth.activeUser!.displayName ?? "Plan Sync Wizard",
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  auth.activeUser!.email ?? "connect@plansync.in",
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.72),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Plan Sync v${versionController.clientVersion} | ',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.72),
                      ),
                    ),
                    Text(
                      'Copy UID',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.72),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => copyUID(context),
                      enableFeedback: true,
                      child: Icon(
                        Icons.copy,
                        size: 18,
                        color: colorScheme.onSurface,
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
                  leading: Icon(
                    Icons.downloading_rounded,
                    color: colorScheme.onSurface,
                  ),
                  title: Text(
                    "Set Primary Sections",
                    style: TextStyle(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  trailing: Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: colorScheme.onSurface,
                  ),
                  onTap: () => setPrimarySections(context),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enableFeedback: true,
                  leading: Icon(
                    Icons.report,
                    color: colorScheme.onSurface,
                  ),
                  title: Text(
                    "Report an error",
                    style: TextStyle(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  trailing: Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: colorScheme.onSurface,
                  ),
                  onTap: () => PopupsWrapper.reportError(
                    autoFill: false,
                    context: context,
                  ),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enableFeedback: true,
                  leading: Icon(Icons.share, color: colorScheme.onSurface),
                  title: Text(
                    "Share This App",
                    style: TextStyle(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  trailing: Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: colorScheme.onSurface,
                  ),
                  onTap: () {
                    BottomSheets.shareAppBottomSheet(
                      context: context,
                    );

                    Provider.of<AnalyticsController>(
                      context,
                      listen: false,
                    ).logShareSheetOpen();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Divider(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.48),
                  ),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enableFeedback: true,
                  leading: Icon(
                    FontAwesomeIcons.fileLines,
                    color: colorScheme.onSurface,
                  ),
                  title: Text(
                    "Terms of Service",
                    style: TextStyle(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  trailing: Icon(Icons.keyboard_arrow_right_rounded,
                      color: colorScheme.onSurface),
                  onTap: () => ExternalLinks.termsAndConditions(),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enableFeedback: true,
                  leading: Icon(
                    Icons.security_rounded,
                    color: colorScheme.onSurface,
                  ),
                  title: Text(
                    "Privacy Policy",
                    style: TextStyle(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  trailing: Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: colorScheme.onSurface,
                  ),
                  onTap: () => ExternalLinks.privacyPolicy(),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enableFeedback: true,
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    color: colorScheme.error,
                  ),
                  title: Text(
                    "Delete your account",
                    style: TextStyle(
                      color: colorScheme.error,
                    ),
                  ),
                  trailing: Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: colorScheme.error,
                  ),
                  onTap: () => PopupsWrapper.deleteAccount(
                    context: context,
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ));
  }
}
