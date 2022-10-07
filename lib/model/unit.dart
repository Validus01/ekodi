import 'package:cloud_firestore/cloud_firestore.dart';

class Unit {
  final String? name;
  final String? description;
  final int? unitID;
  final Map<String, dynamic>? tenantInfo;
  final bool? isOccupied;
  final int? rent;
  final int? deposit;
  final int? dueDate;
  final int? startDate;
  final String? propertyID;
  final String? paymentFreq;
  final int? reminder;
  final String? publisherID;
  final bool? isAccepted;

  Unit({
    this.name,
    this.tenantInfo,
    this.rent,
    this.propertyID,
    this.dueDate,
    this.isOccupied,
    this.unitID,
    this.description,
    this.startDate,
    this.deposit,
    this.paymentFreq,
    this.reminder,
    this.publisherID,
    this.isAccepted,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "description": description,
      "unitID": unitID,
      "tenantInfo": tenantInfo,
      "isOccupied": isOccupied,
      "rent": rent,
      "dueDate": dueDate,
      "propertyID": propertyID,
      "startDate": startDate,
      "deposit": deposit,
      "paymentFreq": paymentFreq,
      "reminder": reminder,
      "publisherID": publisherID,
      "isAccepted": isAccepted,
    };
  }

  factory Unit.fromDocument(DocumentSnapshot doc) {
    return Unit(
      name: doc.get("name") ?? "",
      description: doc.get("description") ?? "",
      unitID: doc.get("unitID") ?? "",
      tenantInfo: doc.get("tenantInfo") ?? "",
      isOccupied: doc.get("isOccupied") ?? "",
      rent: doc.get("rent") ?? "",
      dueDate: doc.get("dueDate") ?? "",
      propertyID: doc.get("propertyID") ?? "",
      deposit: doc.get("deposit") ?? "",
      startDate: doc.get("startDate") ?? "",
      paymentFreq: doc.get("paymentFreq") ?? "",
      reminder: doc.get("reminder") ?? "",
      publisherID: doc.get("publisherID") ?? "",
        isAccepted: doc.get("isAccepted") ?? ""
    );
  }
}