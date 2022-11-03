import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  final String? userID;
  final String? name;
  final String? email;
  final String? phone;
  final String? idNumber;
  final String? accountType;
  final String? photoUrl;
  final List<dynamic>? deviceTokens;
  final bool? verified;
  final Map<String, dynamic>? verification;
  final int? timestamp;

  Account(
      {this.name,
      this.userID,
      this.deviceTokens,
      this.photoUrl,
      this.email,
      this.phone,
      this.idNumber,
      this.verified,
      this.verification,
      this.timestamp,
      this.accountType});

  Map<String, dynamic> toMap() {
    return {
      "userID": userID,
      "name": name,
      "email": email,
      "phone": phone,
      "idNumber": idNumber,
      "accountType": accountType,
      "photoUrl": photoUrl,
      "deviceTokens": deviceTokens,
      "verified": verified,
      "verification": verification,
      "timestamp": timestamp,
    };
  }

  factory Account.fromDocument(DocumentSnapshot doc) {
    return Account(
        userID: doc.id,
        name: doc.get("name") ?? "",
        email: doc.get("email") ?? "",
        phone: doc.get("phone") ?? "",
        idNumber: doc.get("idNumber") ?? "",
        accountType: doc.get("accountType") ?? "",
        photoUrl: doc.get("photoUrl") ?? "",
        deviceTokens: doc.get("deviceTokens") ?? [],
        verified: doc.get("verified") ?? false,
        timestamp:
            doc.get("timestamp") ?? DateTime.now().millisecondsSinceEpoch,
        verification: doc.get("verification") ?? {});
  }

  factory Account.fromJson(Map<String, dynamic> doc) {
    return Account(
        userID: doc["userID"] ?? "",
        name: doc["name"] ?? "",
        email: doc["email"] ?? "",
        phone: doc["phone"] ?? "",
        idNumber: doc["idNumber"] ?? "",
        accountType: doc["accountType"] ?? "",
        photoUrl: doc["photoUrl"] ?? "",
        verified: doc["verified"] ?? false,
        verification: doc["verification"] ?? {},
        timestamp: doc["timestamp"] ?? DateTime.now().millisecondsSinceEpoch,
        deviceTokens: doc["deviceTokens"] ?? []);
  }

  static String encode(List<Account> accounts) => json.encode(accounts
      .map<Map<String, dynamic>>((account) => account.toMap())
      .toList());

  static List<Account> decode(String accountsString) {
    if (accountsString.isNotEmpty) {
      return (json.decode(accountsString) as List<dynamic>)
          .map<Account>((item) => Account.fromJson(item))
          .toList();
    } else {
      return [];
    }
  }
}
