import 'dart:async';

import 'package:chatterjii/features/Messages/Messagerepo.dart';
import 'package:chatterjii/features/Messages/messagedatamodel.dart';
import 'package:chatterjii/features/auth/authrepo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MessageState {}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class MessageLoaded extends MessageState {
  final List<Message> messages;

  MessageLoaded({required this.messages});
}

class MessageError extends MessageState {
  final String error;

  MessageError(this.error);
}

class MessageCubit extends Cubit<MessageState> {
  MessageCubit(
    this.messageRepository,
  ) : super(MessageInitial());

  final MessageRepository messageRepository;

  StreamSubscription<List<Message>>? messagesListener;

  void fetchConversations({required String receiver}) {
    try {
      messagesListener = messageRepository
          .getConversations(AuthRepository.getCurrentUser()!.uid, receiver)
          .listen((messages) {
        emit(MessageLoaded(messages: messages));
      });
    } catch (error) {
      emit(MessageError('Failed to fetch conversations: $error'));
    }
  }

  @override
  Future<void> close() {
    messagesListener?.cancel();
    return super.close();
  }
}
