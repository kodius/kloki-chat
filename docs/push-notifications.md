# Push notifications

## How they get to the phone

Both platforms receive notifications through FCM,
from the Firebase project `konvo-fb886`
(shown in the Firebase console as `kloki-chat`).
The Kloki chat server sends them itself,
with that project's service account.
Zulip's push bouncer isn't involved: this isn't Zulip's app.

* **Android**: the app registers its FCM token
  the legacy way (`users/me/android_gcm_reg_id`),
  and the server sends to FCM.
* **iOS**: the app registers its FCM token as its APNs token
  (`users/me/apns_device_token`),
  and the server sends it through FCM with the APNs payload
  (kodius/zulip `zerver/lib/kloki_push.py`).
  FCM delivers through APNs with the team's APNs auth key.
  On the phone, the `NotificationService` extension
  (`ios/NotificationService/`) runs the Dart code
  in `lib/notifications/ios_service.dart`
  to build what the notification shows.

E2EE notifications are off (`PushDeviceManager.e2eeEnabled`):
they need Zulip's bouncer.
So `lib/notifications/receive.dart` keeps showing legacy plaintext
notifications even from servers new enough for E2EE,
where upstream would drop them.


## Configuration

The app reads its Firebase configuration from `lib/firebase_options.dart`,
not from `google-services.json` or `GoogleService-Info.plist`.
Each platform has its own app in the Firebase project,
registered under its store ID
(`konvo.kodius.com` on Android, `com.kodius.klokichat` on iOS).

For iOS, the APNs auth key `Q22MAG94D6`
(team `N53842DU2C`, sandbox and production)
is uploaded in Firebase → Project settings → Cloud Messaging
→ the iOS app → APNs Authentication Key,
in both the Development and Production rows.
The key file is private; it is not in the repo.

On the server side, see "Push" in boro's `.kubernetes/zulip/README.md`.
The server needs nothing per app.
Push is enabled only in production (`push.enabled` in `prod.values.yaml`),
so a dev organization (`*.chat.dev.kloki.app`) sends no notifications.


## Testing

1. Sign in to a production organization on a real device.
   iOS simulators can't receive remote notifications.
2. Settings → Notifications shows this device's push token;
   tap it to copy.
   On both platforms it's an FCM token (`…:APA91b…`), not hex.
3. Send a DM to that account from another account
   and lock the phone, or put the app in the background.

To check delivery without the server,
send a message to the copied token
with *Test on device* in the Firebase console's Messaging.

On iOS, notifications need a build with the `aps-environment`
entitlement matching the APNs environment:
a debug build gets development, TestFlight and the App Store
get production.
The Firebase key covers both.


## Debugging the iOS NotificationService

* Its logs don't show in `flutter run` or `flutter logs`.
  Use Console.app on the Mac, with the phone selected,
  and filter on `NotificationService`.
* Hot reload doesn't reach it: it runs in its own process
  with its own Flutter engine.
  Rebuild and reinstall the app after changing
  `lib/notifications/ios_service.dart`.
* iOS gives it about 30 seconds.
  If it doesn't finish, the notification shows
  whatever the server sent (`serviceExtensionTimeWillExpire`).
