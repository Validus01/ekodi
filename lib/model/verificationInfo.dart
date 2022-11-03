import 'package:cloud_firestore/cloud_firestore.dart';

class VerificationInfo {
  final String? id;
  final String? view;
  final String? timestamp;
  final String? url;

  VerificationInfo({this.id, this.view, this.timestamp, this.url});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "view": view,
      "url": url,
      "timestamp": timestamp,
    };
  }

  factory VerificationInfo.fromDocument(DocumentSnapshot doc) {
    return VerificationInfo(
      id: doc["id"] ?? "",
      view: doc["view"] ?? "",
      url: doc["url"] ?? "",
      timestamp: doc["timestamp"] ?? "0",
    );
  }
}
