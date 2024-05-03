// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAibrIFbzoWEfN566zn6c4mmp7ZPaRjYTQ',
    appId: '1:980740290537:web:2c83577405c6cb749d3d78',
    messagingSenderId: '980740290537',
    projectId: 're-simplified',
    authDomain: 're-simplified.firebaseapp.com',
    storageBucket: 're-simplified.appspot.com',
    measurementId: 'G-KV0LHQSJLH',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB0V-81c7kp8b7xl2_cdJfef7yfMfDbiqQ',
    appId: '1:980740290537:android:ba1badc94fd783399d3d78',
    messagingSenderId: '980740290537',
    projectId: 're-simplified',
    storageBucket: 're-simplified.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAlEgEnc8vQ36-G6jFfAYxumjFKZc9PQPM',
    appId: '1:980740290537:ios:a16a790782347bc79d3d78',
    messagingSenderId: '980740290537',
    projectId: 're-simplified',
    storageBucket: 're-simplified.appspot.com',
    iosBundleId: 'com.example.resimplified.reSimplifed',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAlEgEnc8vQ36-G6jFfAYxumjFKZc9PQPM',
    appId: '1:980740290537:ios:8b623f730e1ef8c69d3d78',
    messagingSenderId: '980740290537',
    projectId: 're-simplified',
    storageBucket: 're-simplified.appspot.com',
    iosBundleId: 'com.example.resimplified.reSimplifed.RunnerTests',
  );
}
