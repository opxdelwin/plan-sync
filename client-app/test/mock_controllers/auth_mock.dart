import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:plan_sync/controllers/auth.dart';

class MockAuth extends GetxController with Mock implements Auth {
  MockFirebaseAuth _auth = MockFirebaseAuth();

  @override
  User? get activeUser => _auth.currentUser;

  @override
  Future<void> loginWithGoogle() async {
    final user = MockUser(
      isAnonymous: false,
      uid: 'mock-user-uid',
      email: 'mock@plansync.in',
      displayName: 'MockUser',
    );
    _auth = MockFirebaseAuth(mockUser: user, signedIn: true);
    return;
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    return;
  }
}
