import 'package:cloud_firestore/cloud_firestore.dart';

class RatingItem {
  final String? username;
  final String? email;
  final String? review;
  final int? rating;
  final int? timestamp;

  RatingItem(
      {this.username, this.email, this.review, this.rating, this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      "username": username,
      "email": email,
      "review": review,
      "rating": rating,
      "timestamp": timestamp,
    };
  }

  factory RatingItem.fromDocument(DocumentSnapshot doc) {
    return RatingItem(
        username: doc["username"],
        email: doc["email"],
        review: doc["review"],
        rating: doc["rating"],
        timestamp: doc["timestamp"]);
  }
}
