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
                    color: colorScheme.background.withOpacity(0.8),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
