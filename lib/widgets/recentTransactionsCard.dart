import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/providers/tabProvider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:rekodi/model/transaction.dart' as account_transaction;

import '../config.dart';
import '../model/account.dart';

class RecentTransactionsCard extends StatefulWidget {
  const RecentTransactionsCard({Key? key}) : super(key: key);

  @override
  State<RecentTransactionsCard> createState() => _RecentTransactionsCardState();
}

class _RecentTransactionsCardState extends State<RecentTransactionsCard> {
  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile || sizeInfo.isTablet;

        return Padding(
          padding: EdgeInsets.only(
              right: isMobile ? 10.0 : 5.0,
            left: isMobile ? 10.0 : 0.0,
            top: isMobile ? 5.0 : 0.0,
            bottom: isMobile ? 5.0 : 0.0,
          ),
          child: Container(
            width: size.width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.0),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 1,
                      spreadRadius: 1.0,
                      offset: Offset(0.0, 0.0))
                ],
                border: Border.all(
                    width: 0.5, color: Colors.grey.shade300)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text(
                    'Recent Transactions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: TextButton(
                    onPressed: () {
                      context.read<TabProvider>().changeTab("Accounting");
                    },
                    child: const Text(
                      'See all',
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Divider(
                  color: Colors.grey.shade300,
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("users").doc(account.userID)
                      .collection("transactions").orderBy("timestamp", descending: true).limit(5).snapshots(),
                  builder: (context, snapshot) {
                    if(!snapshot.hasData)
                    {
                      return const Text("Loading...");
                    }
                    else
                    {
                      List<account_transaction.Transaction> transactions = [];

                      snapshot.data!.docs.forEach((element) {
                        transactions.add(account_transaction.Transaction.fromDocument(element));
                      });

                      if(transactions.isEmpty)
                      {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.currency_exchange_rounded,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                const Text("No transactions")
                              ],
                            ),
                          ),
                        );
                      }
                      else
                      {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(transactions.length, (index) {
                            account_transaction.Transaction transaction = transactions[index];

                            return ListTile(
                              title: Text("Payment By: "+transaction.senderInfo!["name"]!, style: const TextStyle(fontWeight: FontWeight.bold),),
                              subtitle: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(transaction.transactionType!),
                                  Divider(color: Colors.grey.shade300,)
                                ],
                              ),
                              trailing: Text("Kes ${transaction.paidAmount!}"),
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
      },
    );
  }
}
