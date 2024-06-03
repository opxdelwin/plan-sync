import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:plan_sync/controllers/app_preferences_controller.dart';
import 'package:plan_sync/controllers/app_tour_controller.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:plan_sync/widgets/bottom-sheets/bottom_sheets_wrapper.dart';
import 'package:plan_sync/widgets/tutorials/app_target_focus.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class MockAppTourController extends GetxController
    with Mock
    implements AppTourController {
  @override
  late AppPreferencesController appPreferencesController;

  late GlobalKey _schedulePreferencesButtonKey;
  @override
  GlobalKey get schedulePreferencesButtonKey => _schedulePreferencesButtonKey;

  late GlobalKey _sectionBarKey;
  @override
  GlobalKey get sectionBarKey => _sectionBarKey;

  late GlobalKey _savePreferenceSwitchKey;
  @override
  GlobalKey get savePreferenceSwitchKey => _savePreferenceSwitchKey;

  @override
  void onInit() {
    appPreferencesController = Get.find();
    super.onInit();
    _schedulePreferencesButtonKey = GlobalKey();
    _sectionBarKey = GlobalKey();
    _savePreferenceSwitchKey = GlobalKey();
  }

  @override
  Future<void> startAppTour(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;

    if (await tourAlreadyCompleted()) {
      return;
    } else if (!context.mounted) {
      return;
    }

    List<TargetFocus> targets = getTutorialTargets(context);

    TutorialCoachMark tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: colorScheme.onSurface,
      textSkip: "SKIP",
      textStyleSkip: TextStyle(color: colorScheme.background),
      paddingFocus: 0,
      focusAnimationDuration: const Duration(milliseconds: 500),
      unFocusAnimationDuration: const Duration(milliseconds: 500),
      pulseAnimationDuration: const Duration(milliseconds: 750),
      showSkipInLastTarget: true,
      imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      initialFocus: 0,
      useSafeArea: true,
      onFinish: onTourComplete,
      onSkip: () {
        onTourComplete();
        return true;
      },
      onClickTargetWithTapPosition: onClickHandler,
    );

    if (!context.mounted) {
      return;
    }

    tutorial.show(context: context, rootOverlay: true);
  }

  @override
  Future<void> onClickHandler(
      TargetFocus target, TapDownDetails tapDownDetails) async {
    if (target.identify == schedulePreferencesButtonKey.hashCode) {
      Logger.i('key match with schedule button');

      await Future.delayed(const Duration(milliseconds: 250));
      BottomSheets.changeSectionPreference(
        context: schedulePreferencesButtonKey.currentContext!,
      );
    }
    return;
  }

  @override
  Future<bool> tourAlreadyCompleted() async {
    return appPreferencesController.getTutorialStatus() ?? false;
  }

  @override
  List<TargetFocus> getTutorialTargets(BuildContext context) {
    List<TargetFocus> targets = [];
    final colorScheme = Theme.of(context).colorScheme;

    targets.add(
      AppTargetFocus.schedulePreferencesButton(
        colorScheme: colorScheme,
        buttonKey: schedulePreferencesButtonKey,
      ),
    );
    targets.add(
      AppTargetFocus.savePreferenceSwitch(
        colorScheme: colorScheme,
        buttonKey: savePreferenceSwitchKey,
      ),
    );
    targets.add(
      AppTargetFocus.sectionBarButton(
        colorScheme: colorScheme,
        buttonKey: sectionBarKey,
      ),
    );

    return targets;
  }

  @override
  Future<void> onTourComplete() async {
    final res = await appPreferencesController.saveTutorialStatus(true);
    if (res != true) {
      final err = {
        'origin': 'AppTourController.onTourComplete',
        'message': 'error saving to shared preferences'
      };
      return Future.error(err);
    }
    return;
  }
}
