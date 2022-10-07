import 'package:cloud_firestore/cloud_firestore.dart';

class Outstanding {
  final String? propertyID;
  final int? timestamp;
  final int? outstandingBalance;
  final Map<String, dynamic>? propertyInfo;

  Outstanding({this.timestamp, this.propertyID, this.outstandingBalance, this.propertyInfo});

  Map<String, dynamic> toMap() {
    return {
      "propertyID": propertyID,
      "timestamp": timestamp,
      "outstandingBalance": outstandingBalance,
      "propertyInfo": propertyInfo,
    };
  }

  factory Outstanding.fromDocument(DocumentSnapshot doc) {
    return Outstanding(
      propertyID: doc.get("propertyID") ?? "",
      timestamp:  doc.get("timestamp") ?? "",
      outstandingBalance:  doc.get("outstandingBalance") ?? "",
      propertyInfo:  doc.get("propertyInfo") ?? "",
    );
  }
}