import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  static FirebaseOptions web = FirebaseOptions(
    apiKey: '${dotenv.env['WEB_API_KEY']}',
    appId: '1:${dotenv.env['APP_ID']}:web:${dotenv.env['WEB']}',
    messagingSenderId: '${dotenv.env['APP_ID']}',
    projectId: '${dotenv.env['PROJECT_ID']}',
    authDomain: '${dotenv.env['PROJECT_ID']}.firebaseapp.com',
    storageBucket: '${dotenv.env['PROJECT_ID']}.firebasestorage.app',
    measurementId: 'G-NPCGC4SD3W',
  );

  static FirebaseOptions android = FirebaseOptions(
    apiKey: '${dotenv.env['ANDROID_API_KEY']}',
    appId: '1:${dotenv.env['APP_ID:android']}:${dotenv.env['ANDROID']}',
    messagingSenderId: '${dotenv.env['APP_ID']}',
    projectId: '${dotenv.env['PROJECT_ID']}',
    storageBucket: '${dotenv.env['PROJECT_ID']}.firebasestorage.app',
  );

  static FirebaseOptions ios = FirebaseOptions(
    apiKey: '${dotenv.env['IOS_API_KEY']}',
    appId: '1:${dotenv.env['APP_ID']}:ios:${dotenv.env['IOS']}',
    messagingSenderId: '${dotenv.env['APP_ID']}',
    projectId: '${dotenv.env['PROJECT_ID']}',
    storageBucket: '${dotenv.env['PROJECT_ID']}.firebasestorage.app',
    iosBundleId: 'com.kreata.universalExam',
  );

  static FirebaseOptions macos = FirebaseOptions(
    apiKey: '${dotenv.env['IOS_API_KEY']}',
    appId: '1:${dotenv.env['APP_ID']}:ios:${dotenv.env['IOS']}',
    messagingSenderId: '${dotenv.env['APP_ID']}',
    projectId: '${dotenv.env['PROJECT_ID']}',
    storageBucket: '${dotenv.env['PROJECT_ID']}.firebasestorage.app',
    iosBundleId: 'com.kreata.universalExam',
  );

  static FirebaseOptions windows = FirebaseOptions(
    apiKey: '${dotenv.env['WEB_API_KEY']}',
    appId: '1:${dotenv.env['APP_ID']}:web:${dotenv.env['WINDOWS']}',
    messagingSenderId: '${dotenv.env['APP_ID']}',
    projectId: '${dotenv.env['PROJECT_ID']}',
    authDomain: '${dotenv.env['PROJECT_ID']}.firebaseapp.com',
    storageBucket: '${dotenv.env['PROJECT_ID']}.firebasestorage.app',
    measurementId: 'G-X4WEFY0DW0',
  );
}
