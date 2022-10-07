import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rekodi/model/account.dart';
import 'package:rekodi/model/unit.dart';
import 'package:uuid/uuid.dart';

import '../APIs/pdfInvoiceApi.dart';
import '../model/invoice.dart';
import '../model/property.dart';

class AutoGenerate {

  autoGenerateInvoice(Account account, List<Property> properties) async {
    for (Property property in properties)
      {
        if(property.occupied! > 0) {
          await FirebaseFirestore.instance.collection("properties")
              .doc(property.propertyID).collection("units")
              .where("isOccupied", isEqualTo:  true).get().then((unitsSnapshot) async {
                for (var element in unitsSnapshot.docs) {
                  Unit unit = Unit.fromDocument(element);

                  if(unit.dueDate! >= DateTime.now().millisecondsSinceEpoch)
                    {
                      //generate unpaid invoice for tenant

                      await createInvoiceForTenant(account, property, unit);
                    }
                }});
        }
      }
  }

  int calculatePeriod(Unit unit) {
    switch (unit.paymentFreq) {
      case "One-Time(Airbnb)":
        return  30;//monthly basis
      case "Weekly":
        return 7;
      case "Monthly":
        return 30;
      case "Bi-Annually(6 Months)":
        return 180;
      case "Yearly":
        return 360;
      default:
        return 30;//monthly basis
    }
  }


  createInvoiceForTenant(Account account, Property property, Unit unit) async {
    int period = calculatePeriod(unit);

    String invoiceID = Uuid().v4().split("-").first;

    Invoice invoiceDetails = Invoice(
      invoiceID: invoiceID.toUpperCase(),
      timestamp: DateTime.now().millisecondsSinceEpoch,
      senderInfo: account.toMap(),
      receiverInfo: unit.tenantInfo,
      pdfUrl: '',
      isPaid: false,
      bills: [
        Bill(
          timestamp: DateTime.now().millisecondsSinceEpoch,
          billType: "Rent",
          details: "",
          period: period,
          paidAmount: 0,
          actualAmount: unit.rent,
          balance: unit.rent,
          isPaid: false,
        ).toMap(),
      ],
      unitInfo: unit.toMap(),
      propertyInfo: property.toMap(),
    );

    //save pdf to document
    final String pdfUrl = await PdfInvoiceApi.generateInvoice(account, invoiceDetails);

    Invoice invoiceFinal = Invoice(
      invoiceID: invoiceID.toUpperCase(),
      timestamp: DateTime.now().millisecondsSinceEpoch,
      senderInfo: account.toMap(),
      receiverInfo: unit.tenantInfo,
      pdfUrl: pdfUrl,
      isPaid: false,
      bills: [
        Bill(
          timestamp: DateTime.now().millisecondsSinceEpoch,
          billType: "Rent",
          details: "",
          period: period,
          paidAmount: 0,
          actualAmount: unit.rent,
          balance: unit.rent,
          isPaid: false,
        ).toMap(),
      ],
      unitInfo: unit.toMap(),
      propertyInfo: property.toMap(),
    );

    await uploadInvoiceInfo(invoiceFinal);

  }

  uploadInvoiceInfo(Invoice invoice) async {
    //1.1 record invoice to tenant
    await FirebaseFirestore.instance.collection("users").doc(invoice.senderInfo!["userID"])
        .collection("invoices").doc(invoice.invoiceID).set(invoice.toMap());

    //2.1 record invoice to landlord
    await FirebaseFirestore.instance.collection("users").doc(invoice.unitInfo!["publisherID"])
        .collection("invoices").doc(invoice.invoiceID).set(invoice.toMap());

    //2.2 record invoice to property
    await FirebaseFirestore.instance.collection("properties").doc(invoice.unitInfo!["propertyID"])
        .collection("invoices").doc(invoice.invoiceID).set(invoice.toMap());
  }

}