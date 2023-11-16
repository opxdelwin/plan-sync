import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream() {
    notifyListeners();
    FirebaseAuth.instance.authStateChanges().listen((event) {
      notifyListeners();
    });
  }
}
