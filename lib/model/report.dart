import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String? reportID;
  final String? name;
  final String? url;
  final int? timestamp;
  final String? period;

  Report({this.reportID, this.name, this.url, this.timestamp, this.period});

  Map<String, dynamic> toMap() {
    return {
      "reportID": reportID,
      "name": name,
      "url": url,
      "period": period,
      "timestamp": timestamp,
    };
  }

  factory Report.fromDocument(DocumentSnapshot doc) {
    return Report(
        reportID: doc["reportID"],
        name: doc["name"],
        url: doc["url"],
        period: doc["period"],
        timestamp: doc["timestamp"]);
  }
}
