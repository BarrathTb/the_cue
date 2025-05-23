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
    apiKey: 'AIzaSyByDVI-79-OLKyyqeE2Rt0zTNFAU0Rbm1k',
    appId: '1:394053275958:web:3625ecd2e822106978a397',
    messagingSenderId: '394053275958',
    projectId: 'thecue-5928d',
    authDomain: 'thecue-5928d.firebaseapp.com',
    storageBucket: 'thecue-5928d.firebasestorage.app',
    measurementId: 'G-DGJ2E8RD07',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBVkhEV_2_xv2CPIwFaFNvjHay8XaZqfTM',
    appId: '1:394053275958:android:7862a6c47301cc4b78a397',
    messagingSenderId: '394053275958',
    projectId: 'thecue-5928d',
    storageBucket: 'thecue-5928d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDe0gHvCEA_5jP5YspABGu7VJpnrSHpdkM',
    appId: '1:394053275958:ios:a4d87e1620e6223b78a397',
    messagingSenderId: '394053275958',
    projectId: 'thecue-5928d',
    storageBucket: 'thecue-5928d.firebasestorage.app',
    iosBundleId: 'com.example.theCue',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDe0gHvCEA_5jP5YspABGu7VJpnrSHpdkM',
    appId: '1:394053275958:ios:a4d87e1620e6223b78a397',
    messagingSenderId: '394053275958',
    projectId: 'thecue-5928d',
    storageBucket: 'thecue-5928d.firebasestorage.app',
    iosBundleId: 'com.example.theCue',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyByDVI-79-OLKyyqeE2Rt0zTNFAU0Rbm1k',
    appId: '1:394053275958:web:a4e01fa3447159db78a397',
    messagingSenderId: '394053275958',
    projectId: 'thecue-5928d',
    authDomain: 'thecue-5928d.firebaseapp.com',
    storageBucket: 'thecue-5928d.firebasestorage.app',
    measurementId: 'G-P2B71Y2697',
  );
}
