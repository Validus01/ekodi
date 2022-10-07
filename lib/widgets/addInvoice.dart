import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/model/invoice.dart';
import 'package:rekodi/model/property.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:uuid/uuid.dart';

import '../APIs/pdfInvoiceApi.dart';
import '../config.dart';
import '../model/account.dart';
import '../model/unit.dart';
import 'customTextField.dart';


class AddInvoice extends StatefulWidget {
  final List<Property>? properties;
  const AddInvoice({Key? key, this.properties}) : super(key: key);

  @override
  State<AddInvoice> createState() => _AddInvoiceState();
}

class _AddInvoiceState extends State<AddInvoice> {

  TextEditingController landlordName = TextEditingController();
  TextEditingController landlordEmail = TextEditingController();
  TextEditingController tenantName = TextEditingController();
  TextEditingController tenantEmail = TextEditingController();
  TextEditingController billType = TextEditingController();
  TextEditingController details = TextEditingController();
  TextEditingController period = TextEditingController();
  TextEditingController paidAmount = TextEditingController();
  TextEditingController actualAmount = TextEditingController();
  int startDate = DateTime.now().millisecondsSinceEpoch;
  Property? selectedProperty;
  Unit? selectedUnit;
  List<Unit> units = [];
  Account? selectedTenant;
  String paymentType = "Cash";
  String invoiceID = Uuid().v4().split("-").first.toUpperCase();
  List<Bill> bills = [];
  bool loading = false;


  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    Account userInfo = Provider.of<EKodi>(context, listen: false).account;

