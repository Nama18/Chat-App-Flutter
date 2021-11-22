import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotifController {
  static Future initLocalNotification() async {
    final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    if (Platform.isIOS) {
      var initializationSettingsAndroid =
          AndroidInitializationSettings('icon_notification');
      var initializationSettingsIOS = IOSInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: (id, title, body, payload) async {},
      );
      var initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onSelectNotification: (payload) async {},
      );
    } else {
      var initializationSettingsAndroid =
          AndroidInitializationSettings('icon_notification');
      var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) async {},
      );
      var initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onSelectNotification: (payload) async {},
      );
    }
  }

  static Future<void> sendNotification({
    String type,
    String myLastChat,
    String myUid,
    String myName,
    String photo,
    String personToken,
  }) async {
    String serverKey =
        'AAAAZPTZ0P8:APA91bEj_xhtb0-mDRaQHoFkzHMDbdaxGmXCf2Vw4uofddyefYq1YyoCKjv5hi62yT3fhYKZG_7FePTelfPUw3fpgqgN1uxI_ukf1Fewx7ohsVjVfe7iP_dEkfpHa1dlW_y9cHEFjVxn';
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=$serverKey',
        },
        body: json.encode(
          {
            'notification': {
              'body': type == 'text'
                  ? myLastChat.length >= 25
                      ? myLastChat.substring(0, 25) + '...'
                      : myLastChat
                  : '<Image>',
              'title': myName,
              "sound": "default",
              'tag': myUid,
            },
            'priority': 'high',
            'to': personToken,
          },
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  static Future<String> getTokenFromDevice() async {
    String token = '';
    try {
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      String vapidKey =
          'BLCcXfDs4Vo6_MFoA8Obn7Ok3d4Gh414jWRqKidtzS2UU7VmZAMh-JufWfazZu1Yc0l0unOuNgTL7pPxu8DrG2c';
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        token = await FirebaseMessaging.instance.getToken(vapidKey: vapidKey);
        print('User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        FirebaseMessaging.instance.getToken(vapidKey: vapidKey).then((value) {
          print('token : $value');
        });
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
      }

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('A new onMessageOpenedApp event was published!');
      });
    } catch (e) {
      print(e.message);
    }
    return token;
  }
}
