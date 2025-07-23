import 'package:flutter/material.dart';
import 'package:plan_sync/controllers/app_preferences_controller.dart';
import 'package:plan_sync/controllers/app_tour_controller.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/notification_controller.dart';
import 'package:plan_sync/widgets/buttons/schedule_preferences_button.dart';
import 'package:plan_sync/widgets/date_widget.dart';
import 'package:plan_sync/widgets/hud/top_notice_hud.dart';
import 'package:provider/provider.dart';
import '../widgets/time_table.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FilterController filterController;
  late AppTourController appTourController;

  @override
  void initState() {
    super.initState();
    filterController = Provider.of<FilterController>(context, listen: false);
    appTourController = Provider.of<AppTourController>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        // ignore: use_build_context_synchronously
        appTourController.startAppTour(context);
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((Provider.of<AppPreferencesController>(context, listen: false)
                  .getTutorialStatus() ??
              false) ==
          false) {
        return;
      }

      final notificationController = Provider.of<NotificationController>(
        context,
        listen: false,
      );
      notificationController.initialize(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor:
              colorScheme.surfaceContainerHighest.withOpacity(0.98),
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
                  const TopNoticeHud(),
                  const DateWidget(),
                  const SizedBox(height: 16),
                  Text(
                    "Time Sheet",
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
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
