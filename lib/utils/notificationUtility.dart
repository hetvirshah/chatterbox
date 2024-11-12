import 'dart:isolate';
import 'dart:ui';

import 'package:chatterjii/app/firebase_options.dart';
import 'package:chatterjii/features/notification/notificationCubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'dart:async';

class NotificationUtility {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //setting up local notification

  static Future<void> setUpNotificationService(
    BuildContext buildContext,
  ) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: DarwinInitializationSettings());
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    NotificationSettings notificationSettings =
        await FirebaseMessaging.instance.getNotificationSettings();

    if (notificationSettings.authorizationStatus ==
            AuthorizationStatus.notDetermined ||
        notificationSettings.authorizationStatus ==
            AuthorizationStatus.denied) {
      notificationSettings =
          await FirebaseMessaging.instance.requestPermission();
    }
    if (buildContext.mounted) {
      initNotificationListener(buildContext);
    }
  }

  static void initNotificationListener(BuildContext buildContext) {
    FirebaseMessaging.onMessage.listen(foregroundMessageListener);
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((remoteMessage) {
      if (buildContext.mounted) {
        onMessageOpenedAppListener(remoteMessage, buildContext);
      }
    });
  }

//background listener (entry point is needed for background messages)
  @pragma('vm:entry-point')
  static Future<void> onBackgroundMessage(RemoteMessage remoteMessage) async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    if (remoteMessage.data.isNotEmpty) {
      ReceivePort receiver = ReceivePort();
      IsolateNameServer.registerPortWithName(receiver.sendPort, "port1");

      receiver.listen((message) async {
        if (message == "stop") {
          await FlutterRingtonePlayer().stop();
        }
      });

      NotificationUtility()
          .createLocalNotification(dimissable: true, message: remoteMessage);
      //initialising hive this is way of initialising hive when in background Hive.initflutter method will not work.


    
    
      await NotificationCubit().notifiedUser();


    }
  }

  //foreground listener
  static Future<void> foregroundMessageListener(
    RemoteMessage remoteMessage,
  ) async {
    NotificationUtility()
        .createLocalNotification(dimissable: true, message: remoteMessage);
    await NotificationCubit().notifiedUser();
  }

  static void onMessageOpenedAppListener(
    RemoteMessage remoteMessage,
    BuildContext buildContext,
  ) {}

//local notifications method
  Future<void> createLocalNotification({
    required bool dimissable,
    required RemoteMessage message,
  }) async {
    final String title = message.data['title'] ?? "";
    final String body = message.data['body'] ?? "";
    final int id = int.tryParse(message.data['id'] ?? "0") ?? 0;
    print("body is : $body");
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel', // Ensure this matches your notification channel ID
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      playSound: false,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: const DarwinNotificationDetails(
            interruptionLevel: InterruptionLevel.active));

    flutterLocalNotificationsPlugin.show(
        id, title, body, platformChannelSpecifics);
  }
}
