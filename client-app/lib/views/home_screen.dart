import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/widgets/buttons/schedule_preferences_button.dart';
import '../widgets/time_table.dart';
import '../widgets/version_check.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FilterController filterController = Get.find();
  String? sectionSemesterShortCode;

  @override
  void initState() {
    super.initState();
    filterController.getShortCode().then(
          (code) => setState(() {
            sectionSemesterShortCode = code;
          }),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: colorScheme.background,
          elevation: 0.0,
          toolbarHeight: 80,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(32),
          )),
          title: Text(
            "Plan Sync",
            style: TextStyle(
              color: colorScheme.onBackground,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          actions: const [
            SchedulePreferenceButton(),
            SizedBox(width: 16),
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
