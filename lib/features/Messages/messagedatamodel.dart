import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String sender;
  final String receiver;
  final String sname;
  final String rname;
  String? content;
  String? filename;
  final Timestamp createdAt;

  Message({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.sname,
    required this.rname,
    this.content,
    required this.createdAt,
    this.filename,
  });

  factory Message.fromFirestore(QueryDocumentSnapshot doc) {
    return Message(
      id: doc.id,
      sender: doc['sender'],
      receiver: doc['receiver'],
      content: doc['content'] ?? "",
      sname: doc['sname'],
      rname: doc['rname'],
      createdAt: doc['createdAt'] as Timestamp,
      filename: doc['filename'] ?? "",
    );
  }
}
