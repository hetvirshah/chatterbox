import 'package:chatterjii/features/Messages/Messagerepo.dart';
import 'package:chatterjii/features/Messages/latestCubit.dart';
import 'package:chatterjii/features/Messages/messagedatamodel.dart';
import 'package:chatterjii/features/auth/authrepo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  Future<void> sendMessage({
    required String receiver,
    required String content,
    required String rname,
  }) async {
    emit(SendMessageLoading());

    try {
      final messageData = await messageRepository.sendMessage(
        sender: AuthRepository.getCurrentUser()!.uid,
        receiver: receiver,
        content: content,
        sname: AuthRepository.getCurrentUser()!.displayName as String,
        rname: rname,
      );

      final newMessage = Message(
        id: messageData['id'],
        sender: messageData['sender'],
        receiver: messageData['receiver'],  
        content: messageData['content'],
        sname: messageData['sname'],
        rname: messageData['rname'],
        createdAt: messageData['createdAt'],
      );
      latestMessageCubit.updateMessages(newMessage);

      emit(MessageSent(message: newMessage));
    } catch (error) {
      emit(SendMessageError(error.toString()));
    }
  }
}
