
import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyImages {
  final int? timestamp;
  final List<dynamic>? imageUrls;

  PropertyImages({this.timestamp, this.imageUrls});

  Map<String, dynamic> toMap() {
    return {
      "timestamp": timestamp,
      "imageUrls": imageUrls,
    };
  }

  factory PropertyImages.fromDocument(DocumentSnapshot doc) {
    return PropertyImages(
      timestamp: doc.get("timestamp") ?? "",
      imageUrls: doc.get("imageUrls") ?? "",
    );
  }
}