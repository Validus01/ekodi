import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/APIs/mPesaAPI.dart';
import 'package:rekodi/APIs/pdfInvoiceApi.dart';
import 'package:rekodi/main.dart';
import 'package:rekodi/model/invoice.dart';
import 'package:rekodi/model/leaseExpiryModel.dart';
import 'package:rekodi/model/transaction.dart' as account_transaction;
import 'package:rekodi/providers/transactionProvider.dart';
import 'package:rekodi/widgets/customTextField.dart';
import 'package:rekodi/widgets/loadingAnimation.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:uuid/uuid.dart';

import '../chat/chatProvider/chatProvider.dart';
import '../commonFunctions/transactions.dart';
import '../config.dart';
import '../dialog/errorDialog.dart';
import '../model/account.dart';
import '../model/property.dart';
import '../model/unit.dart';
import '../providers/datePeriod.dart';
import '../providers/tabProvider.dart';
import 'defaultLineChart.dart';

class BillingCard extends StatefulWidget {
  const BillingCard({Key? key}) : super(key: key);

  @override
  State<BillingCard> createState() => _BillingCardState();
}

class _BillingCardState extends State<BillingCard> {
  TextEditingController amountController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  showBillOptions(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (c) {
          return ResponsiveBuilder(
            builder: (context, sizeInfo) {
              bool isMobile = sizeInfo.isMobile;
              return AlertDialog(
                title: const Text("Add Bills"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        onTap: () {},
                        leading: Image.asset("assets/kplc.png", height: 50.0, width: 50.0, fit: BoxFit.contain,),
                        title: const Text("Electricity"),
                        subtitle: const Text("Pay your electricity bills through our platform"),
                        trailing: isMobile ? null : const Text("KES 0.0 Spent", style: TextStyle(color: Colors.grey),),
                      ),
                      ListTile(
                        onTap: () {},
                        leading: Image.asset("assets/water.jpg", height: 50.0, width: 50.0, fit: BoxFit.contain,),
                        title: const Text("Water"),
                        subtitle: const Text("Pay for water"),
                        trailing: isMobile ? null : const Text("KES 0.0 Spent", style: TextStyle(color: Colors.grey),),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }
    );
  }

  showPaymentOptions(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) {
          return ResponsiveBuilder(
            builder: (context, sizeInfo) {
              bool isMobile = sizeInfo.isMobile;
              return AlertDialog(
                title: const Text("Select Payment Option"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        onTap: () {
                          Navigator.pop(context, "M-Pesa");
                        },
                        leading: Image.asset("assets/mpesa.png", height: 50.0, width: 50.0, fit: BoxFit.contain,),
                        title: const Text("M-Pesa"),
                        subtitle: const Text("Pay your rent through M-Pesa"),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.pop(context, "visa");
                        },
                        leading: Image.asset("assets/visa.png", height: 50.0, width: 50.0, fit: BoxFit.contain,),
                        title: const Text("Visa"),
                        subtitle: const Text("Pay for rent using your bank card"),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.pop(context, "cash");
                        },
                        leading: const Icon(Icons.payments_outlined, size: 20.0,),
                        title: const Text("Cash"),
                        subtitle: const Text("Pay rent with cash"),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }
    );
  }

  getAmountDialog(BuildContext context, Size size) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) {
          return ResponsiveBuilder(
            builder: (context, sizeInfo) {
              bool isMobile = sizeInfo.isMobile;
              return AlertDialog(
                title: const Text("Set Amount"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyTextField(
                        controller: amountController,
                        hintText: "Amount",
                        width: isMobile ? size.width*0.8 : size.width*0.4,
                        title: "Rent Amount",
                        inputType: TextInputType.number,
                      ),
                      MyTextField(
                        controller: phoneController,
                        hintText: "2547XXXXXXXX",
                        width: isMobile ? size.width*0.8 : size.width*0.4,
                        title: "Phone (2547...)",
                        inputType: TextInputType.number,
                      )
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if(amountController.text.isNotEmpty && phoneController.text.isNotEmpty)
                        {
                          Navigator.pop(context);
                        }
                    },
                    child: const Text("PROCEED"),
                  )
                ],
              );
            },
          );
        }
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

