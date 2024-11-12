import 'dart:io';

import 'package:chatterjii/features/Messages/Messagerepo.dart';
import 'package:chatterjii/features/Messages/latestCubit.dart';
import 'package:chatterjii/features/Messages/messagedatamodel.dart';
import 'package:chatterjii/features/auth/authrepo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

abstract class SendMessageState {}

class SendMessageInitial extends SendMessageState {}

class SendMessageLoading extends SendMessageState {}

class MessageSent extends SendMessageState {
  final Message message;

  MessageSent({required this.message});
}

class SendMessageError extends SendMessageState {
  final String error;

  SendMessageError(this.error);
}

class SendMessageCubit extends Cubit<SendMessageState> {
  SendMessageCubit(this.messageRepository, this.latestMessageCubit)
      : super(SendMessageInitial());

  final MessageRepository messageRepository;
  final LatestMessageCubit latestMessageCubit;

  Future<void> sendMessage(
      String receiver, String rname, String? content, String? imagefile) async {
    emit(SendMessageLoading());

    try {
      final messageData = await messageRepository.sendMessage(
        AuthRepository.getCurrentUser()!.uid,
        receiver,
        content,
        AuthRepository.getCurrentUser()!.displayName as String,
        rname,
        imagefile,
      );
      print(messageData);
      final newMessage = Message(
        id: messageData['id'],
        sender: messageData['sender'],
        receiver: messageData['receiver'],
        content: messageData['content'],
        sname: messageData['sname'],
        rname: messageData['rname'],
        filename: messageData['filename'],
        createdAt: messageData['createdAt'],
      );
      latestMessageCubit.updateMessages(newMessage);

      emit(MessageSent(message: newMessage));
    } catch (error) {
      emit(SendMessageError(error.toString()));
    }
  }
}