    setState(() {
      landlordName.text = userInfo.name!;
      landlordEmail.text = userInfo.email!;
    });

  }

  getUnits() async {
    setState(() {
      units.clear();
    });

    await FirebaseFirestore.instance.collection("properties")
          .doc(selectedProperty!.propertyID).collection("units")
          .where("isOccupied", isEqualTo: true).get().then((value) {
        for (var element in value.docs) {
          units.add(Unit.fromDocument(element));
        }
      });


  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is DateTime) {
        startDate = args.value.millisecondsSinceEpoch;
      }
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

  saveAndSendInvoice(Account account) async {
    setState(() {
      loading = true;
    });

    if(bills.isNotEmpty && selectedUnit != null && selectedTenant != null && selectedProperty != null) {
      Invoice invoiceDetails = Invoice(
        invoiceID: invoiceID,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        senderInfo: selectedTenant!.toMap(),
        receiverInfo: account.toMap(),
        pdfUrl: '',
        isPaid: bills.any((element) => element.isPaid == false) ? false : true,
        bills: List.generate(bills.length, (index) {
          return bills[index].toMap();
        }),
        unitInfo: selectedUnit!.toMap(),
        propertyInfo: selectedProperty!.toMap(),
      );

      //save pdf to document
      final String pdfUrl = await PdfInvoiceApi.generateInvoice(selectedTenant!, invoiceDetails);

      Invoice invoiceFinal = Invoice(
        invoiceID: invoiceID,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        senderInfo: selectedTenant!.toMap(),
        receiverInfo: account.toMap(),
        pdfUrl: pdfUrl,
        isPaid: bills.any((element) => element.isPaid == false) ? false : true,
        bills: List.generate(bills.length, (index) {
          return bills[index].toMap();
        }),
        unitInfo: selectedUnit!.toMap(),
        propertyInfo: selectedProperty!.toMap(),
      );

      //1.1 record invoice to tenant
      await FirebaseFirestore.instance.collection("users").doc(selectedTenant!.userID)
          .collection("invoices").doc(invoiceFinal.invoiceID).set(invoiceFinal.toMap());

      //2.1 record invoice to landlord
      await FirebaseFirestore.instance.collection("users").doc(account.userID)
          .collection("invoices").doc(invoiceFinal.invoiceID).set(invoiceFinal.toMap());

      //2.2 record invoice to property
      await FirebaseFirestore.instance.collection("properties").doc(selectedUnit!.propertyID)
          .collection("invoices").doc(invoiceFinal.invoiceID).set(invoiceFinal.toMap());

      setState(() {
        loading = false;
        bills.clear();
      });

    }

  }
  
  addBillDialog(BuildContext context, Size size, bool isMobile) {
    double width = isMobile ? size.width*0.8 : size.width*0.4;

    showDialog(
        context:  context,
        builder: (c) {
          return AlertDialog(
            title: const Text("Add Bill"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyTextField(
                  controller: billType,
                  hintText: "e.g Rent, Repair",
                  width: width,
                  title: "Bill Type",
                  inputType: TextInputType.name,
                ),
                MyTextField(
                  controller: details,
                  hintText: "Description",
                  width: width,
                  title: "Description",
                  inputType: TextInputType.text,
                ),
                MyTextField(
                  controller: period,
                  hintText: "Period (Days)",
                  width: width,
                  title: "How long will the payment last",
                  inputType: TextInputType.number,
                ),
                MyTextField(
                  controller: paidAmount,
                  hintText: "Amount",
                  width: width,
                  title: "Paid Amount",
                  inputType: TextInputType.number,
                ),
                MyTextField(
                  controller: actualAmount,
                  hintText: "Amount",
                  width: width,
                  title: "Actual Amount",
                  inputType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              RaisedButton.icon(
                onPressed: () {
                  Bill bill = Bill(
                      timestamp: DateTime.now().millisecondsSinceEpoch,
                      billType: billType.text.trim(),
                      details: details.text.trim(),
                      period: int.parse(period.text.trim()),
                      paidAmount: int.parse(paidAmount.text.trim()),
                      actualAmount: int.parse(actualAmount.text.trim()),
                      balance: int.parse(actualAmount.text.trim()) - int.parse(paidAmount.text.trim()),
                      isPaid: int.parse(actualAmount.text.trim()) - int.parse(paidAmount.text.trim()) > 0 ? false : true,
                  );

                  bills.add(bill);

                  setState(() {
                    billType.clear();
                    period.clear();
                    details.clear();
                    paidAmount.clear();
                    actualAmount.clear();
                  });

                  Navigator.pop(context);
                },
                label: const Text("Add", style: TextStyle(color: Colors.white),),
                color: EKodi().themeColor,
                icon: const Icon(Icons.add, color: Colors.white,),
              )
            ],
          );
        }
    );
  }

  Widget showBills(BuildContext context, Size size, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Bills", style: Theme.of(context).textTheme.titleMedium,),
          Divider(color: Colors.grey.shade300,),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(bills.length, (index) {
              Bill bill = bills[index];

              return Card(
                child: ListTile(
                  leading: Text("${index+1}", style: const TextStyle(fontWeight: FontWeight.w700),),
                  title: Text(bill.billType!),
                  subtitle: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Paid: "+bill.paidAmount!.toString()),
                      Text("Actual Amount: "+bill.actualAmount!.toString()),
                      Text("Period(Days): "+bill.period!.toString()),
                      bill.billType == "Rent"
                          ? Text("Rent for: " + DateFormat("MMMM").format(DateTime.fromMillisecondsSinceEpoch(bill.timestamp!)))
                          : Container()
                    ],
                  ),
                  trailing: TextButton(
                    onPressed: (){
                      setState(() {
                        bills.removeWhere((element) => element == bill);
                      });
                    },
                    child: const Text('Remove', style: TextStyle(color: Colors.red),),
                  ),
                ),
              );
            }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(),
              InkWell(
                onTap: () => addBillDialog(context, size, isMobile),
                child: Container(
                  height: 30.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                        color: EKodi().themeColor, width: 1.0),
                  ),
                  child: Center(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text('Add Bill', style: TextStyle(color: EKodi().themeColor,),),
                  )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForDesktop(Account account, Size size) {
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
        // border: Border.all(
        //     color: Colors.black26, width: 1.0),
      ),
      child:  Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Invoice ID", style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .apply(
                              color: Colors.black,
                              fontWeightDelta: 10)),
                          Container(
                            width: size.width*0.2,
                            height: 35.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3.0),
                              color: Colors.grey.shade100,
                              border: Border.all(
                                  color: Colors.black26, width: 1.0),
                            ),
                            child: Center(child: Text(invoiceID)),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                      child: Text("Bill From", style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .apply(
                          color: Colors.black,
                          fontWeightDelta: 10)),
                    ),
                    InvoiceTextField(
                      controller: landlordName,
                      hintText: "Property Manager",
                      width: size.width*0.3,
                      title: "Property Manager",
                      inputType: TextInputType.name,
                      isEnd: false,
                    ),
                    InvoiceTextField(
                      controller: landlordEmail,
                      hintText: "Email Address",
                      width: size.width*0.3,
                      title: "Email Address",
                      inputType: TextInputType.emailAddress,
                      isEnd: false,
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Invoice Date", style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .apply(
                              color: Colors.black,
                              fontWeightDelta: 10)),
                          Container(
                            width: size.width*0.3,
                            height: 35.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3.0),
                              color: Colors.grey.shade100,
                              border: Border.all(
                                  color: Colors.black26, width: 1.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(child: Text(DateFormat("yyyy-MM-dd").format(DateTime.fromMillisecondsSinceEpoch(startDate)), textAlign: TextAlign.right,)),
                                const VerticalDivider(color: Colors.black26, ),
                                IconButton(
                                  onPressed: () => displayCalendar(context, false),
                                  icon: const Icon(Icons.calendar_today_rounded, color: Colors.grey,),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                      child: Text("Bill To", style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .apply(
                          color: Colors.black,
                          fontWeightDelta: 10)),
                    ),
                    InvoiceTextField(
                      controller: tenantName,
                      hintText: "Tenant",
                      width: size.width*0.3,
                      title: "Tenant",
                      inputType: TextInputType.name,
                      isEnd: true,
                    ),
                    InvoiceTextField(
                      controller: tenantEmail,
                      hintText: "Email",
                      width: size.width*0.3,
                      title: "Email Address",
                      inputType: TextInputType.emailAddress,
                      isEnd: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                      child: SizedBox(
                        height: 35.0,
                        width: size.width*0.3,
                        child: DropdownSearch<Property>(
                          mode: Mode.MENU,
                          //showSelectedItems: true,
                          items: widget.properties!,
                          hint: "Select Property",
                          itemAsString: (p) => p!.name!,
                          onChanged: (v) {
                            setState(() {
                              selectedProperty = v!;
                            });

                            getUnits();
                          },

                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                      child: SizedBox(
                        height: 35.0,
                        width: size.width*0.3,
                        child: DropdownSearch<Unit>(
                          mode: Mode.MENU,
                          //showSelectedItems: true,
                          items: units,
                          hint: "Select Unit",
                          itemAsString: (u)=> u!.name!,
                          onChanged: (v) {
                            setState(() {
                              selectedUnit = v!;
                              selectedTenant = Account.fromJson(v.tenantInfo!);
                              tenantEmail.text = v.tenantInfo!["email"];
                              tenantName.text = v.tenantInfo!["name"];
                              bills.add(Bill(
                                  timestamp: DateTime.now().millisecondsSinceEpoch,
                                  billType: "Rent",
                                  details: "Payment",
                                  period: 30,
                                  paidAmount: 0,
                                  actualAmount: v.rent,
                                  balance: v.rent,
                                  isPaid: false
                              )
                              );
                            });

                          },

                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            showBills(context, size, false),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        bills.clear();
                      });
                    },
                    child: Container(
                      height: 30.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                            color: EKodi().themeColor, width: 1.0),
                      ),
                      child: Center(child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Text('Cancel', style: TextStyle(color: EKodi().themeColor,),),
                      )),
                    ),
                  ),
                  const SizedBox(width: 10.0,),
                  RaisedButton(
                    elevation: 0.0,
                    color: EKodi().themeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    onPressed:  loading ? () {} : ()=> saveAndSendInvoice(account),
                    child: Text(loading ? "Sending..." : "Save & Send", style: const TextStyle(color: Colors.white)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildForMobile(Account account, Size size) {
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
        // border: Border.all(
        //     color: Colors.black26, width: 1.0),
      ),
      child:  Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Invoice Date", style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .apply(
                      color: Colors.black,
                      fontWeightDelta: 10)),
                  Container(
                    width: size.width*0.5,
                    height: 35.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: Colors.grey.shade100,
                      border: Border.all(
                          color: Colors.black26, width: 1.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: Text(DateFormat("yyyy-MM-dd").format(DateTime.fromMillisecondsSinceEpoch(startDate)), textAlign: TextAlign.right,)),
                        const VerticalDivider(color: Colors.black26, ),
                        IconButton(
                          onPressed: () => displayCalendar(context, true),
                          icon: const Icon(Icons.calendar_today_rounded, color: Colors.grey,),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Invoice ID", style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .apply(
                    color: Colors.black,
                    fontWeightDelta: 10)),
                Container(
                  width: size.width*0.4,
                  height: 35.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.0),
                    color: Colors.grey.shade100,
                    border: Border.all(
                        color: Colors.black26, width: 1.0),
                  ),
                  child: Center(child: Text(invoiceID)),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: Text("Bill From", style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .apply(
                      color: Colors.black,
                      fontWeightDelta: 10)),
                ),
                InvoiceTextField(
                  controller: landlordName,
                  hintText: "Property Manager",
                  width: size.width*0.6,
                  title: "Property Manager",
                  inputType: TextInputType.name,
                  isEnd: false,
                ),
                InvoiceTextField(
                  controller: landlordEmail,
                  hintText: "Email Address",
                  width: size.width*0.6,
                  title: "Email Address",
                  inputType: TextInputType.emailAddress,
                  isEnd: false,
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                    child: Text("Bill To", style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .apply(
                        color: Colors.black,
                        fontWeightDelta: 10)),
                  ),
                  InvoiceTextField(
                    controller: tenantName,
                    hintText: "Tenant",
                    width: size.width*0.6,
                    title: "Tenant",
                    inputType: TextInputType.name,
                    isEnd: true,
                  ),
                  InvoiceTextField(
                    controller: tenantEmail,
                    hintText: "Email",
                    width: size.width*0.6,
                    title: "Email Address",
                    inputType: TextInputType.emailAddress,
                    isEnd: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                    child: SizedBox(
                      height: 35.0,
                      width: size.width*0.6,
                      child: DropdownSearch<Property>(
                        mode: Mode.MENU,
                        //showSelectedItems: true,
                        items: widget.properties!,
                        hint: "Select Property",
                        itemAsString: (p) => p!.name!,
                        onChanged: (v) {
                          setState(() {
                            selectedProperty = v!;
                          });

                          getUnits();
                        },

                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                    child: SizedBox(
                      height: 35.0,
                      width: size.width*0.6,
                      child: DropdownSearch<Unit>(
                        mode: Mode.MENU,
                        //showSelectedItems: true,
                        items: units,
                        hint: "Select Unit",
                        itemAsString: (u)=> u!.name!,
                        onChanged: (v) {
                          setState(() {
                            selectedUnit = v!;
                            selectedTenant = Account.fromJson(v.tenantInfo!);
                            tenantEmail.text = v.tenantInfo!["email"];
                            tenantName.text = v.tenantInfo!["name"];
                            bills.add(Bill(
                                timestamp: DateTime.now().millisecondsSinceEpoch,
                                billType: "Rent",
                                details: "Payment",
                                period: 30,
                                paidAmount: 0,
                                actualAmount: v.rent,
                                balance: v.rent,
                                isPaid: false
                            )
                            );
                          });

                        },

                      ),
                    ),
                  ),
                ],
              ),
            ),
            showBills(context, size, true),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        bills.clear();
                      });
                    },
                    child: Container(
                      height: 30.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                            color: EKodi().themeColor, width: 1.0),
                      ),
                      child: Center(child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Text('Cancel', style: TextStyle(color: EKodi().themeColor,),),
                      )),
                    ),
                  ),
                  const SizedBox(width: 10.0,),
                  RaisedButton(
                    elevation: 0.0,
                    color: EKodi().themeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    onPressed:  loading ? () {} : ()=> saveAndSendInvoice(account),
                    child: Text(loading ? "Sending..." : "Save & Send", style: const TextStyle(color: Colors.white)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile || sizeInfo.isTablet;
        return isMobile ? _buildForMobile(account, size) : _buildForDesktop(account, size);
      },
    );
  }
}
