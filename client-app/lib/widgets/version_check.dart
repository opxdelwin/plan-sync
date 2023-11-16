import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:plan_sync/controllers/version_controller.dart';
import 'package:plan_sync/util/colors.dart';
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
    return GetBuilder<VersionController>(
      builder: (controller) {
        if (controller.isError) {
          return Container(
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                color: secondary,
              ),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "Server error occoured, try again later.",
                    style: TextStyle(color: black),
                  ),
                  SizedBox(width: 16),
                  Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                  )
                ],
              ));
        }
        return Container(
          decoration: ShapeDecoration(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            color: secondary,
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: isLatest
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    isWorking
                        ? const Text(
                            "Checking for updates",
                            style: TextStyle(color: black),
                          )
                        : const Text(
                            "You're on the latest verison!",
                            style: TextStyle(color: black),
                          ),
                    const SizedBox(width: 16),
                    isWorking
                        ? LoadingAnimationWidget.prograssiveDots(
                            color: black, size: 24)
                        : const Icon(Icons.check_circle_outline_rounded)
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      "Update Available",
                      style: TextStyle(color: black),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(black),
                          foregroundColor: MaterialStatePropertyAll(white),
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
