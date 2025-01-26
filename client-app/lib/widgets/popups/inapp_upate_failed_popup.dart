import 'package:flutter/material.dart';
import 'package:plan_sync/util/external_links.dart';

class InAppUpateFailedPopup extends StatelessWidget {
  const InAppUpateFailedPopup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Update needed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black87,
                  height: 1.3,
                ),
                children: [
                  const TextSpan(
                    text:
                        'Oops! The automatic update didn\'t go as planned, but no worries - we can fix it! ',
                  ),
                  TextSpan(
                    text: '😊',
                    style: TextStyle(
                      color: Colors.amber[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We\'ll take you directly to Play Store where you can update the app with just one tap.',
              style: TextStyle(
                color: Colors.black87,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => ExternalLinks.store(),
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  backgroundColor: WidgetStatePropertyAll(
                    colorScheme.primary,
                  ),
                  foregroundColor: WidgetStatePropertyAll(
                    colorScheme.onPrimary,
                  ),
                ),
                label: const Text("Open Store"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
