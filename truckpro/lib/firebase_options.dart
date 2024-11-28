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
    apiKey: 'AIzaSyBsvE9sLNao8h6omjARhiWxj_49xOxchBg',
    appId: '1:487639538102:web:e9d4fad2cf8ffc84440917',
    messagingSenderId: '487639538102',
    projectId: 'truckpro-c178e',
    authDomain: 'truckpro-c178e.firebaseapp.com',
    storageBucket: 'truckpro-c178e.firebasestorage.app',
    measurementId: 'G-90PFR1GK2P',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDSmI6uL3ZaVoy3Xqisfmohd2vsMmm-gbE',
    appId: '1:487639538102:android:6eb1eabd785c1a11440917',
    messagingSenderId: '487639538102',
    projectId: 'truckpro-c178e',
    storageBucket: 'truckpro-c178e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB45XmZc9WK8_b5hQiJe3reWLcG9gXrWH0',
    appId: '1:487639538102:ios:175dbe0887e96124440917',
    messagingSenderId: '487639538102',
    projectId: 'truckpro-c178e',
    storageBucket: 'truckpro-c178e.firebasestorage.app',
    iosBundleId: 'com.truckpro.appdev',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB45XmZc9WK8_b5hQiJe3reWLcG9gXrWH0',
    appId: '1:487639538102:ios:cd38671ecc90e8cc440917',
    messagingSenderId: '487639538102',
    projectId: 'truckpro-c178e',
    storageBucket: 'truckpro-c178e.firebasestorage.app',
    iosBundleId: 'com.example.truckpro',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBsvE9sLNao8h6omjARhiWxj_49xOxchBg',
    appId: '1:487639538102:web:a5d72ba11a079da4440917',
    messagingSenderId: '487639538102',
    projectId: 'truckpro-c178e',
    authDomain: 'truckpro-c178e.firebaseapp.com',
    storageBucket: 'truckpro-c178e.firebasestorage.app',
    measurementId: 'G-LNYRCP9QTD',
  );
}