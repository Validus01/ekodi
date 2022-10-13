import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/APIs/pdfInvoiceApi.dart';
import 'package:rekodi/model/account.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../config.dart';
import '../../model/property.dart';
import '../../providers/datePeriod.dart';
import '../../providers/tabProvider.dart';
import '../../widgets/customAppBar.dart';
import '../../widgets/dateSelector.dart';
import '../../widgets/loadingAnimation.dart';
import 'IncomeExpenseStatement.dart';
import '../../model/transaction.dart' as my;

class RentLedgerReport extends StatefulWidget {
  const RentLedgerReport({Key? key}) : super(key: key);

  @override
  State<RentLedgerReport> createState() => _RentLedgerReportState();
}

class _RentLedgerReportState extends State<RentLedgerReport> {
  List<dynamic> properties = [];
  List<dynamic> selectedProperties = [];
  bool loading = false;
  List<my.Transaction> transactions = [];

  @override
  void initState() {
    getProperties();
    super.initState();
  }

  getProperties() async {
    setState(() {
      loading = true;
    });

    String userID = Provider.of<EKodi>(context, listen: false).account.userID!;

    await FirebaseFirestore.instance.collection("properties").where("publisherID", isEqualTo: userID).get().then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        properties.add(Property.fromDocument(element));
      });
    });

    setState(() {
      loading = false;
    });
  }

  void runReport(int startDate, int endDate) async {
    setState(() {
      transactions.clear();
    });

    for(var selectedProperty in selectedProperties) {
      //get all transactions in the time period 

      await FirebaseFirestore.instance.collection("properties")
      .doc(selectedProperty.propertyID!).collection("transactions")
      .where("timestamp", isGreaterThanOrEqualTo: startDate)
      .where("timestamp", isLessThanOrEqualTo: endDate).get()
      .then((querySnapshot) {
        querySnapshot.docs.forEach((element) { 
          my.Transaction transaction = my.Transaction.fromDocument(element);

          transactions.add(transaction);
        });
      });
    }

    if(transactions.isEmpty){
      Fluttertoast.showToast(msg: "There are no transactions in this period ");
    }

    setState(() {
      
    });
  }

  generateReport(Account account, int startDate, int endDate, ) async {
    setState(() {
      loading = true;
    }); 

    String period = DateFormat("dd MMM yyyy")
            .format(DateTime.fromMillisecondsSinceEpoch(startDate)) + " - " + DateFormat("dd MMM yyyy")
            .format(DateTime.fromMillisecondsSinceEpoch(endDate));

    final String downloadUrl = await PdfInvoiceApi.generateReport(
      account, 
      "Rent Ledger \nReport", 
      period,
      transactions);

      int timestamp = DateTime.now().millisecondsSinceEpoch;

      await FirebaseFirestore.instance.collection("users")
      .doc(account.userID).collection("reports").doc(timestamp.toString())
      .set({
        "reportID": timestamp.toString(),
        "url": downloadUrl,
        "period": period,
        "timestamp": timestamp,
      }).then((value) => Fluttertoast.showToast(msg: "Report generated Successfully!"));

      setState(() {
      loading = false;
    }); 
  }

  Widget transactionsList(account, startDate, endDate) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(transactions.length, (index) {
            my.Transaction transaction = transactions[index];

            return ListTile(
              leading: Text(transaction.units![0]["name"], style: const TextStyle(fontWeight: FontWeight.bold),),
              title: Text(transaction.senderInfo!["name"], style: const TextStyle(),),
              subtitle: Text(DateFormat("HH: mm, dd MMM").format(DateTime.fromMillisecondsSinceEpoch(transaction.timestamp!)), style: const TextStyle(),),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(transaction.paidAmount.toString(), style: const TextStyle(fontWeight: FontWeight.bold),),
                      const Text("Paid", style: TextStyle(),),
                    ],
                  ),
                  const SizedBox(width: 10.0,),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(transaction.remainingAmount.toString(), style: const TextStyle(fontWeight: FontWeight.bold),),
                      const Text("Remaining", style: TextStyle(),),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 20.0,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 1.0,),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: InkWell(
                onTap: () => generateReport(account, startDate, endDate),
                child: Container(
                  height: 30.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      border: Border.all(
                          color: Colors.green,
                          width: 1.0
                      )
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Center(child: Text("Generate Report", style: TextStyle(color: Colors.green),)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    Size size = MediaQuery.of(context).size;
     int startDate = context.watch<DatePeriodProvider>().startDate;
    int endDate = context.watch<DatePeriodProvider>().endDate;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        return loading ? const LoadingAnimation(): Container(
          margin: const EdgeInsets.only(top: 20.0),
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
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => context.read<TabProvider>().changeTab("Reports"),
                      child: Container(
                        height: 30.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.0),
                            border: Border.all(
                                color: EKodi().themeColor,
                                width: 1.0
                            )
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Center(child: Text("Back", style: TextStyle(color: EKodi().themeColor),)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0,),
                    Text("Rent Ledger Report", style: Theme.of(context).textTheme.titleMedium,)
                  ],
                ),
                Divider(color: Colors.grey.shade300,),
                CustomDropDown(
                  items: properties,
                  selectedItems: selectedProperties,
                  title: "Select Properties",
                  isMultiselect: true,
                  onMultiChanged: (v) {
                    setState(() {
                      selectedProperties = v;
                    });
                  },
                  hintText: "Select Properties",
                  labelText: "Properties",
                  itemAsString: (u) => u.name,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: sizeInfo.isMobile ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Select Period", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),),
                      SizedBox(height: 10.0,),
                      DateSelector(),
                    ],
                  ) : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text("Select Period", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),),
                      const SizedBox(width: 20.0,),
                      SizedBox(
                          width: size.width*0.55,
                          child: const DateSelector()),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0,),
                transactions.isNotEmpty ? transactionsList(account, startDate, endDate) : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 1.0,),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        onTap: () {
                          if(selectedProperties.isNotEmpty)
                          {
                            runReport(startDate, endDate);
                          } else {
                            Fluttertoast.showToast(msg: "Select a property");
                          }
                        },
                        child: Container(
                          height: 30.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3.0),
                              border: Border.all(
                                  color: Colors.blue,
                                  width: 1.0
                              )
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Center(child: Text("Run Report", style: TextStyle(color: Colors.blue),)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
