import 'package:chatterjii/features/Messages/MessageCubit.dart';
import 'package:chatterjii/features/Messages/latestCubit.dart';
import 'package:chatterjii/features/Messages/sendCubit.dart';
import 'package:chatterjii/features/auth/authrepo.dart';
import 'package:chatterjii/ui/widgets/errorcontainer.dart';
import 'package:chatterjii/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChatsList extends StatefulWidget {
  final String? peerId;
  final String? peerName;

  const ChatsList({super.key, this.peerId, this.peerName});

  @override
  _ChatsListState createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();

    Future.delayed(Duration.zero, () {
      fetchConversations();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void fetchConversations() {
    context.read<MessageCubit>().fetchConversations(
          receiver: widget.peerId ?? 'unknown',
        );
  }

  void sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    context.read<SendMessageCubit>().sendMessage(
        receiver: widget.peerId ?? 'unknown',
        content: _messageController.text.trim(),
        rname: widget.peerName ?? 'anonymous');

    _messageController.clear();
  }

  Widget noData() {
    return const Center(
      child: Text(
        'Don\'t be shy,say hi.',
        style: TextStyle(fontSize: 18, color: Colors.black54),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('HH:mm');
    return BlocListener<SendMessageCubit, SendMessageState>(
      listener: (context, state) {
        if (state is MessageSent) {
          context.read<LatestMessageCubit>().updateMessages(state.message);
        }
      },
      child: BlocConsumer<MessageCubit, MessageState>(
        listener: (context, state) {
          if (state is MessageError) {
            errorContainer(
                errorMessageCode: state.error, onTapRetry: fetchConversations);
          }
        },
        builder: (context, state) {
          if (state is MessageInitial || state is MessageLoading) {
            return Container(color: Colors.white, child: loading());
          } else if (state is MessageLoaded) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 74, 84, 137),
                    Color.fromARGB(255, 14, 37, 165)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                ),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(100),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: AppBar(
                      backgroundColor: Colors.transparent,
                      leading: const CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/person.jpg'),
                      ),
                      title: Center(
                        child: Text(
                          '${widget.peerName}',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                body: Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: state.messages.isEmpty
                              ? noData()
                              : ListView.builder(
                                  reverse: true,
                                  itemCount: state.messages.length,
                                  itemBuilder: (context, index) {
                                    final message = state.messages[index];
                                    final dateTime = message.createdAt.toDate();
                                    final timeString =
                                        dateFormat.format(dateTime);
                                    bool isCurrentUser = message.sender ==
                                        AuthRepository.getCurrentUser()!.uid;
                                    return Align(
                                      alignment: isCurrentUser
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Column(
                                        crossAxisAlignment: isCurrentUser
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 5.0,
                                              horizontal: 3.0,
                                            ),
                                            padding: const EdgeInsets.all(10.0),
                                            decoration: BoxDecoration(
                                              color: isCurrentUser
                                                  ? Colors.indigo
                                                      .withOpacity(0.3)
                                                  : Colors.grey
                                                      .withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  message.content,
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                                const SizedBox(height: 5.0),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '${timeString} min',
                                            textAlign: TextAlign.end,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 10.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.indigo.withOpacity(0.3),
                                  hintText: 'Enter your text..',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send,
                                  color: Color.fromARGB(255, 12, 54, 13)),
                              onPressed: sendMessage,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const Text('Unexpected state');
        },
      ),
    );
  }
}
