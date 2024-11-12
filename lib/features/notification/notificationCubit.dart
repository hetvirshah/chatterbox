import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final int counter;

  NotificationLoaded({required this.counter});
}

class NotificationError extends NotificationState {
  final String error;

  NotificationError(this.error);
}

class NotificationCubit extends Cubit<NotificationState> {
  static final NotificationCubit _instance = NotificationCubit._internal();

  factory NotificationCubit() {
    return _instance;
  }

  NotificationCubit._internal() : super(NotificationInitial()) {
    loadNotifications();
  }

  final String fcmUrl =
      'https://fcm.googleapis.com/v1/projects/chatterjii/messages:send';

  Future<void> sendNotification(String title, String body, int id) async {
    final notificationData = {
      "message": {
        "token":
            "dgbNmTrsQfOSX6UEGLF2oK:APA91bGJy42WC2iApknW-oa4aKbWnKqi9eHkNWXKcznRILQgiAKIexNo7_p5NQA2_g4y-VxdrYXz3LjnN6iyMovrnJA8A82LNY7zPtoJrxzUSxKQP9-6cgc",
        "data": {"title": title, "body": body, "id": id.toString()}
      }
    };

    try {
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ya29.a0AeDClZDNGrxUdZUIYH1v5aXp1rKmB9MQl20szKRjwht8Jdx6CZEiZyXYpCD0YFhyr72_xMNHheVKr-ES_9re1bgh6Er2K6m35wuBR9Xw1nfCeLnJ2QDFmooA7Dw_m9iJ1jjALR8PE2X34wPXfa22KunAno-4_1IH4ij7_P7rMAaCgYKAWcSARISFQHGX2MiilspqxCkzDnxjX1GVUMuGQ0177',
        },
        body: json.encode(notificationData),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> notifiedUser() async {
    try {
      emit(NotificationInitial());
      var counterBox = Hive.box('counter');

      var counter = counterBox.get(0) ?? 0;
      print("before: $counter");

      counter++;
      await counterBox.put(0, counter);

      emit(NotificationLoaded(counter: counter));
    } catch (e) {
      print("Error: $e");
      emit(NotificationError(e.toString()));
    }
  }

  int counterNotification() {
    if (state is NotificationLoaded) {
      return (state as NotificationLoaded).counter;
    }
    return 0;
  }

  void loadNotifications() async {
    try {
      var counterBox = Hive.box('counter');
      var counter = counterBox.get(0) ?? 0;
      print("after: $counter");
      emit(NotificationLoaded(counter: counter));
    } catch (e) {
      print("Error: $e");
      emit(NotificationError(e.toString()));
    }
  }
}
