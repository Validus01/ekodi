import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String? transactionID;
  final String? transactionType;//like m-pesa etc
  final String? paymentCategory;// like rent and stuff
  final String? description;
  final int? timestamp;
  final int? actualAmount;
  final int? paidAmount;
  final int? remainingAmount;
  final List<dynamic>? properties;
  final List<dynamic>? serviceProviders;
  final List<dynamic>? tenants;
  final List<dynamic>? units;
  final Map<String, dynamic>? senderInfo;
  final Map<String, dynamic>? receiverInfo;

  Transaction(
      {this.transactionID,
      this.transactionType,
      this.paymentCategory,
      this.description,
      this.timestamp,
      this.actualAmount,
      this.paidAmount,
      this.remainingAmount,
      this.properties,
      this.serviceProviders,
      this.tenants,
      this.senderInfo,
      this.units,
      this.receiverInfo});


  Map<String, dynamic> toMap() {
    return {
      "transactionID": transactionID,
      "transactionType": transactionType,
      "paymentCategory": paymentCategory,
      "description": description,
      "timestamp": timestamp,
      "actualAmount": actualAmount,
      "paidAmount": paidAmount,
      "remainingAmount": remainingAmount,
      "properties": properties,
      "serviceProviders": serviceProviders,
      "tenants": tenants,
      "senderInfo": senderInfo,
      "receiverInfo": receiverInfo,
      "units": units,
    };
  }

  factory Transaction.fromDocument(DocumentSnapshot doc) {
    return Transaction(
      transactionID: doc.id,
      transactionType: doc.get("transactionType") ?? "",
      paymentCategory: doc.get("paymentCategory") ?? "",
      description: doc.get("description") ?? "",
      timestamp: doc.get("timestamp") ?? "",
      actualAmount: doc.get("actualAmount") ?? "",
      paidAmount: doc.get("paidAmount") ?? "",
      remainingAmount: doc.get("remainingAmount") ?? "",
      properties: doc.get("properties") ?? "",
      serviceProviders: doc.get("serviceProviders") ?? "",
      tenants: doc.get("tenants") ?? "",
      senderInfo: doc.get("senderInfo") ?? "",
      receiverInfo: doc.get("receiverInfo") ?? "",
      units: doc.get("units") ?? ""
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> doc) {
    return Transaction(
      transactionID: doc['transactionID'],
      transactionType: doc["transactionType"],
      paymentCategory: doc["paymentCategory"],
      description: doc["description"],
      timestamp: doc["timestamp"],
      actualAmount: doc["actualAmount"],
      paidAmount: doc["paidAmount"],
      remainingAmount: doc["remainingAmount"],
      properties: doc["properties"],
      serviceProviders: doc["serviceProviders"],
      tenants: doc["tenants"],
      senderInfo: doc["senderInfo"],
      receiverInfo: doc["receiverInfo"],
      units: doc["units"],
    );
  }

  static String encode(List<Transaction> transactions) => json.encode(
      transactions.map<Map<String, dynamic>>((transaction) => transaction.toMap()).toList());


  static List<Transaction> decode(String transactionsString) {
    if(transactionsString.isNotEmpty) {
      return (json.decode(transactionsString) as List<dynamic>).map<Transaction>((item) => Transaction.fromJson(item)).toList();
    } else {
      return [];
    }
  }

}