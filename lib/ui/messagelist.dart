import 'package:chatterjii/features/Messages/latestCubit.dart';
import 'package:chatterjii/features/Messages/messagedatamodel.dart';
import 'package:chatterjii/features/auth/authrepo.dart';
import 'package:chatterjii/app/routes.dart';
import 'package:chatterjii/ui/chatscreen.dart';
import 'package:chatterjii/ui/widgets/errorcontainer.dart';
import 'package:chatterjii/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessagesList extends StatefulWidget {
  @override
  State<MessagesList> createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {
  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  void fetchMessages() {
    context.read<LatestMessageCubit>().fetchMessages();
  }

  Widget noData() {
    return Container(
      child: const Center(
        child: Text(
          'No messages found.',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LatestMessageCubit, LatestMessageState>(
      listener: (context, state) {
        if (state is LatestMessageError) {
          errorContainer(
              errorMessageCode: state.error, onTapRetry: fetchMessages);
        }
      },
      builder: (context, state) {
        if (state is LatestMessageInitial || state is LatestMessageLoading) {
          return loading();
        } else if (state is LatestMessageLoaded) {
          if (state.latestmessages.isEmpty) {
            return noData();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ListView.builder(
              itemCount: state.latestmessages.length,
              itemBuilder: (context, index) {
                final message = state.latestmessages[index];
                String peerId =
                    (message.sender != AuthRepository.getCurrentUser()!.uid)
                        ? message.sender
                        : message.receiver;
                String peerName =
                    (message.sender != AuthRepository.getCurrentUser()!.uid)
                        ? message.sname
                        : message.rname;
                String rname =
                    (message.sender != AuthRepository.getCurrentUser()!.uid)
                        ? message.sname
                        : message.rname;
                final dateTime = message.createdAt.toDate();
                String timeAgo = timeago.format(dateTime);

                return ListTile(
                    leading: const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/person.jpg'),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(rname, style: const TextStyle(fontSize: 16)),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '${message.content}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    onTap: () => Navigator.pushNamed(
                          context,
                          Routes.chats,
                          arguments: {
                            'peerId': peerId,
                            'peerName': peerName,
                          },
                        ));
              },
            ),
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
