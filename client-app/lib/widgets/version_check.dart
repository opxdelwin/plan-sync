import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/version_controller.dart';

class VersionCheckWidget extends StatefulWidget {
  const VersionCheckWidget({super.key});

  @override
  State<VersionCheckWidget> createState() => _VersionCheckWidgetState();
}

class _VersionCheckWidgetState extends State<VersionCheckWidget> {
  bool isLatest = true;

  late VersionController versionController;

  @override
  void initState() {
    super.initState();
    versionController = Get.find();
    checkVersionIfUpdate();
  }

  checkVersionIfUpdate() async {
    final updateAvailable = await versionController.checkForUpdate();
    setState(() {
      isLatest = !updateAvailable;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return isLatest
        ? const SizedBox()
        : Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.only(
              top: 16,
              bottom: 8,
              right: 16,
              left: 16,
            ),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: Get.isDarkMode
                    ? BorderSide.none
                    : BorderSide(
                        color: colorScheme.onSurfaceVariant,
                      ),
              ),
              color: Get.isDarkMode
                  ? colorScheme.surface
                  : colorScheme.surfaceContainerHighest,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ListTile(
                  title: Text(
                    "Update Available",
                    style: TextStyle(
                        color: Get.isDarkMode
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant),
                  ),
                  subtitle: Text(
                    "A new version of Plan Sync is available "
                    "with bug fixes and performance improvements. Tap to download and install.",
                    style: TextStyle(
                        color: Get.isDarkMode
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant),
                  ),
                  contentPadding: const EdgeInsets.all(0),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage(
                      'assets/favicon.png',
                    ),
                  ),
                ),
                FilledButton(
                  style: ButtonStyle(
                      elevation: const WidgetStatePropertyAll(0.0),
                      backgroundColor:
                          WidgetStatePropertyAll(colorScheme.secondary),
                      foregroundColor:
                          WidgetStatePropertyAll(colorScheme.onSecondary),
                      shape: const WidgetStatePropertyAll(StadiumBorder())),
                  onPressed: () => versionController.openStore(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.download_rounded),
                      const SizedBox(width: 8),
                      Text('Download')
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
