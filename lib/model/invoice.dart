import 'package:cloud_firestore/cloud_firestore.dart';

class Invoice {
  final String? invoiceID;
  final int? timestamp;
  final Map<String, dynamic>? senderInfo;//sending payment
  final Map<String, dynamic>? receiverInfo; //receiving payment
  final Map<String, dynamic>? unitInfo;
  final Map<String, dynamic>? propertyInfo;
  final List<dynamic>? bills;
  final String? pdfUrl;
  final bool? isPaid;

  Invoice(
      {required this.invoiceID,
        required this.timestamp,
        required this.senderInfo,
        required this.receiverInfo,
        required this.bills,
        required this.pdfUrl,
        required this.unitInfo,
        required this.isPaid,
        required this.propertyInfo});

  Map<String, dynamic> toMap() {
    return {
      "invoiceID": invoiceID,
      "timestamp": timestamp,
      "senderInfo": senderInfo,
      "receiverInfo": receiverInfo,
      "propertyInfo": propertyInfo,
      "unitInfo": unitInfo,
      "bills": bills,
      "pdfUrl": pdfUrl,
      "isPaid": isPaid
    };
  }

  factory Invoice.fromDocument(DocumentSnapshot doc) {
    return Invoice(
      invoiceID: doc.get("invoiceID") ?? '',
      timestamp: doc.get("timestamp") ?? '',
      senderInfo: doc.get("senderInfo") ?? '',
      receiverInfo: doc.get("receiverInfo") ?? '',
      unitInfo: doc.get("unitInfo") ?? '',
      propertyInfo: doc.get("propertyInfo") ?? '',
      bills: doc.get("bills") ?? '',
      pdfUrl: doc.get("pdfUrl") ?? '',
      isPaid: doc.get("isPaid") ?? '',
    );
  }
}


class Bill {
  final int? timestamp;
  final String? billType;
  final String? details;
  final int? period;
  final int? paidAmount;
  final int? actualAmount;
  final int? balance;
  final bool? isPaid;

  Bill({
    required this.timestamp,
    required this.billType,
    required this.details,
    required this.period,
    required this.paidAmount,
    required this.actualAmount,
    required this.balance,
    required this.isPaid});

  Map<String, dynamic> toMap() {
    return {
      "timestamp": timestamp,
      "billType": billType,
      "details": details,
      "period": period,
      "paidAmount": paidAmount,
      "actualAmount": actualAmount,
      "balance": balance,
      "isPaid": isPaid

    };
  }
}