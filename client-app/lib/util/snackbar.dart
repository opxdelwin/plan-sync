import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackbar {
  CustomSnackbar.error(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Theme.of(Get.context!).colorScheme.error,
      colorText: Theme.of(Get.context!).colorScheme.onError,
    );
    return;
  }
}
