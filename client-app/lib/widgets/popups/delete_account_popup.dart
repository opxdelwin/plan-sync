import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:plan_sync/controllers/auth.dart';

class DeleteAccountPopup extends StatefulWidget {
  const DeleteAccountPopup({super.key});

  @override
  State<DeleteAccountPopup> createState() => _DeleteAccountPopupState();
}

class _DeleteAccountPopupState extends State<DeleteAccountPopup> {
  bool isWorking = false;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: colorScheme.surface,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                "Delete your account?",
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Oops! We're sad to see you go, but we understand."
              "\n\nJust so you know, deleting your account will remove all your data from our servers within 7 working days. "
              "This action can't be undone. We will ask you to sign in again."
              "\n\nBefore you go, is there anything we can help with? "
              "Sometimes a quick chat can solve things easier than starting over.",
              style: TextStyle(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isWorking
                        ? () {}
                        : () async {
                            setState(() {
                              isWorking = true;
                            });
                            await Get.find<Auth>().deleteCurrentUser();
                            setState(() {
                              isWorking = false;
                            });
                          },
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      backgroundColor: WidgetStatePropertyAll(
                        colorScheme.error,
                      ),
                      foregroundColor: WidgetStatePropertyAll(
                        colorScheme.onError,
                      ),
                    ),
                    child: isWorking
                        ? LoadingAnimationWidget.progressiveDots(
                            color: colorScheme.onError,
                            size: 24,
                          )
                        : const Text("Delete Account"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        isWorking ? {} : Navigator.of(context).pop(),
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
                    child: isWorking
                        ? LoadingAnimationWidget.progressiveDots(
                            color: colorScheme.onPrimary,
                            size: 24,
                          )
                        : const Text("Cancel"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
