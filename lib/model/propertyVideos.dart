import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyVideos {
  final int? timestamp;
  final List<dynamic>? videoUrls;

  PropertyVideos({this.timestamp, this.videoUrls});

  Map<String, dynamic> toMap() {
    return {
      "timestamp": timestamp,
      "videoUrls": videoUrls,
    };
  }

  factory PropertyVideos.fromDocument(DocumentSnapshot doc) {
    return PropertyVideos(
      timestamp: doc.get("timestamp") ?? 0,
      videoUrls: doc.get("videoUrls") ?? [],
    );
  }
}
