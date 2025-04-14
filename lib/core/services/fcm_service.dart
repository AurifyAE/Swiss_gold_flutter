import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:swiss_gold/core/services/cart_service.dart';

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



// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';

// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:swiss_gold/core/services/cart_service.dart';
// import 'package:swiss_gold/core/services/local_storage.dart';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();

//   await FcmService.setupFlutterNotifications();
//   FcmService.showFlutterNotification(message);

//   log('Handling a background message ${message.data}');
// }

// @pragma('vm:entry-point')
// Future<void> firebaseMessagingForegroundHandler(RemoteMessage message) async {
//   log('Handling a foreground message ${message.data}');

//   FcmService.showFlutterNotification(message);
// }

// @pragma('vm:entry-point')
// void notificationTapBackground(NotificationResponse notificationResponse) {
//   log('Notification tapped in background: ${notificationResponse.payload}');
//   // Additional handling can be added here if needed
// }

// class FcmService {
//   static late AndroidNotificationChannel channel;
//   static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

//   static bool isFlutterLocalNotificationsInitialized = false;

//   // Initialize notifications early in app lifecycle
//   static Future<void> initializeNotifications() async {
//     await setupFlutterNotifications();
//     await requestNotificationPermission();
    
//     // Get and store initial token
//     String? token = await getToken();
//     if (token != null) {
//       LocalStorage.setString({'fcmToken': token});
//       log('FCM Token stored: $token');
//     }
    
//     // Setup token refresh listener
//     FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
//       log('FCM Token refreshed: $newToken');
//       LocalStorage.setString({'fcmToken': newToken});
      
//       // If user is logged in, update token on server
//       if (!LocalStorage.getBool('isGuest')) {
//         // Call your API to update the token
//         // Example: AuthService.updateFcmToken(newToken);
//       }
//     });
    
//     // Setup notification handling
//     setupNotificationTapHandling();
//   }

//   static Future<String?> getToken() async {
//     String? token;

//     try {
//       if (defaultTargetPlatform == TargetPlatform.iOS) {
//         token = await FirebaseMessaging.instance.getAPNSToken();
//       } else {
//         token = await FirebaseMessaging.instance.getToken();
//       }
//       log('Retrieved FCM token: $token');
//       return token;
//     } catch (e) {
//       log('Error getting FCM token: $e');
//       return null;
//     }
//   }

//   static void showFlutterNotification(RemoteMessage message) {
//     try {
//       RemoteNotification? notification = message.notification;
//       AndroidNotification? android = message.notification?.android;
//       String jsonData = jsonEncode(message.data);
      
//       // Extract title and body from either data or notification object
//       String? title = message.data['title'] ?? message.notification?.title ?? 'Notification';
//       String? body = message.data['body'] ?? message.notification?.body ?? '';
      
//       flutterLocalNotificationsPlugin.show(
//         message.hashCode,
//         title,
//         body,
//         payload: jsonData,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             channel.id,
//             channel.name,
//             actions: message.data['type'] != null
//                 ? <AndroidNotificationAction>[
//                     AndroidNotificationAction(
//                       'ACCEPT',
//                       'Accept',
//                       titleColor: Colors.green,
//                       showsUserInterface: true,
//                     ),
//                     AndroidNotificationAction(
//                       'DECLINE',
//                       'Decline',
//                       titleColor: Colors.red,
//                       showsUserInterface: true,
//                     ),
//                   ]
//                 : null,
//             importance: Importance.max,
//             priority: Priority.max,
//             channelDescription: channel.description,
//             icon: '@mipmap/ic_launcher',
//           ),
//           iOS: const DarwinNotificationDetails(
//             presentAlert: true,
//             presentBadge: true,
//             presentBanner: true,
//             presentSound: true,
//           ),
//         ),
//       );
//     } catch (e) {
//       log('Error showing notification: $e');
//     }
//   }

//   static Future<void> requestNotificationPermission() async {
//     // Request FCM permission
//     await FirebaseMessaging.instance.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );
    
