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

  print('Handling a background message ${message.messageId}');
  print('Background message data: ${message.data}');
  print('Background message notification: ${message.notification?.title}, ${message.notification?.body}');
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingForegroundHandler(RemoteMessage message) async {
  print('Handling a foreground message ${message.messageId}');
  print('Foreground message data: ${message.data}');
  print('Foreground message notification: ${message.notification?.title}, ${message.notification?.body}');

  FcmService.showFlutterNotification(message);
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print('Notification tapped in background with payload: ${notificationResponse.payload}');
  // handle action
}

class FcmService {
  static late AndroidNotificationChannel standardChannel;
  static late AndroidNotificationChannel warningChannel;
  static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  static bool isFlutterLocalNotificationsInitialized = false;

  static Future<String?> getToken() async {
    String? token;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      token = await FirebaseMessaging.instance.getAPNSToken();
    } else {
      token = await FirebaseMessaging.instance.getToken();
    }
    print('FCM Token: $token');
    return token;
  }

  static void showFlutterNotification(RemoteMessage message) {
    String jsonData = jsonEncode(message.data);
    
    // Debug information
    print('Showing notification for message ID: ${message.messageId}');
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}, ${message.notification?.body}');
    
    // Get title and body from either data payload or notification payload
    String? title = message.data['title'] ?? message.notification?.title;
    String? body = message.data['body'] ?? message.notification?.body;
    
    // Determine notification type
    String? notificationType = message.data['type'];
    print('Notification type: $notificationType');
    
    // Choose appropriate channel based on notification type
    AndroidNotificationChannel channel = standardChannel;
    if (notificationType == 'warning') {
      channel = warningChannel;
      print('Using warning channel for notification');
    } else {
      print('Using standard channel for notification');
    }
    
    // Only show notification if we have either title or body
    if (title != null || body != null) {
      // Configure actions for confirmation notifications
      List<AndroidNotificationAction>? actions;
      if (notificationType == 'confirmation') {
        actions = <AndroidNotificationAction>[
          AndroidNotificationAction(
            'ACCEPT',
            'Accept',
            titleColor: Colors.green,
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'DECLINE',
            'Decline',
            titleColor: Colors.red,
            showsUserInterface: true,
          ),
        ];
        print('Adding Accept/Decline actions to notification');
      }
      
      flutterLocalNotificationsPlugin.show(
        message.hashCode,
        title,
        body,
        payload: jsonData,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            actions: actions,
            importance: Importance.max,
            priority: Priority.max,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentBanner: true,
            presentSound: true,
          ),
        ),
      );
      print('Notification displayed with title: $title, body: $body');
    } else {
      print('Warning: Received notification with no title or body - could not display');
    }
  }

  static void requestPermission() {
    FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    ).then((settings) {
      print('FCM permission status: ${settings.authorizationStatus}');
    });
  }

  static Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      print('Flutter notifications already initialized');
      return;
    }
    
    print('Setting up Flutter notifications');
    
    // Set up standard channel for normal notifications
    standardChannel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );
    
    // Set up warning channel with different settings
    warningChannel = const AndroidNotificationChannel(
      'warning_channel',
      'Warning Notifications',
      description: 'This channel is used for warning notifications.',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Create notification channels
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
            
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(standardChannel);
      await androidPlugin.createNotificationChannel(warningChannel);
      print('Created notification channels');
    }

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    print('Set foreground notification presentation options');

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
        print('Notification response received with action: ${notificationResponse.actionId}');
        print('Notification payload: ${notificationResponse.payload}');
        
        if (notificationResponse.payload != null) {
          try {
            Map<String, dynamic> fcmData =
                jsonDecode(notificationResponse.payload!);
            
            if (notificationResponse.actionId == 'ACCEPT') {
              print('Processing ACCEPT action for item: ${fcmData['itemId']}, order: ${fcmData['orderId']}');
              CartService.confirmQuantity({
                'action': true,
                'itemId': fcmData['itemId'],
                'orderId': fcmData['orderId']
              });
            }
            else if (notificationResponse.actionId == 'DECLINE') {
              print('Processing DECLINE action for item: ${fcmData['itemId']}, order: ${fcmData['orderId']}');
              CartService.confirmQuantity({
                'action': false,
                'itemId': fcmData['itemId'],
                'orderId': fcmData['orderId']
              });
            } else {
              print('Notification tapped (no specific action)');
              // Handle general notification tap if needed
            }
          } catch (e) {
            print('Error processing notification response: $e');
          }
        }
        return;
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    
    isFlutterLocalNotificationsInitialized = true;
    print('Flutter notifications initialization complete');
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