import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:plan_sync/controllers/version_controller.dart';
import 'package:plan_sync/util/external_links.dart';

class VersionCheckWidget extends StatefulWidget {
  const VersionCheckWidget({super.key});

  @override
  State<VersionCheckWidget> createState() => _VersionCheckWidgetState();
}

class _VersionCheckWidgetState extends State<VersionCheckWidget> {
  bool isWorking = false;
  bool isLatest = true;

  late VersionController versionController;

  @override
  void initState() {
    super.initState();
    versionController = Get.find();
    checkVersionIfUpdate();
  }

  checkVersionIfUpdate() async {
    setState(() {
      isWorking = true;
    });
    final update = await versionController.isUpdateAvailable();
    setState(() {
      isWorking = false;
      isLatest = update;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GetBuilder<VersionController>(
      builder: (controller) {
        if (controller.isError) {
          return Container(
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                color: colorScheme.primary,
              ),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "Server error occoured, try again later.",
                    style: TextStyle(color: colorScheme.onPrimary),
                  ),
                  SizedBox(width: 16),
                  Icon(
                    Icons.error_outline_rounded,
                    color: colorScheme.error,
                  )
                ],
              ));
        }
        return Container(
          decoration: ShapeDecoration(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            color: colorScheme.primary,
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: isLatest
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    isWorking
                        ? Text(
                            "Checking for updates",
                            style: TextStyle(color: colorScheme.onPrimary),
                          )
                        : Text(
                            "You're on the latest verison!",
                            style: TextStyle(color: colorScheme.onPrimary),
                          ),
                    const SizedBox(width: 16),
                    isWorking
                        ? LoadingAnimationWidget.prograssiveDots(
                            color: colorScheme.onPrimary,
                            size: 24,
                          )
                        : const Icon(Icons.check_circle_outline_rounded)
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Update Available",
                      style: TextStyle(color: colorScheme.onPrimary),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      style: ButtonStyle(
                          elevation: MaterialStatePropertyAll(0.0),
                          backgroundColor:
                              MaterialStatePropertyAll(colorScheme.secondary),
                          foregroundColor:
                              MaterialStatePropertyAll(colorScheme.onSecondary),
                          shape: MaterialStatePropertyAll(StadiumBorder())),
                      onPressed: () => ExternalLinks.updateApp(),
                      icon: const Icon(Icons.download_rounded),
                      label: const Text("Download Now"),
                    )
                  ],
                ),
        );
      },
    );
  }
}
