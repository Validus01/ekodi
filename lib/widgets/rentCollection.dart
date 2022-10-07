import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/model/transaction.dart' as account_transaction;
import 'package:rekodi/widgets/customTextField.dart';
import 'package:rekodi/widgets/loadingAnimation.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:uuid/uuid.dart';

import '../APIs/pdfInvoiceApi.dart';
import '../commonFunctions/transactions.dart';
import '../config.dart';
import '../model/account.dart';
import '../model/invoice.dart';
import '../model/property.dart';
import '../model/unit.dart';
import '../providers/accountingProvider.dart';

class RentCollection extends StatefulWidget {
  final List<dynamic>? properties;

  const RentCollection({Key? key, this.properties}) : super(key: key);

  @override
  State<RentCollection> createState() => _RentCollectionState();
}

class _RentCollectionState extends State<RentCollection> {
  int startDate = DateTime.now().millisecondsSinceEpoch;
  TextEditingController amount = TextEditingController();
  TextEditingController bankName = TextEditingController();
  bool loading = false;
  // List<dynamic> properties = [];
  List<dynamic> selectedProperties = [];
  List<dynamic> units = [];
  List<dynamic> selectedUnits = [];
  List<dynamic> tenants = [];
  List<dynamic> selectedTenants = [];
  String paymentType = "Cash";
  Invoice? selectedInvoice;

  getUnits() async {
    setState(() {
      units.clear();
      selectedUnits.clear();
    });

    for(var property in selectedProperties)
      {
        await FirebaseFirestore.instance.collection("properties")
            .doc(property.propertyID).collection("units")
            .where("isOccupied", isEqualTo: true).get().then((value) {
              value.docs.forEach((element) {
                units.add(Unit.fromDocument(element));
              });
        });
      }


  }

  getTenants() async {
    setState(() {
      tenants.clear();
      selectedTenants.clear();
    });

    for(var unit in selectedUnits)
      {
        tenants.add(unit.tenantInfo);
      }
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    /// The argument value will return the changed date as [DateTime] when the
    /// widget [SfDateRangeSelectionMode] set as single.
    ///
    /// The argument value will return the changed dates as [List<DateTime>]
    /// when the widget [SfDateRangeSelectionMode] set as multiple.
    ///
    /// The argument value will return the changed range as [PickerDateRange]
    /// when the widget [SfDateRangeSelectionMode] set as range.
    ///
    /// The argument value will return the changed ranges as
    /// [List<PickerDateRange] when the widget [SfDateRangeSelectionMode] set as
    /// multi range.
    setState(() {
      // if (args.value is PickerDateRange) {
      //   // String _range = '${DateFormat('dd/MM/yyyy').format(args.value.startDate)} -'
      //   // // ignore: lines_longer_than_80_chars
      //   //     ' ${DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate)}';
      //
      // }
      // else
      if (args.value is DateTime) {
        startDate = args.value.millisecondsSinceEpoch;
      }
      //   else if (args.value is List<DateTime>) {
      //   _dateCount = args.value.length.toString();
      // } else {
      //   _rangeCount = args.value.length.toString();
      // }
    });
  }

