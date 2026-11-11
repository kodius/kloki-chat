import 'package:firebase_core/firebase_core.dart';

/// Configuration used for receiving notifications on Android.
///
/// The Kloki chat server sends Android notifications to FCM itself,
/// with a service account of the Firebase project `konvo-fb886`
/// (see "Push" in boro's `.kubernetes/zulip/README.md`),
/// so the FCM token must come from that same project.
/// A token from Zulip's own project, as upstream uses,
/// would be rejected.
///
/// These values are public identifiers,
/// from the `google-services.json` of the Android app `konvo.kodius.com`
/// in that project.
/// For details, see:
///   https://developers.google.com/android/guides/google-services-plugin#processing_the_json_file
const kFirebaseOptionsAndroid = FirebaseOptions(
  appId: '1:${_KlokiFirebaseOptions.projectNumber}:android:278f037643459d91f7defd',
  messagingSenderId: _KlokiFirebaseOptions.projectNumber,
  projectId: _KlokiFirebaseOptions.projectId,
  apiKey: _KlokiFirebaseOptions.firebaseApiKey,
);

abstract class _KlokiFirebaseOptions {
  static const projectNumber = '552649391048';
  static const projectId = 'konvo-fb886';

  // Google Cloud API keys, public by design: they ship in every build and
  // only identify the app to Firebase. Firebase made one per platform
  // ("Android key" and "iOS key (auto created by Firebase)").
  static const firebaseApiKey = 'AIzaSyBz_9WNQl18ROlRu9VBuJrq3G1aHFMuTwI';
  static const iosApiKey = 'AIzaSyDfcRKzLItdAfvAptGRckZAkmoFL_UE3rY';
}

/// Configuration used for receiving notifications on iOS.
///
/// iOS goes through FCM too: the app registers its FCM token (from the
/// Firebase project `konvo-fb886`, like [kFirebaseOptionsAndroid]) as its
/// APNs token, and the Kloki chat server sends those through FCM with the
/// APNs payload (kodius/zulip `zerver/lib/kloki_push.py`). FCM delivers
/// them through APNs with the key uploaded to that project.
const kFirebaseOptionsIos = FirebaseOptions(
  appId: '1:${_KlokiFirebaseOptions.projectNumber}:ios:165adc9ab430ff41f7defd',
  messagingSenderId: _KlokiFirebaseOptions.projectNumber,
  projectId: _KlokiFirebaseOptions.projectId,
  apiKey: _KlokiFirebaseOptions.iosApiKey,
);
