import 'dart:async';

import 'package:chatterjii/features/Messages/Messagerepo.dart';
import 'package:chatterjii/features/Messages/messagedatamodel.dart';
import 'package:chatterjii/features/auth/authrepo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LatestMessageState {}

class LatestMessageInitial extends LatestMessageState {}

class LatestMessageLoading extends LatestMessageState {}

class LatestMessageLoaded extends LatestMessageState {
  final List<Message> latestmessages;

  LatestMessageLoaded({required this.latestmessages});
}

class LatestMessageError extends LatestMessageState {
  final String error;

  LatestMessageError(this.error);
}

class LatestMessageCubit extends Cubit<LatestMessageState> {
  LatestMessageCubit(
    this.messageRepository,
  ) : super(LatestMessageInitial()) {
    fetchMessages();
  }

  final MessageRepository messageRepository;
  StreamSubscription<List<Message>>? latestmessagesListener;
  List<Message> latestmessages = [];

  void fetchMessages() {
    emit(LatestMessageLoading());
    try {
      latestmessagesListener = messageRepository
          .latestMessages(AuthRepository.getCurrentUser()!.uid)
          .listen((messages) {
        latestmessages = messages;
        emit(LatestMessageLoaded(latestmessages: latestmessages));
      });
    } catch (error) {
      emit(LatestMessageError(error.toString()));
    }
  }

  void updateMessages(Message newMessage) {
    if (state is LatestMessageLoaded) {
      List<Message> updatedMessages =
          List.from((state as LatestMessageLoaded).latestmessages);
      print(updatedMessages);
      bool messageUpdated = false;
      for (int i = 0; i < updatedMessages.length; i++) {
        Message existingMessage = updatedMessages[i];
        if ((existingMessage.sender == newMessage.sender &&
                existingMessage.receiver == newMessage.receiver) ||
            (existingMessage.sender == newMessage.receiver &&
                existingMessage.receiver == newMessage.sender)) {
          updatedMessages[i] = newMessage;
          messageUpdated = true;
          break;
        }
      }

      if (messageUpdated) {
        updatedMessages.remove(newMessage);
        updatedMessages.insert(0, newMessage);
      } else {
        updatedMessages.insert(0, newMessage);
      }

      emit(LatestMessageLoaded(latestmessages: updatedMessages));
    }
  }

  @override
  Future<void> close() {
    latestmessagesListener?.cancel();
    return super.close();
  }
}
