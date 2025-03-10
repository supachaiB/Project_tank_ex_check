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
    apiKey: 'AIzaSyCMYXmrznSueixPjczu4ZTnEh-10627thE',
    appId: '1:1084138640762:web:06bfe78abe0591a41a72c3',
    messagingSenderId: '1084138640762',
    projectId: 'fire-check-db',
    authDomain: 'fire-check-db.firebaseapp.com',
    databaseURL: 'https://fire-check-db-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'fire-check-db.firebasestorage.app',
    measurementId: 'G-NZ48SL4SB9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD3aBMl7VRfCZB9kc69uMJfOoQz69JT6QE',
    appId: '1:1084138640762:android:57bb89bc2ecdcf061a72c3',
    messagingSenderId: '1084138640762',
    projectId: 'fire-check-db',
    databaseURL: 'https://fire-check-db-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'fire-check-db.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBURykRXJaxQM4Zoolv7ItalGydzQUTVzE',
    appId: '1:1084138640762:ios:53bf5b2a449a52601a72c3',
    messagingSenderId: '1084138640762',
    projectId: 'fire-check-db',
    databaseURL: 'https://fire-check-db-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'fire-check-db.firebasestorage.app',
    iosBundleId: 'com.example.firecheckSetup',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBURykRXJaxQM4Zoolv7ItalGydzQUTVzE',
    appId: '1:1084138640762:ios:53bf5b2a449a52601a72c3',
    messagingSenderId: '1084138640762',
    projectId: 'fire-check-db',
    databaseURL: 'https://fire-check-db-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'fire-check-db.firebasestorage.app',
    iosBundleId: 'com.example.firecheckSetup',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCMYXmrznSueixPjczu4ZTnEh-10627thE',
    appId: '1:1084138640762:web:1707c08ccb1168751a72c3',
    messagingSenderId: '1084138640762',
    projectId: 'fire-check-db',
    authDomain: 'fire-check-db.firebaseapp.com',
    databaseURL: 'https://fire-check-db-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'fire-check-db.firebasestorage.app',
    measurementId: 'G-GFYMP49EYF',
  );

}