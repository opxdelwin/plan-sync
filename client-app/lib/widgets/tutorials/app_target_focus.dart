import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class AppTargetFocus {
  AppTargetFocus();

  static schedulePreferencesButton({
    required ColorScheme colorScheme,
    required GlobalKey buttonKey,
  }) {
    return TargetFocus(
      identify: buttonKey.hashCode,
      keyTarget: buttonKey,
      contents: [
        TargetContent(
          align: ContentAlign.left,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 64),
              Text(
                "Select your section here",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.background,
                  fontSize: 20.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  "View your schedule efficiently and save your preferences here",
                  style: TextStyle(
                    color: colorScheme.background,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  static sectionBarButton({
    required ColorScheme colorScheme,
    required GlobalKey buttonKey,
  }) {
    return TargetFocus(
      identify: buttonKey.hashCode,
      keyTarget: buttonKey,
      shape: ShapeLightFocus.RRect,
      radius: 24,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Select your section",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.background,
                  fontSize: 20.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  "We have all the schedules ready to go!",
                  style: TextStyle(
                    color: colorScheme.background,
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ],
    );
  }

  static savePreferenceSwitch({
    required ColorScheme colorScheme,
    required GlobalKey buttonKey,
  }) {
    return TargetFocus(
      identify: buttonKey.hashCode,
      keyTarget: buttonKey,
      shape: ShapeLightFocus.RRect,
      radius: 24,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Save Everything",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.background,
                  fontSize: 20.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  "Turn this on to save your section details.\nWe'll open this up when you come back!",
                  style: TextStyle(
                    color: colorScheme.background,
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ],
    );
  }
}
