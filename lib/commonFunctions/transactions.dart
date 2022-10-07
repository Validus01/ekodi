import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rekodi/model/transaction.dart' as account_transaction;
import 'package:rekodi/model/unit.dart';

import '../model/account.dart';
import '../model/invoice.dart';


class Transactions {


  Future<String> payRent(account_transaction.Transaction transaction, Invoice invoice, Account sender, Account receiver, Unit unit) async {
    try {
      //1. record transaction to Tenant
      await FirebaseFirestore.instance.collection("users").doc(sender.userID)
          .collection("transactions").doc(transaction.transactionID)
          .set(transaction.toMap());

      //1.1 record invoice to tenant
      await FirebaseFirestore.instance.collection("users").doc(sender.userID)
          .collection("invoices").doc(invoice.invoiceID)
          .set(invoice.toMap());

      //2. record transaction to landlord
      await FirebaseFirestore.instance.collection("users").doc(unit.publisherID)
          .collection("transactions").doc(transaction.transactionID)
          .set(transaction.toMap());

      //2.1 record invoice to landlord
      await FirebaseFirestore.instance.collection("users").doc(unit.publisherID)
          .collection("invoices").doc(invoice.invoiceID).set(invoice.toMap());

      //2.2 add transaction to property

      await FirebaseFirestore.instance.collection("properties").doc(unit.propertyID)
          .collection("transactions").doc(transaction.transactionID)
          .set(transaction.toMap());

      //2.2 record invoice to property
      await FirebaseFirestore.instance.collection("properties").doc(unit.propertyID)
          .collection("invoices").doc(invoice.invoiceID).set(invoice.toMap());

      //3.1 push duedate by stated period on the property
      int dueDate = calculateDueDate(unit);

      await FirebaseFirestore.instance.collection("properties").doc(unit.propertyID)
          .collection("units").doc(unit.unitID.toString()).update({
        "dueDate": dueDate,
      });

      //3.2 push duedate by stated period on the tenant

      await FirebaseFirestore.instance.collection("users").doc(sender.userID)
          .collection("units").doc(unit.unitID.toString()).update({
        "dueDate": dueDate,
      });

      //Todo : deduct from outstanding

      //check if unit is in outstanding
      // await FirebaseFirestore.instance.collection("users").doc(property?.publisherID)
      //     .collection("outstanding").doc(property?.propertyID).collection("units")
      //     .doc(unit.unitID.toString()).get().then((value) async {
      //   if(value.exists)
      //   {
      //     await value.reference.delete();
      //
      //     await FirebaseFirestore.instance.collection("users").doc(property?.publisherID)
      //         .collection("outstanding").doc(property?.propertyID).get().then((outstandingSnap) async {
      //       Outstanding outstanding = Outstanding.fromDocument(outstandingSnap);
      //
      //       await outstandingSnap.reference.update({
      //         "outstandingBalance": outstanding.outstandingBalance! - unit.rent!,
      //       });
      //     });
      //   }
      // });

      return "success";
    } catch (e) {

      print(e.toString());

      return "failed";
    }
  }

  int calculateDueDate(Unit unit) {
    switch (unit.paymentFreq) {
      case "One-Time(Airbnb)":
        return  unit.dueDate! + 2.628e+9.toInt();//monthly basis
      case "Weekly":
        return unit.dueDate! + 6.048e+8.toInt();
      case "Monthly":
        return unit.dueDate! + 2.628e+9.toInt();
      case "Bi-Annually(6 Months)":
        return unit.dueDate! + (6 * 2.628e+9).toInt();
      case "Yearly":
        return unit.dueDate! + (12 * 2.628e+9).toInt();
      default:
        return unit.dueDate! + 2.628e+9.toInt();//monthly basis
    }
  }
}