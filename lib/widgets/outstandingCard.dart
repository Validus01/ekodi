import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../config.dart';
import '../model/account.dart';
import '../model/outstanding.dart';

class OutstandingCard extends StatefulWidget {
  const OutstandingCard({Key? key}) : super(key: key);

  @override
  State<OutstandingCard> createState() => _OutstandingCardState();
}

class _OutstandingCardState extends State<OutstandingCard> {
  int outstandingAmount = 0;

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile || sizeInfo.isTablet;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10.0 : 0.0,
            vertical: isMobile ? 5.0 : 0.0,
          ),
          child: Container(
            width: size.width,
            decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(3.0),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 1,
                      spreadRadius: 1.0,
                      offset: Offset(0.0, 0.0))
                ],
                border: Border.all(
                    width: 0.5,
                    color: Colors.grey.shade300)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    "KES $outstandingAmount",
                    style: const TextStyle(
                        fontSize: 25.0,
                        fontWeight:
                        FontWeight.bold),
                  ),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.more_horiz,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const ListTile(
                  title: Text(
                    "Outstanding Balances",
                    style: TextStyle(
                        fontWeight:
                        FontWeight.bold),
                  ),
                  subtitle: Text(
                    "All properties",
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight:
                        FontWeight.bold),
                  ),
                  trailing: Icon(
                    Icons.equalizer,
                    color: Colors.teal,
                    size: 30.0,
                  ),
                ),
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection("users").doc(account.userID)
                      .collection("outstanding").where("outstandingBalance", isGreaterThan: 0)
                      .orderBy("outstandingBalance", descending: true).limit(4).get(),
                  builder: (context, snapshot) {
                    if(!snapshot.hasData)
                    {
                      return Text("Loading...");
                    }
                    else
                    {
                      List<Outstanding> outstandingProperties = [];
                      snapshot.data!.docs.forEach((element) {
                        outstandingProperties.add(Outstanding.fromDocument(element));
                        outstandingAmount = outstandingAmount + Outstanding.fromDocument(element).outstandingBalance!;
                      });

                      if(outstandingProperties.isEmpty)
                      {
                        return Container();
                      }
                      else
                      {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(outstandingProperties.length, (index) {
                            Outstanding outstandingProperty = outstandingProperties[index];

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.5),
                              child: Card(
                                child: ListTile(
                                  title: Text(outstandingProperty.propertyInfo!["name"]),
                                  subtitle: Text("${outstandingProperty.propertyInfo!["address"]}"),
                                  trailing: Text("Kes ${outstandingProperty.outstandingBalance.toString()}"),
                                ),
                              ),
                            );
                          }),
                        );
                      }
                    }
                  },
                )
              ],
            ),
          ),
        );
      }
    );
  }
}
