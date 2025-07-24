import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plan_sync/util/external_links.dart';
import 'package:plan_sync/util/snackbar.dart';

class ContributeScheduleBottomSheet extends StatelessWidget {
  const ContributeScheduleBottomSheet({super.key});

  void launchMail(BuildContext context) async {
    try {
      await ExternalLinks.contributeTimeTableViaMail();
    } catch (e) {
      if (!context.mounted) return;

      CustomSnackbar.error(
        'Failed to launch mail app',
        'Could not open your mail application. Please try again.',
        context,
      );
    }
  }

  void launchGithub(BuildContext context) async {
    try {
      await ExternalLinks.contributeTimeTableViaGithub();
    } catch (e) {
      if (!context.mounted) return;

      CustomSnackbar.error(
        'Failed to launch GitHub',
        'Could not open GitHub. Please try again.',
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: size.width * 0.04,
        right: size.width * 0.04,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // via mail
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Contribute via mail",
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
              ),
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll(colorScheme.onSurface),
                  ),
                  onPressed: () => launchMail(context),
                  child: Row(
                    children: [
                      Text(
                        'Launch Mail',
                        style: TextStyle(
                          color: colorScheme.surface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.mail_outline_rounded,
                        color: colorScheme.surface,
                      )
                    ],
                  ))
            ],
          ),

          // via github
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Contribute via GitHub",
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
              ),
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll(colorScheme.onSurface),
                  ),
                  onPressed: () => launchGithub(context),
                  child: Row(
                    children: [
                      Text(
                        'Launch GitHub',
                        style: TextStyle(
                          color: colorScheme.surface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        FontAwesomeIcons.github,
                        color: colorScheme.surface,
                      )
                    ],
                  ))
            ],
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
