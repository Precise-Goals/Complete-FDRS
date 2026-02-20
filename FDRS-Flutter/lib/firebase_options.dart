import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'see https://github.com/firebase/flutterfire/blob/master/packages/firebase_core/firebase_core/example/lib/firebase_options.dart',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD8gx48hLf-g9kVudOXzms0kJEtuXdL4n0',
    appId: '1:476999757389:android:6a9d1bae8cc76ba7d7f604',
    messagingSenderId: '476999757389',
    projectId: 'fdrs-53651',
    authDomain: 'fdrs-53651.firebaseapp.com',
    storageBucket: 'fdrs-53651.firebasestorage.app',
    databaseURL: 'https://fdrs-53651-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD8gx48hLf-g9kVudOXzms0kJEtuXdL4n0',
    appId: '1:476999757389:android:6a9d1bae8cc76ba7d7f604',
    messagingSenderId: '476999757389',
    projectId: 'fdrs-53651',
    storageBucket: 'fdrs-53651.firebasestorage.app',
    databaseURL: 'https://fdrs-53651-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: '476999757389',
    projectId: 'fdrs-53651',
    storageBucket: 'fdrs-53651.firebasestorage.app',
    databaseURL: 'https://fdrs-53651-default-rtdb.firebaseio.com',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'YOUR_IOS_BUNDLE_ID',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: '476999757389',
    projectId: 'fdrs-53651',
    storageBucket: 'fdrs-53651.firebasestorage.app',
    databaseURL: 'https://fdrs-53651-default-rtdb.firebaseio.com',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'YOUR_IOS_BUNDLE_ID',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD8gx48hLf-g9kVudOXzms0kJEtuXdL4n0',
    appId: '1:476999757389:android:6a9d1bae8cc76ba7d7f604',
    messagingSenderId: '476999757389',
    projectId: 'fdrs-53651',
    authDomain: 'fdrs-53651.firebaseapp.com',
    storageBucket: 'fdrs-53651.firebasestorage.app',
    databaseURL: 'https://fdrs-53651-default-rtdb.firebaseio.com',
  );
}
