import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/app_tour_controller.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/widgets/buttons/schedule_preferences_button.dart';
import 'package:plan_sync/widgets/date_widget.dart';
import '../widgets/time_table.dart';
import '../widgets/version_check.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FilterController filterController = Get.find();
  AppTourController appTourController = Get.find();
  String? sectionSemesterShortCode;

  @override
  void initState() {
    super.initState();
    filterController.getShortCode().then(
          (code) => setState(() {
            sectionSemesterShortCode = code;
          }),
        );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        // ignore: use_build_context_synchronously
        appTourController.startAppTour(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0.0,
          toolbarHeight: 80,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(32),
          )),
          title: Text(
            "Plan Sync",
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          actions: [
            SchedulePreferenceButton(
              key: appTourController.schedulePreferencesButtonKey,
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ListView(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const VersionCheckWidget(),
                  const DateWidget(),
                  const SizedBox(height: 16),
                  Text(
                    "Time Sheet",
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const TimeTableWidget()
                ],
              ),
              const SizedBox(height: 60)
            ],
          ),
        ));
  }
}
