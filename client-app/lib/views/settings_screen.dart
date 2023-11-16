import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/util/external_links.dart';
import 'package:plan_sync/widgets/filters_bar.dart';
import 'package:plan_sync/widgets/semester_bar.dart';
import '../controllers/auth.dart';
import '../util/colors.dart';
import '../util/constants.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Auth auth = Get.find();
    FilterController filterController = Get.find();
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: black,
          elevation: 0.0,
          toolbarHeight: 80,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(32),
          )),
          title: const Text(
            "Account",
            style: TextStyle(
              color: white,
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
                Row(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: CachedNetworkImageProvider(
                        auth.activeUser!.photoURL ?? DEFAULT_USER_IMAGE,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.activeUser!.displayName ?? "username",
                          style: const TextStyle(
                            color: black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(auth.activeUser!.email ?? "example@gmail.com"),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                ListTile(
                  leading: const Text(
                    "Primary\nSemester",
                    style: TextStyle(color: black),
                  ),
                  title: const SemesterBar(),
                  trailing: GetBuilder<FilterController>(builder: (controller) {
                    return IconButton(
                      icon: controller.primarySemester !=
                              controller.activeSemester
                          ? const Icon(Icons.download_rounded)
                          : const Icon(
                              Icons.check_circle_outline_rounded,
                              color: primary,
                            ),
                      onPressed: () => filterController.storePrimarySemester(),
                    );
                  }),
                ),
                ListTile(
                  leading: const Text(
                    "Primary\nSection",
                    style: TextStyle(color: black),
                  ),
                  title: const FiltersBar(),
                  trailing: GetBuilder<FilterController>(builder: (controller) {
                    return IconButton(
                      icon: controller.primarySection !=
                              controller.activeSectionCode
                          ? const Icon(Icons.download_rounded)
                          : const Icon(
                              Icons.check_circle_outline_rounded,
                              color: primary,
                            ),
                      onPressed: () => filterController.storePrimarySection(),
                    );
                  }),
                ),
                const Divider(),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.report),
                  title: const Text("Report an error"),
                  trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                  onTap: () => ExternalLinks.reportError(),
                ),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text("Share"),
                  trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                  onTap: () => ExternalLinks.shareApp(),
                ),
                ListTile(
                  leading: const Icon(Icons.add_circle_outline_rounded),
                  title: const Text("Contribute Time Table"),
                  trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                  onTap: () => ExternalLinks.contributeTimeTable(),
                ),
                const SizedBox(height: 8),
                const Divider(),
                ListTile(
                  leading: const Icon(FontAwesomeIcons.fileLines),
                  title: const Text("Terms of Service"),
                  trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                  onTap: () => ExternalLinks.termsAndConditions(),
                ),
                ListTile(
                  leading: const Icon(Icons.security_rounded),
                  title: const Text("Privacy Policy"),
                  trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                  onTap: () => ExternalLinks.privacyPolicy(),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(black)),
                  onPressed: () => auth.logout(),
                  icon: const Icon(Icons.logout, color: white),
                  label: const Text(
                    "Logout",
                    style: TextStyle(color: white),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ));
  }
}
