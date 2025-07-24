import 'package:flutter/material.dart';
import 'package:plan_sync/util/external_links.dart';
import 'package:plan_sync/util/snackbar.dart';

class RequestFeaturesPopup extends StatefulWidget {
  const RequestFeaturesPopup({super.key});

  @override
  State<RequestFeaturesPopup> createState() => _RequestFeaturesPopupState();
}

class _RequestFeaturesPopupState extends State<RequestFeaturesPopup> {
  final GlobalKey<FormState> featureReqFormKey = GlobalKey<FormState>();
  final TextEditingController _suggestionController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendFeatureRequest() async {
    if (!(featureReqFormKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ExternalLinks.requestFeatureViaMail(
        suggestion: _suggestionController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.error(
          'Failed to send suggestion',
          'Could not send your suggestion. Please try again later.',
          context,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _suggestionController.dispose();
    super.dispose();
  }

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
                'Got an awesome idea? Share it with us!',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "We're always looking for ways to make Plan Sync even better! 🚀"
              "\n\n"
              "Tell us about features you'd love to see, improvements you think would be helpful, "
              "or any cool ideas you have in mind.",
              style: TextStyle(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: featureReqFormKey,
              child: TextFormField(
                controller: _suggestionController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your suggestion';
                  }
                  return null;
                },
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Type your feature suggestion here...',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      side: WidgetStatePropertyAll(
                        BorderSide(color: colorScheme.outline),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _sendFeatureRequest,
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
                    label: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("Send"),
                    icon: _isLoading
                        ? const SizedBox.shrink()
                        : const Icon(Icons.send_rounded),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
