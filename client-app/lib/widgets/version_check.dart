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
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              color: colorScheme.primary,
            ),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            margin: const EdgeInsets.only(top: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "Update Available",
                  style: TextStyle(color: colorScheme.onPrimary),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  style: ButtonStyle(
                      elevation: const WidgetStatePropertyAll(0.0),
                      backgroundColor:
                          WidgetStatePropertyAll(colorScheme.secondary),
                      foregroundColor:
                          WidgetStatePropertyAll(colorScheme.onSecondary),
                      shape: const WidgetStatePropertyAll(StadiumBorder())),
                  onPressed: () => versionController.openStore(),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text("Update Now"),
                )
              ],
            ),
          );
  }
}
