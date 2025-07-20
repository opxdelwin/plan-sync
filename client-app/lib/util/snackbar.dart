import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class CustomSnackbar {
  CustomSnackbar.error(String title, String message, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      primaryColor: colorScheme.errorContainer,
      backgroundColor: colorScheme.errorContainer,
      foregroundColor: colorScheme.onErrorContainer,
      showIcon: false,
      showProgressBar: false,
      autoCloseDuration: const Duration(seconds: 5),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      description: Text(
        message,
        style: const TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 14,
        ),
      ),
    );
    return;
  }

  CustomSnackbar.info(String title, String message, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      primaryColor: colorScheme.secondaryContainer,
      backgroundColor: colorScheme.secondaryContainer,
      foregroundColor: colorScheme.onSecondaryContainer,
      showIcon: false,
      showProgressBar: false,
      autoCloseDuration: const Duration(seconds: 5),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      description: Text(
        message,
        style: const TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 14,
        ),
      ),
    );
    return;
  }
}
