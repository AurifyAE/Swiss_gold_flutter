import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/services/cart_service.dart';
import 'package:swiss_gold/core/services/product_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FcmService.setupFlutterNotifications();
  FcmService.showFlutterNotification(message);

  print('Handling a background message ${message.data}');
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingForegroundHandler(RemoteMessage message) async {
  print('Handling a foreground message ${message.data}');

  FcmService.showFlutterNotification(message);
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // handle action
}

class FcmService {
  static late AndroidNotificationChannel channel;
  static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  static bool isFlutterLocalNotificationsInitialized = false;

  static Future<String?> getToken() async {
    String? token;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      token = await FirebaseMessaging.instance.getAPNSToken();
    } else {
      token = await FirebaseMessaging.instance.getToken();
    }
    return token;
  }

  static void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    String jsonData = jsonEncode(message.data);

    flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.data['title'],
      message.data['body'],
      payload: jsonData,
      NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            actions: message.data['type'] != null
                ? <AndroidNotificationAction>[
                    AndroidNotificationAction(
                      'ACCEPT',
                      'Accept',
                      titleColor: Colors.green,
                      // icon: DrawableResourceAndroidBitmap("ic_accept"),
                      showsUserInterface: true,
                    ),
                    AndroidNotificationAction(
                      'DECLINE',
                      'Decline',
                    
                      titleColor: Colors.red,
                      // icon: DrawableResourceAndroidBitmap("ic_reject"),
                      showsUserInterface: true,
                    ),
                  ]
                : null,
            importance: Importance.max,
            priority: Priority.max,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentBanner: true,
              presentSound: true)),
    );
  }

  static void requestPermission() {
    FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  static Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        Map<String, dynamic> fcmData =
            jsonDecode(notificationResponse.payload!);
        if (notificationResponse.actionId == 'ACCEPT') {

          CartService.confirmQuantity({
            'action': true,
            'itemId': fcmData['itemId'],
            'orderId': fcmData['orderId']
          });
        }
        else if (notificationResponse.actionId == 'DECLINE') {
          CartService.confirmQuantity({
            'action': false,
            'itemId': fcmData['itemId'],
            'orderId': fcmData['orderId']
          });
        }
        return;
      },
    );
    isFlutterLocalNotificationsInitialized = true;
  }
}
