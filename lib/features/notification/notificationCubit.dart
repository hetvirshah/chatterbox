import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

  Future<void> notifiedUser() async {
    try {
      emit(NotificationInitial());
      var counterBox = Hive.box('counter');

      var counter = counterBox.get(0) ?? 0;
      print("before: $counter");

      counter++;
      await counterBox.put(0, counter);
      print("after: $counter");

      emit(NotificationLoaded(counter: counter));
      print(NotificationLoaded(counter: counter).counter);
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