//     // For Android 13+ (API level 33+), request runtime permission
//     if (Platform.isAndroid) {
//       final androidInfo = await DeviceInfoPlugin().androidInfo;
//       if (androidInfo.version.sdkInt >= 33) {
//         final status = await Permission.notification.status;
//         if (status != PermissionStatus.granted) {
//           await Permission.notification.request();
//         }
//       }
//     }
//   }

//   static void openNotificationSettings() async {
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.requestPermission();
//   }

//   static Future<void> setupFlutterNotifications() async {
//     if (isFlutterLocalNotificationsInitialized) {
//       return;
//     }
    
//     channel = const AndroidNotificationChannel(
//       'high_importance_channel',
//       'High Importance Notifications',
//       description: 'This channel is used for important notifications.',
//       importance: Importance.max,
//     );

//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//     // Create notification channel for Android
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);

//     // Set foreground notification presentation options
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     // Initialize local notifications
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
    
//     final DarwinInitializationSettings initializationSettingsIOS =
//         const DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
    
//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: DarwinInitializationSettings(),
//     );
    
//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: handleNotificationResponse,
//       onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
//     );
    
//     isFlutterLocalNotificationsInitialized = true;
//   }
  
//   static Future<void> handleNotificationResponse(NotificationResponse notificationResponse) async {
//     try {
//       if (notificationResponse.payload != null) {
//         Map<String, dynamic> fcmData = jsonDecode(notificationResponse.payload!);
//         log('Notification response received: ${notificationResponse.payload}');
        
//         // Handle notification actions
//         if (notificationResponse.actionId == 'ACCEPT') {
//           CartService.confirmQuantity({
//             'action': true,
//             'itemId': fcmData['itemId'],
//             'orderId': fcmData['orderId']
//           });
//         } else if (notificationResponse.actionId == 'DECLINE') {
//           CartService.confirmQuantity({
//             'action': false,
//             'itemId': fcmData['itemId'],
//             'orderId': fcmData['orderId']
//           });
//         } else {
//           // Handle notification tap (no specific action)
//           _handleNotificationTap(fcmData);
//         }
//       }
//     } catch (e) {
//       log('Error handling notification response: $e');
//     }
//   }
  
//   static void setupNotificationTapHandling() {
//     // For when the app is terminated and opened via notification
//     FirebaseMessaging.instance.getInitialMessage().then((message) {
//       if (message != null) {
//         log('App opened from terminated state via notification');
//         _handleNotificationTap(message.data);
//       }
//     });
    
//     // For when the app is in background and opened via notification
//     FirebaseMessaging.onMessageOpenedApp.listen((message) {
//       log('App opened from background state via notification');
//       _handleNotificationTap(message.data);
//     });
//   }
  
//   static void _handleNotificationTap(Map<String, dynamic> data) {
//     // Navigate based on notification data
//     // Example:
//     if (data.containsKey('type')) {
//       String type = data['type'];
      
//       switch (type) {
//         case 'order':
//           if (data.containsKey('orderId')) {
//             // Navigate to order details
//             // navigatorKey.currentState?.push(MaterialPageRoute(
//             //   builder: (_) => OrderDetailsScreen(orderId: data['orderId']),
//             // ));
//           }
//           break;
//         case 'product':
//           if (data.containsKey('productId')) {
//             // Navigate to product details
//             // navigatorKey.currentState?.push(MaterialPageRoute(
//             //   builder: (_) => ProductDetailsScreen(productId: data['productId']),
//             // ));
//           }
//           break;
//         // Add more types as needed
//       }
//     }
//   }
  
//   // Subscribe to a specific topic
//   static Future<void> subscribeToTopic(String topic) async {
//     await FirebaseMessaging.instance.subscribeToTopic(topic);
//     log('Subscribed to topic: $topic');
//   }
  
//   // Unsubscribe from a specific topic
//   static Future<void> unsubscribeFromTopic(String topic) async {
//     await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
//     log('Unsubscribed from topic: $topic');
//   }
// }