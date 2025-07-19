import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:plan_sync/backend/models/timetable.dart';
import 'package:plan_sync/controllers/app_preferences_controller.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/util/enums.dart';
import 'package:plan_sync/widgets/buttons/elective_preferences_button.dart';
import 'package:plan_sync/widgets/date_widget.dart';
import 'package:plan_sync/widgets/popups/popups_wrapper.dart';
import 'package:plan_sync/widgets/time_table.dart';
import 'package:provider/provider.dart';

class ElectiveScreen extends StatefulWidget {
  const ElectiveScreen({super.key});

  @override
  State<ElectiveScreen> createState() => _ElectiveScreenState();
}

class _ElectiveScreenState extends State<ElectiveScreen> {
  late FilterController filterController;
  late AppPreferencesController appPrefsController;
  String? sectionSemesterShortCode;

  void reportError() {
    PopupsWrapper.reportError(
      context: context,
      scheduleType: ScheduleType.electives,
    );
  }

  @override
  void initState() {
    super.initState();
    filterController = Provider.of<FilterController>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerHighest,
        elevation: 0.0,
        toolbarHeight: 80,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32),
        )),
        title: Text(
          "Electives",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        actions: const [
          ElectivePreferenceButton(),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),
              const DateWidget(),
              const SizedBox(height: 8),
              Consumer<FilterController>(
                builder: (ctx, filterController, child) {
                  GitService service =
                      Provider.of<GitService>(context, listen: false);
                  return StreamBuilder(
                    key: ValueKey(filterController.getElectiveShortCode()),
                    stream: service.getElectives(),
                    builder: (context, AsyncSnapshot<Timetable?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const ElectiveLoadingWidget();
                      } else if (snapshot.hasError) {
                        return ElectiveErrorWidget(
                            error: snapshot.error.toString());
                      } else if (!snapshot.hasData &&
                          snapshot.connectionState == ConnectionState.done) {
                        return const ElectiveNoDataWidget();
                      } else if (snapshot.data?.meta.isTimetableUpdating ??
                          false) {
                        return const ElectiveUpdatingWidget();
                      } else {
                        return ElectiveContentWidget(
                          timetable: snapshot.data!,
                          onReportError: reportError,
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ElectiveLoadingWidget extends StatelessWidget {
  const ElectiveLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Center(
          child: CircularProgressIndicator(
            color: colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}

class ElectiveErrorWidget extends StatelessWidget {
  final String error;

  const ElectiveErrorWidget({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 32),
        const Icon(
          Icons.error,
          color: Colors.red,
          size: 40,
        ),
        const SizedBox(height: 16),
        Flexible(
          child: MarkdownBody(data: "```$error```"),
        ),
        const SizedBox(height: 16),
        const Text(
            "A status report has been sent, this issue will be looked into."),
      ],
    );
  }
}

class ElectiveNoDataWidget extends StatelessWidget {
  const ElectiveNoDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32),
          Icon(
            Icons.info,
            color: colorScheme.secondary,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            "No Data Available",
            style: TextStyle(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class ElectiveUpdatingWidget extends StatelessWidget {
  const ElectiveUpdatingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32),
          Icon(
            Icons.settings_outlined,
            color: colorScheme.secondary,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            "We're working on this timetable,",
            style: TextStyle(
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            "Check back in soon!",
            style: TextStyle(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class ElectiveContentWidget extends StatelessWidget {
  final Timetable timetable;
  final VoidCallback onReportError;

  const ElectiveContentWidget({
    super.key,
    required this.timetable,
    required this.onReportError,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 8),
        TimeTableWidget(isElective: true),
      ],
    );
  }
}