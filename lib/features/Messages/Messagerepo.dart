import 'dart:io';

import 'package:chatterjii/features/Messages/messagedatamodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class MessageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String generateChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join("_");
  }

  Stream<List<Message>> latestMessages(String currentUserId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .asyncMap((querySnapshot) async {
      List<Message> latestMessages = [];

      for (var doc in querySnapshot.docs) {
        String chatId = doc.id;

        var messageSnapshot = await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();

        if (messageSnapshot.docs.isNotEmpty) {
          latestMessages.add(Message.fromFirestore(messageSnapshot.docs.last));
        }
      }
      latestMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return latestMessages;
    });
  }

  Stream<List<Message>> getConversations(String userId1, String userId2) {
    String chatId = generateChatId(userId1, userId2);
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());
  }

  Future<Map<String, dynamic>> sendMessage(String sender, String receiver,
      String? content, String sname, String rname, String? imageFile) async {
    try {
      String chatId = generateChatId(sender, receiver);

      DocumentReference messageRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();
      String messageId = messageRef.id;
      Map<String, dynamic> messageData = {
        'id': messageId,
        'sender': sender,
        'receiver': receiver,
        'sname': sname,
        'rname': rname,
        'content': content,
        'filename': imageFile,
        'createdAt': Timestamp.now(),
      };

      await messageRef.set(messageData);

      DocumentReference chatRef =
          FirebaseFirestore.instance.collection('chats').doc(chatId);
      DocumentSnapshot chatSnapshot = await chatRef.get();
      if (!chatSnapshot.exists) {
        await chatRef.set({
          'chatId': chatId,
          'participants': [sender, receiver],
        });
      }

      return messageData;
    } catch (e) {
      print('Error sending message: $e');
      return {};
    }
  }
}
