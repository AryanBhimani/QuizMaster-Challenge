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
    apiKey: 'AIzaSyDpeSzaYGYoLn7pr6oEU_ERM3EiOCfuF9w',
    appId: '1:510134474236:web:ea2593d06948901da9ce79',
    messagingSenderId: '510134474236',
    projectId: 'quizmaster-challenge-36346',
    authDomain: 'quizmaster-challenge-36346.firebaseapp.com',
    storageBucket: 'quizmaster-challenge-36346.firebasestorage.app',
    measurementId: 'G-L0PK0P8XZM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAqfEz51T0WfHE9Wwswj7zzdKcST2NCtr4',
    appId: '1:510134474236:android:0ac10406bc5d4cc0a9ce79',
    messagingSenderId: '510134474236',
    projectId: 'quizmaster-challenge-36346',
    storageBucket: 'quizmaster-challenge-36346.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAVKLUR2PnZTtr2407yOyyIemu6Q5SDOAo',
    appId: '1:510134474236:ios:74298adaf9c14b6aa9ce79',
    messagingSenderId: '510134474236',
    projectId: 'quizmaster-challenge-36346',
    storageBucket: 'quizmaster-challenge-36346.firebasestorage.app',
    iosBundleId: 'com.example.quizmasterChallenge',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAVKLUR2PnZTtr2407yOyyIemu6Q5SDOAo',
    appId: '1:510134474236:ios:74298adaf9c14b6aa9ce79',
    messagingSenderId: '510134474236',
    projectId: 'quizmaster-challenge-36346',
    storageBucket: 'quizmaster-challenge-36346.firebasestorage.app',
    iosBundleId: 'com.example.quizmasterChallenge',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDpeSzaYGYoLn7pr6oEU_ERM3EiOCfuF9w',
    appId: '1:510134474236:web:06db940b3e1a5982a9ce79',
    messagingSenderId: '510134474236',
    projectId: 'quizmaster-challenge-36346',
    authDomain: 'quizmaster-challenge-36346.firebaseapp.com',
    storageBucket: 'quizmaster-challenge-36346.firebasestorage.app',
    measurementId: 'G-6CDJP5ZH8M',
  );
}
