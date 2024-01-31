import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
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
    } catch (error) {
      CustomSnackbar.error(
        "Authentication Error",
        "Team has been notified, try again later",
      );
      logout();
      return;
    }
  }

  Future<void> logout() async {
    Logger.i("logout sequence");
    await _auth.signOut();
    await GoogleSignIn().signOut();
    await FirebaseCrashlytics.instance.setUserIdentifier("");
    return;
  }
}
