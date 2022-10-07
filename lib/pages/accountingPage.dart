
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/model/property.dart';
import 'package:rekodi/model/transaction.dart' as account_transaction;
import 'package:rekodi/providers/accountingProvider.dart';
import 'package:rekodi/providers/tabProvider.dart';
import 'package:rekodi/widgets/customTextField.dart';
import 'package:rekodi/widgets/loadingAnimation.dart';
import 'package:rekodi/widgets/rentCollection.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../config.dart';
import '../model/account.dart';
import '../providers/datePeriod.dart';

class Accounting extends StatefulWidget {
  const Accounting({Key? key}) : super(key: key);

  @override
  State<Accounting> createState() => _AccountingState();
}

class _AccountingState extends State<Accounting> {

  TextEditingController description = TextEditingController();
  TextEditingController paidAmount = TextEditingController();
  String selected = "All";
  List<String> items = [
    "All",
  ];
  bool loading = false;
  List<dynamic> properties = [];
  late dynamic selectedProperty;
  List<dynamic> selectedProperties = [];

  @override
  void initState() {
    super.initState();
    getProperties();
  }

  getProperties() async {
    setState(() {
      loading = true;
    });

    String userID = Provider.of<EKodi>(context, listen: false).account.userID!;

    await FirebaseFirestore.instance.collection("properties").where("publisherID", isEqualTo: userID)
        .get().then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        properties.add(Property.fromDocument(element));
        items.add(Property.fromDocument(element).name!);
      });
    });

    setState(() {
      loading = false;
    });
  }

  proceedToAddExpense(Account account) async {
    setState(() {
      loading = true;
    });
    Navigator.pop(context);

    account_transaction.Transaction transaction = account_transaction.Transaction(
      transactionID: DateTime.now().millisecondsSinceEpoch.toString(),
      transactionType: "",
      paymentCategory: description.text.trim(),
      description: description.text,
      timestamp:  DateTime.now().millisecondsSinceEpoch,
      actualAmount: int.parse(paidAmount.text.trim()),
      paidAmount: int.parse(paidAmount.text.trim()),
      remainingAmount: 0,
      properties: List.generate(selectedProperties.length, (index) => selectedProperties[index].propertyID),
      serviceProviders: [],
      tenants: [],
      senderInfo: account.toMap(),
      units: [],
      receiverInfo: {},
    );

    await FirebaseFirestore.instance.collection("users").doc(account.userID).collection("transactions").doc(transaction.transactionID).set(transaction.toMap());


    setState(() {
      loading = false;
      description.clear();
      paidAmount.clear();
      selectedProperties.clear();
    });
  }

  showAddExpense(BuildContext context, Account account, Size size, bool isMobile) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return ResponsiveBuilder(
          builder: (context, sizeInfo) {
            bool isDesktop = sizeInfo.isDesktop;

            return AlertDialog(
              title: const Text("Add Expense"),
              content: Container(
               // height: isDesktop ? size.height * 0.6 : size.height * 0.4,
                width: isDesktop ? size.width * 0.4 : size.width*0.8,
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyTextField(
                      controller: description,
                      hintText: "What's the expense for?",
                      width: size.width,
                      title: "Describe Expense",
                      inputType: TextInputType.text,
                    ),
                    MyTextField(
                      controller: paidAmount,
                      hintText: "Amount (Kes)",
                      width: size.width,
                      title: "Amount (Kes)",
                      inputType: TextInputType.number,
                    ),
                    const Text("Select Properties"),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(properties.length, (index) {

                        return PropertyItem(
                          property: properties[index],
                          isSelected: (v) {
                            setState(() {
                              if(v)
                              {
                                selectedProperties.add(properties[index]);
                                print("Added ${selectedProperties.length}");
                              }
                              else
                              {
                                selectedProperties.removeWhere((property) => properties[index].propertyID == property.propertyID);
                                print("Removed ${selectedProperties.length}");
                              }
                            });
                          },
                        );
                      }),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                RaisedButton.icon(
                  onPressed: () {
                    if(description.text.isNotEmpty && paidAmount.text.isNotEmpty
                        && selectedProperties.isNotEmpty)
                      {
                        proceedToAddExpense(account);
                      }
                  },
                  color: EKodi().themeColor,
                  icon: const Icon(Icons.add, color: Colors.white,),
                  label: const Text("Add Expense", style: TextStyle(color: Colors.white),),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    Size size = MediaQuery.of(context).size;
    int startDate = context.watch<DatePeriodProvider>().startDate;
    int endDate = context.watch<DatePeriodProvider>().endDate;

    String start = DateFormat("dd MMM yyyy")
        .format(DateTime.fromMillisecondsSinceEpoch(startDate));

    String end = DateFormat("dd MMM yyyy")
        .format(DateTime.fromMillisecondsSinceEpoch(endDate));

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile || sizeInfo.isTablet;

        return loading ? const LoadingAnimation() : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Accounting", style: Theme.of(context).textTheme.headlineSmall,),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: RaisedButton.icon(
                    color: EKodi().themeColor,
                    onPressed: () => context.read<TabProvider>().changeTab("Invoice"),
                    icon: const Icon(Icons.receipt_long_rounded, color: Colors.white,),
                    label: const Text("Invoices", style: TextStyle(color: Colors.white),),
                  ),
                ),
              ],
            ),
            Container(
              width: size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 1,
                      spreadRadius: 1.0,
                      offset: Offset(0.0, 0.0))
                ],
                // border: Border.all(
                //     color: Colors.black26, width: 1.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(),
                          Row(
                            children: [
                              Text("Property", style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),),
                              const SizedBox(width: 10.0,),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Text(selected),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.arrow_drop_down),
                                offset: const Offset(0.0, 0.0),
                                onSelected: (v) async {
                                  setState(() {
                                    selected = v;
                                    selectedProperty = properties.where((element) => element.name == v).toList().first;
                                  });
                                },
                                itemBuilder: (BuildContext context) {
                                  return items.map((String choice) {
                                    return PopupMenuItem<String>(
                                      value: choice,
                                      child: Text(choice),
                                    );
                                  }).toList();
                                },
                              ),
                            ],
                          ),
                          isMobile ? Container() : Text("$start - $end", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),)
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Expenses", style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),),
                          RaisedButton.icon(
                            onPressed: ()=> showAddExpense(context, account, size, isMobile),
                            color: EKodi().themeColor,
                            icon: const Icon(Icons.add, color: Colors.white,),
                            label: const Text("Add Expense", style: TextStyle(color: Colors.white),),
                          )
                        ],
                      ),
                    ),
                    const Divider(),
                    const ListTile(
                      title: Text("Expense Description", style: TextStyle(fontWeight: FontWeight.bold),),
                      trailing: Text("Amount", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const Divider(),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection("users")
                          .doc(account.userID).collection("transactions")
                          .where("paymentCategory", isNotEqualTo: "Rent")
                          //.orderBy("timestamp", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if(!snapshot.hasData)
                          {
                            return const Text("Loading...");
                          }
                        else {
                          List<account_transaction.Transaction> transactions = [];
                          int expenseTotal = 0;

                          for (var element in snapshot.data!.docs) {
                            transactions.add(account_transaction.Transaction.fromDocument(element));

                            expenseTotal = expenseTotal + account_transaction.Transaction.fromDocument(element).paidAmount!;
                          }

                          context.read<AccountingProvider>().setExpense(expenseTotal);

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
                                      const Text("No Expenses")
                                    ],
                                  ),
                                ),
                              );
                            }
                          else {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(transactions.length, (index) {
                                    account_transaction.Transaction expense = transactions[index];

                                    return ListTile(
                                      leading: Text((index+1).toString(), style: const TextStyle(fontWeight: FontWeight.bold),),
                                      title: Text(expense.description!),
                                      subtitle: Divider(color: Colors.grey.shade300,),
                                      trailing: Text("Kes "+expense.paidAmount.toString()),
                                    );
                                  }),
                                ),
                                Divider(color: Colors.grey.shade300,),
                                const SizedBox(height: 20.0,),
                                Text("Total Expense: KES $expenseTotal", style: const TextStyle(fontWeight: FontWeight.bold),),
                                const SizedBox(height: 20.0,),
                              ],
                            );
                          }
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0,),
            RentCollection(properties: properties,)
          ],
        );
      },
    );
  }
}



class PropertyItem extends StatefulWidget {

  final Property? property;
  final ValueChanged<bool>? isSelected;
  const PropertyItem({Key? key, this.property, this.isSelected}) : super(key: key);

  @override
  State<PropertyItem> createState() => _PropertyItemState();
}

class _PropertyItemState extends State<PropertyItem> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        child: ListTile(
          onTap: () {
            setState(() {
              isSelected = !isSelected;
              widget.isSelected!(isSelected);
            });
          },
          leading: isSelected
              ? Icon(Icons.check_box, color: EKodi().themeColor,)
              : const Icon(Icons.check_box_outline_blank_rounded, color: Colors.grey,),
          title: Text(widget.property!.name!, style: const TextStyle(fontWeight: FontWeight.bold),),
          subtitle: Text(widget.property!.city!+", "+widget.property!.country!, maxLines: 3, overflow: TextOverflow.ellipsis,),
        ),
      ),
    );
  }
}