  proceedToPayRent(Account sender, Unit unit, Size size) async {

    setState(() {
      amountController.text = unit.rent.toString();
    });

    await context.read<TransactionProvider>().setIsPaying(true);

    //check if landlord has paybill of buygoods TODO Implement payment
    String transactionType = await showPaymentOptions(context,);

    await getAmountDialog(context, size);

    Account? receiver;
    Property? property;

    await FirebaseFirestore.instance.collection("users").doc(unit.publisherID).get().then((value) {
      setState(() {
        receiver = Account.fromDocument(value);
      });
    });

    await FirebaseFirestore.instance.collection("properties").doc(unit.propertyID).get().then((value) {
      setState(() {
        property = Property.fromDocument(value);
      });
    });

    String? response = "success";

    if(transactionType == "M-Pesa")
      {
        if(kIsWeb)
          {
            response = await MPesaAPI().performTransactionWeb(sender, amountController.text.trim(), int.parse(phoneController.text.trim()));
          }
        else
          {
            response = await MPesaAPI().performTransactionMobile(sender, amountController.text.trim(), phoneController.text.trim());
          }
      }

    if(response == "success")
      {
        // if its available proceed with payment
        account_transaction.Transaction transaction = account_transaction.Transaction(
          transactionID: DateTime.now().millisecondsSinceEpoch.toString(),
          transactionType: transactionType,
          paymentCategory: "Rent",
          description: "",
          timestamp:  DateTime.now().millisecondsSinceEpoch,
          actualAmount: unit.rent,
          paidAmount: int.parse(amountController.text.trim()),
          remainingAmount: unit.rent! - int.parse(amountController.text.trim()),
          properties: [unit.propertyID],
          serviceProviders: [],
          tenants: [sender.userID],
          senderInfo: sender.toMap(),
          units: [unit.toMap()],
          receiverInfo: receiver!.toMap(),
        );

        int period = calculatePeriod(unit);

        String invoiceID = Uuid().v4().split("-").first;

        Invoice invoiceDetails = Invoice(
          invoiceID: invoiceID.toUpperCase(),
          timestamp: DateTime.now().millisecondsSinceEpoch,
          senderInfo: sender.toMap(),
          receiverInfo: receiver!.toMap(),
          pdfUrl: '',
          isPaid: unit.rent! - int.parse(amountController.text.trim()) < 1 ? true : false,
          bills: [
            Bill(
              timestamp: DateTime.now().millisecondsSinceEpoch,
              billType: "Rent",
              details: "",
              period: period,
              paidAmount: int.parse(amountController.text.trim()),
              actualAmount: unit.rent,
              balance: unit.rent! - int.parse(amountController.text.trim()),
              isPaid: unit.rent! - int.parse(amountController.text.trim()) < 1 ? true : false,
            ).toMap(),
          ],
          unitInfo: unit.toMap(),
          propertyInfo: property!.toMap(),
        );

        //save pdf to document
        final String pdfUrl = await PdfInvoiceApi.generateInvoice(sender, invoiceDetails);

        Invoice invoiceFinal = Invoice(
          invoiceID: invoiceID.toUpperCase(),
          timestamp: DateTime.now().millisecondsSinceEpoch,
          senderInfo: sender.toMap(),
          receiverInfo: receiver!.toMap(),
          pdfUrl: pdfUrl,
          isPaid: unit.rent! - int.parse(amountController.text.trim()) < 1 ? true : false,
          bills: [
            Bill(
              timestamp: DateTime.now().millisecondsSinceEpoch,
              billType: "Rent",
              details: "",
              period: period,
              paidAmount: int.parse(amountController.text.trim()),
              actualAmount: unit.rent,
              balance: unit.rent! - int.parse(amountController.text.trim()),
              isPaid: unit.rent! - int.parse(amountController.text.trim()) < 1 ? true : false,
            ).toMap(),
          ],
          unitInfo: unit.toMap(),
          propertyInfo: property!.toMap(),
        );

        String res = await Transactions().payRent(transaction, invoiceFinal, sender, receiver!, unit);

        if(res == "success")
        {

          await

          showDialog(
              context: context,
              barrierDismissible: true,
              builder: (c) {
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      Icon(Icons.check_circle_outline_rounded, color: Colors.teal, size: 70.0,),
                      SizedBox(
                        height: 10,
                      ),
                      Text("Payment Successful!", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: ()=> Navigator.pop(context),
                      child: const Text("Close"),
                    )
                  ],
                );
              }
          );

          await context.read<TransactionProvider>().setIsPaying(false);

          Fluttertoast.showToast(msg: "Payment Successful!");
        }
        else
        {
          await context.read<TransactionProvider>().setIsPaying(false);

          showDialog(
              context: context,
              barrierDismissible: true,
              builder: (c) {
                return ErrorAlertDialog(message: "Error: $res",);
              }
          );
        }
      }
    else
      {
        await context.read<TransactionProvider>().setIsPaying(false);

        Fluttertoast.showToast(msg: "Payment not made");
      }

  }

  showConfirmationRequest(BuildContext context, Account account, Unit unit, bool isMobile) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (c) {
          return AlertDialog(
            title: const Text("Confirm Request"),
            content: const Text("Do you want to vacate the property? A request will be sent to your landlord."),
            actions: [
              RaisedButton.icon(
                onPressed: () {
                  Navigator.pop(context);

                  displayCalendar(context, account, unit, isMobile);
                },
                color: Colors.red,
                icon: const Icon(Icons.warning_amber_rounded, color: Colors.white,),
                label: const Text('Request', style: TextStyle(color: Colors.white)),
              )
            ],
          );
        }
    );
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is DateTime) {
        selectedDate = args.value;
      }
    });
  }

  displayCalendar(BuildContext context, Account account, Unit unit, bool isMobile) {
    Size size = MediaQuery.of(context).size;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Select Date to vacate property"),
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
              initialSelectedDate: selectedDate,
              // initialSelectedRange: PickerDateRange(
              //     DateTime.fromMillisecondsSinceEpoch(startDate),
              //     DateTime.fromMillisecondsSinceEpoch(endDate)
              // ),
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: ()=> setExpiryLeaseDate(account, unit),
              icon: Icon(Icons.done, color: Theme.of(context).primaryColor),
              label: Text("Done", style: TextStyle(color: Theme.of(context).primaryColor),),
            )
          ],
        );
      },
    );
  }

  setExpiryLeaseDate(Account account, Unit unit) async {
    Property? property;

    await FirebaseFirestore.instance.collection("properties").doc(unit.propertyID).get().then((value) {
      setState(() {
        property = Property.fromDocument(value);
      });
    });

    LeaseExpiry expiry = LeaseExpiry(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      expiryDate: selectedDate.millisecondsSinceEpoch,
      userInfo: account.toMap(),
      unitInfo: unit.toMap(),
      propertyInfo: property!.toMap(),
    );

    await FirebaseFirestore.instance.collection("users").doc(unit.publisherID)
        .collection("leaseExpiry").doc(expiry.timestamp.toString()).set(expiry.toMap());

    Fluttertoast.showToast(msg: "Lease Expiry set Successfully");

    Navigator.pop(context);
  }

  Widget _buildForMobile(Account account, Size size, int startDate, int endDate, bool isPaying) {
    String start = DateFormat("dd MMM yyyy")
        .format(DateTime.fromMillisecondsSinceEpoch(startDate));

    String end = DateFormat("dd MMM yyyy")
        .format(DateTime.fromMillisecondsSinceEpoch(endDate));

    return  isPaying ? LoadingAnimation() :  Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
                color: Colors.black26, width: 1.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text(
                "Billing",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "$start - $end",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: RaisedButton.icon(
                elevation: 0.0,
                hoverColor: Colors.transparent,
                color: EKodi().themeColor,
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                label: const Text("Add Bill",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                onPressed: () => showBillOptions(context),
              ),
            ),
            const DefaultLineChart(),
            const Text(
              "My Property",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("users").doc(account.userID).collection("units").limit(1).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text("Loading...");
                } else {
                  List<Unit> units = [];

                  for (var element in snapshot.data!.docs) {
                    Unit unit =
                    Unit.fromDocument(element);

                    units.add(unit);
                  }

                  if (units.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.house_rounded,
                            color: Colors.grey,
                            size: 70.0,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            "You currently don't have a unit",
                            style: TextStyle(
                                color: Colors.grey),
                          )
                        ],
                      ),
                    );
                  } else {
                    bool isUnitAccepted = units[0].isAccepted!;

                    return SizedBox(
                      width: size.width,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(10.0),
                        ),
                        elevation: 5.0,
                        child: Padding(
                          padding:
                          const EdgeInsets.all(10.0),
                          child: isUnitAccepted ? Column(
                            mainAxisSize:
                            MainAxisSize.min,
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance.collection("properties").doc(units[0].propertyID).get(),
                                builder: (context, snap) {
                                  if (!snap.hasData) {
                                    return const Text("Property Info Loading");
                                  } else {
                                    Property property = Property.fromDocument(snap.data!);

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(property.name!, style: const TextStyle(fontWeight: FontWeight.bold,)),
                                        //const SizedBox(height: 5.0,),
                                        Text("${property.address}, ${property.city} ${property.country}",
                                          style: const TextStyle(
                                              fontWeight:
                                              FontWeight
                                                  .bold,
                                              color: Colors
                                                  .grey),
                                        ),
                                        //const SizedBox(height: 5.0,),
                                        Text(
                                          property.notes!,
                                          maxLines: 2,
                                          overflow:
                                          TextOverflow
                                              .ellipsis,
                                        ),
                                        Divider(
                                          color: Colors
                                              .grey
                                              .shade300,
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            //Text("Unit Information"),
                                            Text(units[0].name!,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                )),
                                            Text(units[0].description!, maxLines: 5, overflow: TextOverflow.ellipsis,),
                                            Text("Started on: " +
                                                DateFormat("dd MMM yyyy").format(DateTime.fromMillisecondsSinceEpoch(units[0].startDate!)),
                                              style: const TextStyle(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.all(2.0),
                                                child:
                                                Container(
                                                  width:
                                                  size.width,
                                                  //height: 100.0,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(5.0),
                                                      border: Border.all(
                                                        width: 1.0,
                                                        color: Colors.grey.shade300,
                                                      )),
                                                  child:
                                                  Center(
                                                    child:
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            "Rent Amount",
                                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
                                                          ),
                                                          Text(
                                                            "KES " + NumberFormat("###,###.0#", "en_US").format(units[0].rent),
                                                            style: TextStyle(color: EKodi().themeColor, fontWeight: FontWeight.bold),
                                                          ),
                                                          const SizedBox(
                                                            height: 5.0,
                                                          ),
                                                          Text(
                                                            "Due on: " + DateFormat("dd MMM yyyy").format(DateTime.fromMillisecondsSinceEpoch(units[0].dueDate!)),
                                                            style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.all(2.0),
                                                child:
                                                Container(
                                                  width:
                                                  size.width,
                                                  //height: 100.0,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(5.0),
                                                      border: Border.all(
                                                        width: 1.0,
                                                        color: Colors.grey.shade300,
                                                      )),
                                                  child:
                                                  Center(
                                                    child:
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            "Deposit Amount",
                                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
                                                          ),
                                                          Text(
                                                            "KES " + NumberFormat("###,###.0#", "en_US").format(units[0].deposit),
                                                            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                                                          ),
                                                          // const SizedBox(height: 5.0,),
                                                          // Text("Due on: " + DateFormat("dd MMM yyyy").format(DateTime.fromMillisecondsSinceEpoch(units[0].dueDate!)), style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height:
                                              10.0,
                                            )
                                          ],
                                        ),

                                      ],
                                    );
                                  }
                                },
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.end,
                                children: [
                                  RaisedButton(
                                    color:
                                    EKodi().themeColor,
                                    shape:
                                    RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                          5.0),
                                    ),
                                    child: const Text(
                                      "Pay Rent",
                                      style: TextStyle(
                                          color: Colors
                                              .white),
                                    ),
                                    onPressed: ()=> proceedToPayRent(account, units[0], size),
                                  ),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  InkWell(
                                    onTap: () => showConfirmationRequest(context, account, units[0], true),
                                    child: Container(
                                      height: 25.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius
                                              .circular(
                                              5.0),
                                          border: Border.all(
                                              color: EKodi().themeColor,
                                              width:
                                              1.0)),
                                      child:
                                      Padding(
                                        padding: const EdgeInsets
                                            .symmetric(
                                            horizontal:
                                            5.0),
                                        child: Center(
                                            child: Text(
                                              "Request to Leave Property",
                                              style: TextStyle(
                                                  color: EKodi().themeColor),
                                            )),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ) :  displayPrompt(account, size, units[0]),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  performResponse(Account account, Size size, Property property, Unit unit, String choice) async {
    if(choice == "denied")
      {
        await FirebaseFirestore.instance.collection("users").doc(account.userID).collection("units").doc(unit.unitID.toString()).get().then((value) async {
          if(value.exists)
            {
              await value.reference.delete();
            }
        });

        await FirebaseFirestore.instance.collection("users").doc(property.publisherID).collection("tenants").doc(account.userID).get().then((value) async {
          if(value.exists)
          {
            await value.reference.delete();
          }
        });

        await FirebaseFirestore.instance.collection("properties").doc(property.propertyID).get().then((value) async {
          await value.reference.update({
            "occupied": property.occupied! - 1,
            "vacant": property.vacant! + 1,
          });

          await value.reference.collection("units").doc(unit.unitID.toString()).get().then((unitSnap) async {
            if(unitSnap.exists)
            {
              Unit updatedUnit = Unit(
                unitID: unit.unitID,
                name: unit.name,
                description: unit.description,
                tenantInfo: {},
                isOccupied: false,
                rent: 0,
                dueDate: 0,
                propertyID: property.propertyID,
                deposit: 0,
                startDate: 0,
                paymentFreq: "",
                reminder: 0,
                publisherID: property.publisherID,
                isAccepted: false,
              );

              await unitSnap.reference.update(updatedUnit.toMap());
            }
          });
        });

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SplashScreen()));
      }
    else {
      //TODO: Prompt for rent and deposit payment
      //await proceedToPayRent(account, unit, size);

      //update unit info
      await FirebaseFirestore.instance.collection("users").doc(account.userID).collection("units").doc(unit.unitID.toString()).get().then((value) async {
        if(value.exists)
        {
          await value.reference.update({
            "isAccepted": true,
          });
        }
      });

      await FirebaseFirestore.instance.collection("properties").doc(property.propertyID).collection("units").doc(unit.unitID.toString()).get().then((value) async {
        if(value.exists)
        {
          await value.reference.update({
            "isAccepted": true,
          });
        }
      });

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SplashScreen()));
    }
  }

  Widget displayPrompt(Account account, Size size, Unit unit) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection("properties").doc(unit.propertyID).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Text("Property Info Loading");
        } else {
          Property property = Property.fromDocument(snap.data!);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text("You have been added to ${property.name}, unit ${unit.name}, rent payment of KES ${unit.rent} on ${unit.paymentFreq} basis and a deposit of KES ${unit.deposit}"),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 1,
                    child: TextButton(
                      onPressed: () => performResponse(account, size, property, unit, "denied"),
                      child: const Text("Cancel"),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: RaisedButton(
                      onPressed: () => performResponse(account, size, property, unit, "accepted"),
                      color: EKodi().themeColor,
                      child: const Text("Accept", style: TextStyle(color: Colors.white),),
                    ),
                  )
                ],
              )
            ],
          );
        }
      },
    );
  }

  Widget _buildForWeb(Account account, Size size, int startDate, int endDate, bool isPaying) {
    String start = DateFormat("dd MMM yyyy")
        .format(DateTime.fromMillisecondsSinceEpoch(startDate));

    String end = DateFormat("dd MMM yyyy")
        .format(DateTime.fromMillisecondsSinceEpoch(endDate));


    return isPaying ? LoadingAnimation() : Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
                color: Colors.black26, width: 1.0)),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text(
                      "Billing",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "$start - $end",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: RaisedButton.icon(
                      elevation: 0.0,
                      hoverColor: Colors.transparent,
                      color: EKodi().themeColor.withOpacity(0.3),
                      icon: Icon(
                        Icons.add,
                        color: EKodi().themeColor,
                      ),
                      label: Text("Add Bill",
                          style: TextStyle(
                              color: EKodi().themeColor,
                              fontWeight: FontWeight.bold)),
                      onPressed: () => showBillOptions(context),
                    ),
                  ),
                  const Text(
                    "My Property",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(account.userID)
                        .collection("units")
                        .limit(1)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text("Loading...");
                      } else {
                        List<Unit> units = [];

                        snapshot.data!.docs.forEach((element) {
                          Unit unit =
                          Unit.fromDocument(element);

                          units.add(unit);
                        });

                        if (units.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.house_rounded,
                                  color: Colors.grey,
                                  size: 70.0,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  "You currently don't have a unit",
                                  style: TextStyle(
                                      color: Colors.grey),
                                )
                              ],
                            ),
                          );
                        } else {
                          bool isUnitAccepted = units[0].isAccepted!;

                          return SizedBox(
                            width: size.width,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10.0),
                              ),
                              elevation: 5.0,
                              child: Padding(
                                padding:
                                const EdgeInsets.all(10.0),
                                child: isUnitAccepted ? Column(
                                  mainAxisSize:
                                  MainAxisSize.min,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    StreamBuilder<
                                        DocumentSnapshot>(
                                      stream: FirebaseFirestore
                                          .instance
                                          .collection(
                                          "properties")
                                          .doc(units[0]
                                          .propertyID)
                                          .snapshots(),
                                      builder: (context, snap) {
                                        if (!snap.hasData) {
                                          return const Text(
                                              "Property Info Loading");
                                        } else {
                                          Property property =
                                          Property
                                              .fromDocument(
                                              snap.data!);

                                          return Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .start,
                                            mainAxisSize:
                                            MainAxisSize
                                                .min,
                                            children: [
                                              Text(
                                                  property
                                                      .name!,
                                                  style:
                                                  const TextStyle(
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                  )),
                                              //const SizedBox(height: 5.0,),
                                              Text(
                                                "${property.address}, ${property.city} ${property.country}",
                                                style: const TextStyle(
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    color: Colors
                                                        .grey),
                                              ),
                                              //const SizedBox(height: 5.0,),
                                              Text(
                                                property.notes!,
                                                maxLines: 2,
                                                overflow:
                                                TextOverflow
                                                    .ellipsis,
                                              ),
                                              Divider(
                                                color: Colors
                                                    .grey
                                                    .shade300,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child:
                                                    Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .start,
                                                      mainAxisSize:
                                                      MainAxisSize
                                                          .min,
                                                      children: [
                                                        //Text("Unit Information"),
                                                        Text(
                                                            units[0]
                                                                .name!,
                                                            style:
                                                            const TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                            )),
                                                        Text(
                                                          units[0]
                                                              .description!,
                                                          maxLines:
                                                          5,
                                                          overflow:
                                                          TextOverflow.ellipsis,
                                                        ),
                                                        Text(
                                                          "Started on: " +
                                                              DateFormat("dd MMM yyyy").format(DateTime.fromMillisecondsSinceEpoch(units[0].startDate!)),
                                                          style: const TextStyle(
                                                              fontSize: 12.0,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets.all(2.0),
                                                        child:
                                                        Container(
                                                          width:
                                                          size.width * 0.15,
                                                          //height: 100.0,
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(5.0),
                                                              border: Border.all(
                                                                width: 1.0,
                                                                color: Colors.grey.shade300,
                                                              )),
                                                          child:
                                                          Center(
                                                            child:
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  const Text(
                                                                    "Rent Amount",
                                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
                                                                  ),
                                                                  Text(
                                                                    "KES " + NumberFormat("###,###.0#", "en_US").format(units[0].rent),
                                                                    style: TextStyle(color: EKodi().themeColor, fontWeight: FontWeight.bold),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5.0,
                                                                  ),
                                                                  Text(
                                                                    "Due on: " + DateFormat("dd MMM yyyy").format(DateTime.fromMillisecondsSinceEpoch(units[0].dueDate!)),
                                                                    style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets.all(2.0),
                                                        child:
                                                        Container(
                                                          width:
                                                          size.width * 0.15,
                                                          //height: 100.0,
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(5.0),
                                                              border: Border.all(
                                                                width: 1.0,
                                                                color: Colors.grey.shade300,
                                                              )),
                                                          child:
                                                          Center(
                                                            child:
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  const Text(
                                                                    "Deposit Amount",
                                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
                                                                  ),
                                                                  Text(
                                                                    "KES " + NumberFormat("###,###.0#", "en_US").format(units[0].deposit),
                                                                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                                                                  ),
                                                                  // const SizedBox(height: 5.0,),
                                                                  // Text("Due on: " + DateFormat("dd MMM yyyy").format(DateTime.fromMillisecondsSinceEpoch(units[0].dueDate!)), style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height:
                                                        10.0,
                                                      )
                                                    ],
                                                  )
                                                ],
                                              )
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.end,
                                      children: [
                                        RaisedButton(
                                          color:
                                          EKodi().themeColor,
                                          shape:
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius
                                                .circular(
                                                5.0),
                                          ),
                                          child: const Text(
                                            "Pay Rent",
                                            style: TextStyle(
                                                color: Colors
                                                    .white),
                                          ),
                                          onPressed: ()=> proceedToPayRent(account, units[0], size),
                                        ),
                                        const SizedBox(
                                          width: 5.0,
                                        ),
                                        InkWell(
                                          onTap: () => showConfirmationRequest(context, account, units[0], false),
                                          child: Container(
                                            height: 25.0,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius
                                                    .circular(
                                                    5.0),
                                                border: Border.all(
                                                    color: EKodi().themeColor,
                                                    width:
                                                    1.0)),
                                            child:
                                            Padding(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                  5.0),
                                              child: Center(
                                                  child: Text(
                                                    "Request to Leave Property",
                                                    style: TextStyle(
                                                        color: EKodi().themeColor),
                                                  )),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ) : displayPrompt(account, size, units[0]),
                              ),
                            ),
                          );
                        }
                      }
                    },
                  )
                ],
              ),
            ),
            const Expanded(
              flex: 1,
              child: DefaultLineChart(),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    int startDate = context.watch<DatePeriodProvider>().startDate;
    int endDate = context.watch<DatePeriodProvider>().endDate;
    String currentTab = context.watch<TabProvider>().currentTab;
    bool isChatOpen = context.watch<ChatProvider>().isOpen;
    
    bool isPaying = context.watch<TransactionProvider>().isPaying;

    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile || sizeInfo.isTablet;

        return isMobile
            ? _buildForMobile(account, size, startDate, endDate, isPaying)
            : _buildForWeb(account, size, startDate, endDate, isPaying);
      },
    );
  }
}
