import 'package:cloud_firestore/cloud_firestore.dart';

class ScreeningData {
  final int? timestamp;
  final bool? isScreened;
  final Map<String, dynamic>? landlordInfo;
  final Map<String, dynamic>? tenantInfo;

  ScreeningData(
      {this.timestamp, this.isScreened, this.landlordInfo, this.tenantInfo});

  Map<String, dynamic> toMap() {
    return {
      "timestamp": timestamp,
      "isScreened": isScreened,
      "landlordInfo": landlordInfo,
      "tenantInfo": tenantInfo
    };
  }

  factory ScreeningData.fromDocument(DocumentSnapshot doc) {
    return ScreeningData(
      timestamp: doc.get("timestamp") ?? "",
      isScreened: doc.get("isScreened") ?? "",
      landlordInfo: doc.get("landlordInfo") ?? "",
      tenantInfo: doc.get("tenantInfo") ?? "",
    );
  }

}