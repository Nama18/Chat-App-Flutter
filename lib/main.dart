import 'package:chatapp_flutter/page/dashboard.dart';
import 'package:chatapp_flutter/page/login.dart';
import 'package:chatapp_flutter/utils/notif_controller.dart';
import 'package:chatapp_flutter/utils/prefs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'utils/prefs.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  NotifController.initLocalNotification();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: Prefs.getPerson(),
        builder: (context, snapshot) {
          if (snapshot.hasData && !snapshot.hasError && snapshot.data != null) {
            return Dashboard();
          } else {
            return Login();
          }
        },
      ),
    );
  }
}
