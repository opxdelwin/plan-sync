import 'package:connectivity_plus/connectivity_plus.dart';

/// Waits till the device is back online.
/// Primarily used to wait for the device to connect to the internet,
/// before supabase makes a postgREST request.
///
/// The request would fail if the device is offline.
Future<void> waitForInternetConnectivity() async {
  final conn = Connectivity();

  await for (final event in conn.onConnectivityChanged) {
    if (!event.contains(ConnectivityResult.none)) {
      break;
    }
  }
}

Future<bool> hasInternetConnection() async {
  final conn = await Connectivity().checkConnectivity();
  return conn.contains(ConnectivityResult.none);
}
