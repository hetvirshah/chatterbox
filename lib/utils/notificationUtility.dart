import 'package:chatterjii/app/firebase_options.dart';
import 'package:chatterjii/features/notification/notificationCubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
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
      NotificationUtility()
          .createLocalNotification(dimissable: true, message: remoteMessage);
      //initialising hive this is way of initialising hive when in background Hive.initflutter method will not work.
      var appDir = await getApplicationDocumentsDirectory();
      Hive.init(appDir.path);
      await Hive.openBox('counter');
      await NotificationCubit().notifiedUser();
      Hive.box('counter').close();
    }
  }

  //foreground listener
  static Future<void> foregroundMessageListener(
    RemoteMessage remoteMessage,
  ) async {
    await FirebaseMessaging.instance.getToken();

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
    final String title = message.data.values.first ?? "";
    final String body = message.data.values.last ?? "";
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel', // Ensure this matches your notification channel ID
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails(
            interruptionLevel: InterruptionLevel.active));

    flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
