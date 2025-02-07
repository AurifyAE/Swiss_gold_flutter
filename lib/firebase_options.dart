// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCAHapnxRWqH8lwgYuFjrHQ7rDrkRlSe54',
    appId: '1:329227476273:web:d977025db3317cafeee410',
    messagingSenderId: '329227476273',
    projectId: 'pushnotifaction-11aab',
    authDomain: 'pushnotifaction-11aab.firebaseapp.com',
    storageBucket: 'pushnotifaction-11aab.firebasestorage.app',
    measurementId: 'G-LB4BB5PSG5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAxqLz38mV2VN3IR6YeF9DQS_ZUyDdA0qc',
    appId: '1:329227476273:android:b674d95426fd35a1eee410',
    messagingSenderId: '329227476273',
    projectId: 'pushnotifaction-11aab',
    storageBucket: 'pushnotifaction-11aab.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDJHftzZwSbJXwsB5Fg77PkAaRyBJWnHMc',
    appId: '1:329227476273:ios:992074daf491428beee410',
    messagingSenderId: '329227476273',
    projectId: 'pushnotifaction-11aab',
    storageBucket: 'pushnotifaction-11aab.firebasestorage.app',
    iosBundleId: 'com.tecnavis.swissgold',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDJHftzZwSbJXwsB5Fg77PkAaRyBJWnHMc',
    appId: '1:329227476273:ios:992074daf491428beee410',
    messagingSenderId: '329227476273',
    projectId: 'pushnotifaction-11aab',
    storageBucket: 'pushnotifaction-11aab.firebasestorage.app',
    iosBundleId: 'com.tecnavis.swissgold',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCXmn_n7D5K_p88voGCIlZhsFMJWes27P4',
    appId: '1:329227476273:web:8a4dab8b1dddf30aeee410',
    messagingSenderId: '329227476273',
    projectId: 'pushnotifaction-11aab',
    authDomain: 'pushnotifaction-11aab.firebaseapp.com',
    storageBucket: 'pushnotifaction-11aab.firebasestorage.app',
    measurementId: 'G-SXLW2E3C7B',
  );
}