  displayCalendar(BuildContext context, bool isMobile) {
    Size size = MediaQuery.of(context).size;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Pick Starting Date"),
          content: Container(
            height: isMobile ? size.height * 0.4 : size.height * 0.6,
            width: isMobile ? size.width * 0.8 : size.width*0.4,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0)
            ),
            child: SfDateRangePicker(
              view: DateRangePickerView.month,
              onSelectionChanged: _onSelectionChanged,
              enableMultiView: isMobile ? false : true,
              selectionMode: DateRangePickerSelectionMode.single,
              initialSelectedDate: DateTime.fromMillisecondsSinceEpoch(startDate),
              // initialSelectedRange: PickerDateRange(
              //     DateTime.fromMillisecondsSinceEpoch(startDate),
              //     DateTime.fromMillisecondsSinceEpoch(endDate)
              // ),
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {Navigator.pop(context);},
              icon: Icon(Icons.done, color: Theme.of(context).primaryColor),
              label: Text("Done", style: TextStyle(color: Theme.of(context).primaryColor),),
            )
          ],
        );
      },
    );
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

  saveAndExit(Account account ) async {
    setState(() {
      loading = true;
    });

    if(selectedTenants.isNotEmpty && bankName.text.isNotEmpty && amount.text.isNotEmpty)
      {
        for (Unit unit in selectedUnits)
        {
          if(selectedTenants.contains(unit.tenantInfo))
          {

            account_transaction.Transaction transaction = account_transaction.Transaction(
              transactionID: DateTime.now().millisecondsSinceEpoch.toString(),
              transactionType: paymentType,
              paymentCategory: "Rent",
              description: "",
              timestamp:  DateTime.now().millisecondsSinceEpoch,
              actualAmount: int.parse(amount.text.trim()),
              paidAmount: int.parse(amount.text.trim()),
              remainingAmount: 0,
              properties: List.generate(selectedProperties.length, (index) {
                return selectedProperties[index].propertyID;
              }),
              serviceProviders: [],
              tenants: [unit.tenantInfo],
              senderInfo: unit.tenantInfo,
              units: [unit.toMap()],
              receiverInfo: account.toMap(),
            );

            Account tenant = Account.fromJson(unit.tenantInfo!);

            Property? property;

            await FirebaseFirestore.instance.collection("properties").doc(unit.propertyID).get().then((value) {
              setState(() {
                property = Property.fromDocument(value);
              });
            });

            //generate invoice

            int period = calculatePeriod(unit);


            String invoiceID = Uuid().v4().split("-").first;

            Invoice invoiceDetails = Invoice(
              invoiceID: selectedInvoice != null ? selectedInvoice!.invoiceID : invoiceID,
              timestamp: DateTime.now().millisecondsSinceEpoch,
              senderInfo: unit.tenantInfo,
              receiverInfo: account.toMap(),
              pdfUrl: '',
              isPaid: unit.rent! - int.parse(amount.text.trim()) < 1 ? true : false,
              bills: [
                Bill(
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                  billType: "Rent",
                  details: "",
                  period: period,
                  paidAmount: int.parse(amount.text.trim()),
                  actualAmount: unit.rent,
                  balance: unit.rent! - int.parse(amount.text.trim()),
                  isPaid: unit.rent! - int.parse(amount.text.trim()) < 1 ? true : false,
                ).toMap(),
              ],
              unitInfo: unit.toMap(),
              propertyInfo: property!.toMap(),
            );

            //save pdf to document
            final String pdfUrl = await PdfInvoiceApi.generateInvoice(account, invoiceDetails);

            Invoice invoiceFinal = Invoice(
              invoiceID: selectedInvoice != null ? selectedInvoice!.invoiceID : invoiceID,
              timestamp: DateTime.now().millisecondsSinceEpoch,
              senderInfo: unit.tenantInfo,
              receiverInfo: account.toMap(),
              pdfUrl: pdfUrl,
              isPaid: unit.rent! - int.parse(amount.text.trim()) < 1 ? true : false,
              bills: [
                Bill(
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                  billType: "Rent",
                  details: "",
                  period: period,
                  paidAmount: int.parse(amount.text.trim()),
                  actualAmount: unit.rent,
                  balance: unit.rent! - int.parse(amount.text.trim()),
                  isPaid: unit.rent! - int.parse(amount.text.trim()) < 1 ? true : false,
                ).toMap(),
              ],
              unitInfo: unit.toMap(),
              propertyInfo: property!.toMap(),
            );


            await Transactions().payRent(transaction, invoiceFinal, tenant, account, unit);

          }
        }


        context.read<AccountingProvider>().changeToAddRent(false);

        setState(() {
          loading = false;
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    Size size = MediaQuery.of(context).size;

    bool showAddRent = context.watch<AccountingProvider>().showAddRent;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isTablet || sizeInfo.isMobile;
        return Container(
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
          ),
          child: loading ? const LoadingAnimation() : Padding(
            padding: const EdgeInsets.all(10.0),
            child: showAddRent ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => context.read<AccountingProvider>().changeToAddRent(false),
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
                    Text("Payment Details", style: Theme.of(context).textTheme.titleMedium,)
                  ],
                ),
                Divider(color: Colors.grey.shade300,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: SizedBox(
                    height: 50.0,
                    child: DropdownSearch<dynamic>.multiSelection(
                      mode: Mode.MENU,
                      items: widget.properties,
                      dropdownSearchDecoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide(
                                width: 1.0,
                                color: Theme.of(context).primaryColor
                            )
                        ),
                        labelText: "Properties",
                        hintText: "Select Properties",
                      ),
                      onChanged: (v) {
                        setState(() {
                          selectedProperties = v;
                        });

                        getUnits();
                      },
                      selectedItems: selectedProperties,
                      itemAsString: (prop) => prop.name,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: SizedBox(
                    height: 50.0,
                    child: DropdownSearch<dynamic>.multiSelection(
                      mode: Mode.MENU,
                      items: units,
                      dropdownSearchDecoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide(
                                width: 1.0,
                                color: Theme.of(context).primaryColor
                            )
                        ),
                        labelText: "Units",
                        hintText: "Select Units",
                      ),
                      onChanged: (v) {
                        setState(() {
                          selectedUnits = v;
                        });

                        getTenants();
                      },
                      selectedItems: selectedUnits,
                      itemAsString: (unit) => unit.name,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: SizedBox(
                    height: 50.0,
                    child: DropdownSearch<dynamic>.multiSelection(
                      mode: Mode.MENU,
                      items: tenants,
                      dropdownSearchDecoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide(
                                width: 1.0,
                                color: Theme.of(context).primaryColor
                            )
                        ),
                        labelText: "Tenants",
                        hintText: "Select Tenants",
                      ),
                      onChanged: (v) {
                        setState(() {
                          selectedTenants = v;
                        });
                      },
                      selectedItems: selectedTenants,
                      itemAsString: (tenantInfo) => tenantInfo["name"],
                    ),
                  ),
                ),
                MyTextField(
                  controller: amount,
                  hintText: "Amount Paid",
                  width: size.width,
                  title: "Amount Paid",
                  inputType: TextInputType.number,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: Text("Payment Type",
                    textAlign: TextAlign.start,
                    style:  TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 5.0),
                  child: DropdownSearch<String>(
                      mode: Mode.MENU,
                      showSelectedItems: true,
                      items: const [
                        "Cash",
                        "M-Pesa",
                        "Bank",
                      ],
                      hint: "",
                      onChanged: (v) {
                        setState(() {
                          paymentType = v!;
                        });
                      },
                      selectedItem: paymentType),
                ),
                paymentType == "Bank" ? MyTextField(
                  controller: bankName,
                  hintText: "Bank Name",
                  width: size.width,
                  title: "Bank Name",
                  inputType: TextInputType.text,
                ) : Container(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text("Payment Date", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(DateFormat('dd MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(startDate)), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),),
                      const SizedBox(width: 5.0,),
                      IconButton(
                        onPressed: () => displayCalendar(context, isMobile),
                        icon: const Icon(Icons.date_range_rounded, color: Colors.grey,),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20.0,),
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection("users").doc(account.userID)
                      .collection("invoices").where("isPaid", isEqualTo: false).get(),
                  builder: (context, snapshot) {
                    if(!snapshot.hasData)
                    {
                      return const Center(child: Text('Loading...'));
                    }
                    else {
                      List<Invoice> invoices = [];

                      for (var element in snapshot.data!.docs) {
                        invoices.add(Invoice.fromDocument(element));
                      }

                      if(invoices.isEmpty)
                      {
                        return Container();
                      }
                      else
                      {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Select Invoice Reference"),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.error_outline_rounded, color: EKodi().themeColor.withOpacity(0.3)),
                                const Text("Ignore if invoice reference does not appear here.", maxLines: 2, style: TextStyle(fontSize: 12.0,),),
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: List.generate(invoices.length, (index) {
                                Invoice invoice = invoices[index];
                                bool isSelected = invoice == selectedInvoice;


                                return Card(
                                  elevation: 5.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      setState(() {
                                        selectedInvoice = invoice;
                                      });
                                    },
                                    leading: isSelected
                                        ? Icon(Icons.check_box, color: EKodi().themeColor,)
                                        : const Icon(Icons.check_box_outline_blank_rounded, color: Colors.grey,),
                                    title: Text(invoice.invoiceID!, style: const TextStyle(fontWeight: FontWeight.bold),),
                                    subtitle: Text("Unpaid rent for ${invoice.senderInfo!["name"]}, Unit: ${invoice.unitInfo!["name"]}", maxLines: 3, overflow: TextOverflow.ellipsis,),
                                    trailing: Text("KES "+invoice.unitInfo!["rent"]),
                                  ),
                                );
                              }),
                            ),
                          ],
                        );
                      }
                    }
                  },
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RaisedButton(
                        onPressed: () => saveAndExit(account),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)
                        ),
                        color: EKodi().themeColor,
                        elevation: 0.0,
                        child: const Text("Save", style: TextStyle(color: Colors.white),),
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      RaisedButton(
                        onPressed: (){
                          saveAndExit(account);
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)
                        ),
                        color: EKodi().themeColor,
                        elevation: 0.0,
                        child: const Text("Save & Send Receipt", style: TextStyle(color: Colors.white),),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
              ],
            ) : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Rent Collection", style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),),
                      RaisedButton.icon(
                        onPressed: () {
                          context.read<AccountingProvider>().changeToAddRent(true);
                        },
                        color: EKodi().themeColor,
                        icon: const Icon(Icons.add, color: Colors.white,),
                        label: const Text("Add Collection", style: TextStyle(color: Colors.white),),
                      )
                    ],
                  ),
                ),
                const Divider(),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("users").doc(account.userID)
                      .collection("transactions").where("paymentCategory", isEqualTo: "Rent")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if(!snapshot.hasData)
                    {
                      return const Text("Loading...");
                    }
                    else
                    {
                      List<account_transaction.Transaction> transactions = [];
                      int rentTotal = 0;

                      for (var element in snapshot.data!.docs) {
                        transactions.add(account_transaction.Transaction.fromDocument(element));

                        rentTotal = rentTotal+account_transaction.Transaction.fromDocument(element).paidAmount!;
                      }

                      context.read<AccountingProvider>().setIncome(rentTotal);

                      transactions.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));

                      if(transactions.isEmpty) {
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
                                const Text("No Rent Collected")
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
                                account_transaction.Transaction transaction = transactions[index];

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
                            Divider(color: Colors.grey.shade300,),
                            const SizedBox(height: 20.0,),
                            Text("Total Rent Collected: KES $rentTotal", style: const TextStyle(fontWeight: FontWeight.bold),),
                            const SizedBox(height: 10.0,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total Revenue: KES ${context.watch<AccountingProvider>().income - context.watch<AccountingProvider>().expense }", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),),
                                const SizedBox(),
                              ],
                            ),
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
        );
      },
    );
  }
}