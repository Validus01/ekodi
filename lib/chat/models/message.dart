import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String? messageID;
  final String? chatID;
  final String? senderID;
  final String? receiverID;
  final String? messageDescription;
  final String? imageUrl;
  final int? timestamp;
  final bool? isWithImage;
  final bool? seen;
  final Map<String, dynamic>? senderInfo;
  final Map<String, dynamic>? receiverInfo;


  Message(
      {this.messageID,
        this.senderID,
        this.chatID,
        this.receiverID,
        this.messageDescription,
        this.timestamp,
        this.isWithImage,
        this.imageUrl,
        // this.isServiceProvider,
        this.senderInfo,
        this.receiverInfo,
        this.seen});

  Map<String, dynamic> toMap() {
    return {
      "messageID": messageID,
      "senderID": senderID,
      "chatID": chatID,
      "receiverID": receiverID,
      "messageDescription": messageDescription,
      "timestamp": timestamp,
      "isWithImage": isWithImage,
      "seen": seen,
      "senderInfo": senderInfo,
      "imageUrl": imageUrl,
      "receiverInfo": receiverInfo
    };
  }

  factory Message.fromDocument(DocumentSnapshot doc) {
    return Message(
      messageID: doc.id,
      senderID: doc.get("senderID") ?? "",
      receiverID:  doc.get("receiverID") ?? "",
      messageDescription:  doc.get("messageDescription") ?? "",
      timestamp:  doc.get("timestamp") ?? "",
      isWithImage:  doc.get("isWithImage") ?? "",
      chatID:  doc.get("chatID") ?? "",
      senderInfo:  doc.get("senderInfo") ?? "",
      seen:  doc.get("seen") ?? "",
      imageUrl: doc.get("imageUrl") ?? "",
      receiverInfo: doc.get("receiverInfo") ?? "",
    );
  }

  factory Message.fromJson(Map<String, dynamic> doc) {
    return Message(
      messageID: doc['messageID'],
      senderID: doc["senderID"],
      receiverID:  doc["receiverID"],
      messageDescription:  doc["messageDescription"],
      timestamp:  doc["timestamp"],
      isWithImage:  doc["isWithImage"],
      chatID:  doc["chatID"],
      senderInfo:  doc["senderInfo"],
      seen:  doc["seen"],
      imageUrl: doc["imageUrl"],
      receiverInfo: doc["receiverInfo"],
    );
  }

  static String encode(List<Message> messages) => json.encode(
      messages.map<Map<String, dynamic>>((message) => message.toMap()).toList());


  static List<Message> decode(String messagesString) {
    if(messagesString.isNotEmpty) {
      return (json.decode(messagesString) as List<dynamic>).map<Message>((item) => Message.fromJson(item)).toList();
    } else {
      return [];
    }
  }



}