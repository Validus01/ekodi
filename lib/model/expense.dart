import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String? expenseID;
  final String? description;
  final int? amount;
  final int? timestamp;
  final bool? isAll;
  final List<dynamic>? properties;
  //todo add payment category

  Expense({this.description, this.expenseID, this.isAll, this.properties, this.amount, this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      "expenseID": expenseID,
      "description": description,
      "amount": amount,
      "timestamp": timestamp,
      "properties": properties,
      "isAll": isAll
    };
  }

  factory Expense.fromDocument(DocumentSnapshot doc) {
    return Expense(
      expenseID: doc.id,
      description: doc.get("description") ?? '',
      amount: doc.get("amount") ?? '',
      timestamp: doc.get("timestamp") ?? '',
      properties: doc.get("properties") ?? '',
      isAll: doc.get("isAll") ?? '',
    );
  }

}