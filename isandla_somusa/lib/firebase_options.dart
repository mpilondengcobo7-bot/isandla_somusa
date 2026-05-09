import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCqy2lyYT3NHMlTCiaH2O9ru8d4c87BgvE',
    appId: '1:681278406079:web:71ca5fd82130c46ff5350a',
    messagingSenderId: '681278406079',
    projectId: 'isandla-somusa-bebb1',
    authDomain: 'isandla-somusa-bebb1.firebaseapp.com',
    storageBucket: 'isandla-somusa-bebb1.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCqy2lyYT3NHMlTCiaH2O9ru8d4c87BgvE',
    appId: '1:681278406079:android:71ca5fd82130c46ff5350a',
    messagingSenderId: '681278406079',
    projectId: 'isandla-somusa-bebb1',
    storageBucket: 'isandla-somusa-bebb1.firebasestorage.app',
  );
}