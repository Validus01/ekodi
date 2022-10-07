import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/outstanding.dart';
import '../model/property.dart';
import '../model/unit.dart';

class AddToOutstanding {
  addToOutstanding(Unit unit) async {

    await FirebaseFirestore.instance.collection("properties").doc(unit.propertyID)
        .get().then((querySnapshot) async { //Get property details

      Property property = Property.fromDocument(querySnapshot);

      Outstanding newOutstanding = Outstanding(
        timestamp: DateTime.now().millisecondsSinceEpoch,
        propertyID: property.propertyID,
        outstandingBalance: unit.rent,
        propertyInfo: property.toMap(),
      );

      await FirebaseFirestore.instance.collection("users").doc(property.publisherID)
          .collection("outstanding").doc(property.propertyID).get().then((outstandingSnapshot) async {// check if the outstanding exists
        if(!outstandingSnapshot.exists)// If it does not exist
            {
          // 1. We add the outstanding property
          await FirebaseFirestore.instance.collection("users").doc(property.publisherID)
              .collection("outstanding").doc(property.propertyID).set(newOutstanding.toMap());

          // 2. We add the unit to the outstanding property
          await FirebaseFirestore.instance.collection("users").doc(property.publisherID)
              .collection("outstanding").doc(property.propertyID).collection("units").doc(unit.unitID.toString()).set(unit.toMap());
        }
        else
        { //If the outstanding property exists
          // 1. check if the unit is in it
          await FirebaseFirestore.instance.collection("users").doc(property.publisherID)
              .collection("outstanding").doc(property.propertyID).collection("units").doc(unit.unitID.toString()).get().then((unitSnapshot) async {
            if(!unitSnapshot.exists) //if the unit does not exist
                {// 1. Add the unit
              await FirebaseFirestore.instance.collection("users").doc(property.publisherID)
                  .collection("outstanding").doc(property.propertyID).collection("units").doc(unit.unitID.toString()).set(unit.toMap());

              // 2. Update the outstanding amount
              await outstandingSnapshot.reference.update({
                "outstandingBalance": outstandingSnapshot.get("outstandingBalance") + unit.rent,
              });
            }
          });
        }
      });
    });

  }
}