import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDOc9BSny2gHA0s7VsfXzYZnL9ZqiXT4t0',
    authDomain: 'gestion-tramites-26754.firebaseapp.com',
    projectId: 'gestion-tramites-26754',
    storageBucket: 'gestion-tramites-26754.firebasestorage.app',
    messagingSenderId: '345104547307',
    appId: '1:345104547307:web:ff5b568b8331f98b3fedae',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDOc9BSny2gHA0s7VsfXzYZnL9ZqiXT4t0',
    authDomain: 'gestion-tramites-26754.firebaseapp.com',
    projectId: 'gestion-tramites-26754',
    storageBucket: 'gestion-tramites-26754.firebasestorage.app',
    messagingSenderId: '345104547307',
    appId: '1:345104547307:web:ff5b568b8331f98b3fedae',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDOc9BSny2gHA0s7VsfXzYZnL9ZqiXT4t0',
    authDomain: 'gestion-tramites-26754.firebaseapp.com',
    projectId: 'gestion-tramites-26754',
    storageBucket: 'gestion-tramites-26754.firebasestorage.app',
    messagingSenderId: '345104547307',
    appId: '1:345104547307:web:ff5b568b8331f98b3fedae',
  );
}