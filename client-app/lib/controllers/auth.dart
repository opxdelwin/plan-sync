import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:plan_sync/controllers/analytics_controller.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:plan_sync/util/snackbar.dart';

class Auth extends GetxController {
  final _auth = FirebaseAuth.instance;
  User? get activeUser => _auth.currentUser;

  Future<void> loginWithGoogle() async {
    Logger.i("login using google");
    // Trigger the authentication flow
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (googleAuth == null) {
        Logger.e(
          "googleAuth was null, login potentially cancelled by the user",
        );
        CustomSnackbar.error(
          "Authentication Error",
          "Login was cancelled by the user.",
        );

        return;
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      await FirebaseCrashlytics.instance.setUserIdentifier(activeUser!.uid);

      AnalyticsController analytics = Get.find();
      analytics.setUserData();

      return;
    } on FirebaseAuthException catch (error) {
      CustomSnackbar.error(
        "Authentication Error",
        "${error.code} : ${error.message}",
      );
      logout();
      return;
    } catch (error, trace) {
      CustomSnackbar.error(
        "Authentication Error",
        "Team has been notified, try again later",
      );
      FirebaseCrashlytics.instance.recordError(error, trace);
      logout();
      return;
    }
  }

  Future<void> loginWithApple() async {
    final appleAuth = AppleAuthProvider();
    appleAuth.addScope('email');
    appleAuth.addScope('name');

    try {
      await FirebaseAuth.instance.signInWithProvider(
        appleAuth,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == "web-context-canceled" || e.code == "canceled") {
        CustomSnackbar.error(
          "Authentication Error",
          "Procedure was cancelled by the user.",
        );
      }
      return;
    } catch (error, trace) {
      CustomSnackbar.error(
        "Authentication Error",
        "Team has been notified, try again later",
      );
      FirebaseCrashlytics.instance.recordError(error, trace);
      logout();
      return;
    }

    if (activeUser == null) {
      Logger.e("Active User Null post login -> auth.dart:58");
      return;
    }
    await FirebaseCrashlytics.instance.setUserIdentifier(activeUser!.uid);

    AnalyticsController analytics = Get.find();
    analytics.setUserData();

    return;
  }

  Future<void> logout() async {
    Logger.i("logout sequence");
    await _auth.signOut();
    await GoogleSignIn().signOut();
    await FirebaseCrashlytics.instance.setUserIdentifier("");
    return;
  }

  Future<void> deleteCurrentUser() async {
    final provider =
        Platform.isAndroid ? GoogleAuthProvider() : AppleAuthProvider();

    UserCredential? authenticatedUser;
    try {
      authenticatedUser = await _auth.currentUser?.reauthenticateWithProvider(
        provider,
      );
    } on FirebaseAuthException catch (e) {
      // commonly happens if user used Apple Sign in with private
      // relay service.
      if (e.code == "user-mismatch") {
        CustomSnackbar.error(
          "User Mismatch",
          "We we're unable to verify your account, contact us to continue deletion.",
        );
        return;
      }
    }

    if (authenticatedUser == null) {
      CustomSnackbar.error(
        "Operation Failed",
        "We we're unable to verify your account, try again.",
      );
      return;
    }
    return _auth.currentUser?.delete().then((value) {
      CustomSnackbar.info(
        "Account Deleted",
        "We have sent delete request, it'll be done shortly!",
      );
      return;
    }).onError((err, trace) async {
      CustomSnackbar.error(
        "Operation Failed",
        "We faced some error. Please try again later.",
      );

      if (kReleaseMode) {
        FlutterErrorDetails flutterErrorDetails = FlutterErrorDetails(
          exception: err ?? Exception("Null exception on user delete"),
          stack: trace,
        );
        await FirebaseCrashlytics.instance.recordFlutterError(
          flutterErrorDetails,
        );
      }
      return;
    });
  }
}
