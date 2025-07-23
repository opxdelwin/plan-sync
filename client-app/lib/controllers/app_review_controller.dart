import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:plan_sync/backend/models/in_app_review_model.dart';
import 'package:plan_sync/controllers/app_preferences_controller.dart';
import 'package:provider/provider.dart';

class AppReviewController extends ChangeNotifier {
  void initalize(BuildContext context) async {
    final available = await InAppReview.instance.isAvailable();
    if (!available) {
      log('InAppReview not available');
      return;
    }
    log('InAppReview is available');
    Future.delayed(const Duration(seconds: 5), () {
      log('Requesting review');
      showRatingsRequest(context);
    });
  }

  void showRatingsRequest(BuildContext context) async {
    final isAvailable = await InAppReview.instance.isAvailable();
    if (!isAvailable) {
      return;
    }
    final preferencesController = Provider.of<AppPreferencesController>(
      context,
      listen: false,
    );
    final reviewModel = preferencesController.getAppReviewRequest();

    if (reviewModel == null) {
      log('No review model found');
      InAppReviewCacheModel cacheModel = InAppReviewCacheModel(
        firstOpen: DateTime.now().millisecondsSinceEpoch,
      );
      await preferencesController.saveAppReviewRequest(cacheModel);
      return;
    }

    if (!await reviewModel.shouldRequestReview(context)) {
      log('Review request conditions not met');
      return;
    }

    try {
      await InAppReview.instance.requestReview();
      log('Review requested successfully');
    } catch (e) {
      log('Error requesting review: $e');
      return;
    }
  }
}
