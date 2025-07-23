import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:plan_sync/util/external_links.dart';
import 'package:plan_sync/util/snackbar.dart';

class ForcedUpdateScreen extends StatelessWidget {
  const ForcedUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/lottie/graph_animation.json',
                  height: size.height * 0.3,
                  width: size.width * 0.6,
                ),
                const SizedBox(height: 32),
                Text(
                  "Important System Update Available",
                  style: TextStyle(
                    fontSize: 24,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  "We've been burning the midnight oil to bring you some nifty new "
                  "features and iron out a few wrinkles. Your app is about to get smarter,"
                  " faster, and might even start telling better jokes. Time for a quick "
                  "spruce-up!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.72),
                  ),
                )
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () async {
              try {
                await ExternalLinks.store();
              } catch (e) {
                if (!context.mounted) return;
                CustomSnackbar.error(
                  'Failed to open store',
                  'Could not open the app store. Please try again.',
                  context,
                );
              }
            },
            child: Text(
              'Update Now',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ));
  }
}
