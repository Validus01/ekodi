import 'package:cloud_firestore/cloud_firestore.dart';

class LeaseExpiry {
  final int? timestamp;
  final int? expiryDate;
  final Map<String, dynamic>? userInfo;
  final Map<String, dynamic>? unitInfo;
  final Map<String, dynamic>? propertyInfo;

  LeaseExpiry(
      {this.timestamp, this.expiryDate, this.propertyInfo, this.userInfo, this.unitInfo});

  Map<String, dynamic> toMap() {
    return {
      "timestamp": timestamp,
      "expiryDate": expiryDate,
      "userInfo": userInfo,
      "unitInfo": unitInfo,
      "propertyInfo": propertyInfo,
    };
  }

  factory LeaseExpiry.fromDocument(DocumentSnapshot doc) {
    return LeaseExpiry(
      timestamp: doc.get("timestamp") ?? "",
      expiryDate: doc.get("expiryDate") ?? "",
      unitInfo: doc.get("unitInfo") ?? "",
      userInfo: doc.get("userInfo") ?? "",
      propertyInfo: doc.get("propertyInfo") ?? "",
    );
  }
}