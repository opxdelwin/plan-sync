import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plan_sync/widgets/tutorials/app_target_focus.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

//TODO: find a way to simulate bottomsheet click and continue
// the tutorial

//TODO: init shared-perfs to store data state, to check if to show
// tutorial at launch

class AppTourController extends GetxController {
  late GlobalKey _schedulePreferencesButtonKey;
  GlobalKey get schedulePreferencesButtonKey => _schedulePreferencesButtonKey;

  late GlobalKey _electiveNavButtonKey;
  GlobalKey get electiveNavButtonKey => _electiveNavButtonKey;

  @override
  void onInit() {
    super.onInit();
    _schedulePreferencesButtonKey = GlobalKey();
    _electiveNavButtonKey = GlobalKey();
  }

  Future<void> startAppTour(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;

    if (await tourAlreadyCompleted()) {
      return;
    }

    List<TargetFocus> targets = getTutorialTargets(context);

    TutorialCoachMark tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: colorScheme.onBackground,
      alignSkip: Alignment.bottomRight,
      textSkip: "SKIP",
      paddingFocus: 0,
      focusAnimationDuration: const Duration(milliseconds: 500),
      unFocusAnimationDuration: const Duration(milliseconds: 500),
      pulseAnimationDuration: const Duration(milliseconds: 500),
      showSkipInLastTarget: true,
      imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      initialFocus: 0,
      useSafeArea: true,
      onFinish: () {
        print("finish");
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        print("target: $target");
        print(
            "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },
      onClickTarget: (target) {},
    );

    if (!context.mounted) {
      return;
    }

    tutorial.show(context: context);

    // tutorial.skip();
    // tutorial.finish();
    // tutorial.next(); // call next target programmatically
    // tutorial.previous(); // call previous target programmatically
    // tutorial.goTo(3); // call target programmatically by index
  }

  Future<bool> tourAlreadyCompleted() async {
    return false;
  }

  List<TargetFocus> getTutorialTargets(BuildContext context) {
    List<TargetFocus> targets = [];
    final colorScheme = Theme.of(context).colorScheme;

    targets.add(
      AppTargetFocus.schedulePreferencesButton(
        colorScheme: colorScheme,
        buttonKey: schedulePreferencesButtonKey,
      ),
    );

    return targets;
  }
}
