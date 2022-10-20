import 'package:cloud_firestore/cloud_firestore.dart';

class LocationInfo {
  final String? locationID;
  final double? latitude;
  final double? longitude;
  final int? timestamp;

  LocationInfo({this.locationID, this.latitude, this.longitude, this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      "locationID": locationID,
      "latitude": latitude,
      "longitude": longitude,
      "timestamp": timestamp,
    };
  }

  factory LocationInfo.fromDocument(DocumentSnapshot doc) {
    return LocationInfo(
      locationID: doc.id,
      latitude: doc["latitude"],
      longitude: doc["longitude"],
      timestamp: doc["timestamp"],
    );
  }
}