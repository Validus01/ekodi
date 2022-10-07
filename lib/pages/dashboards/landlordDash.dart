import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/chat/chatBuilder.dart';
import 'package:rekodi/chat/chatDetails.dart';
import 'package:rekodi/chat/chatHome.dart';
import 'package:rekodi/commonFunctions/autoGnerate.dart';
import 'package:rekodi/model/property.dart';
import 'package:rekodi/model/tabItem.dart';
import 'package:rekodi/pages/accountingPage.dart';
import 'package:rekodi/pages/addProperty.dart';
import 'package:rekodi/pages/addTenant.dart';
import 'package:rekodi/pages/invoicePage.dart';
import 'package:rekodi/pages/profilePage.dart';
import 'package:rekodi/pages/properties.dart';
import 'package:rekodi/pages/propertyDetails.dart';
import 'package:rekodi/pages/propertyImages.dart';
import 'package:rekodi/pages/reportPages/IncomeExpenseStatement.dart';
import 'package:rekodi/providers/accountingProvider.dart';
import 'package:rekodi/providers/datePeriod.dart';
import 'package:rekodi/providers/propertyProvider.dart';
import 'package:rekodi/widgets/customAppBar.dart';
import 'package:rekodi/widgets/customDashDrawer.dart';
import 'package:rekodi/widgets/customFooter.dart';
import 'package:rekodi/widgets/dateSelector.dart';
import 'package:rekodi/widgets/expiringLeases.dart';
import 'package:rekodi/widgets/invoicesCard.dart';
import 'package:rekodi/widgets/loadingAnimation.dart';
import 'package:rekodi/widgets/outstandingCard.dart';
import 'package:rekodi/widgets/propertiesCard.dart';
import 'package:rekodi/widgets/recentTransactionsCard.dart';
import 'package:rekodi/widgets/revenueOverview.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../chat/chatProvider/chatProvider.dart';
import '../../config.dart';
import '../../model/account.dart';
import '../../providers/tabProvider.dart';
import '../../widgets/bulkSmsSection.dart';
import '../reportPages/OverdueRentPayments.dart';
import '../reportPages/RentLedgerReport.dart';
import '../reportPages/leaseEpiryReport.dart';
import '../reportPages/serviceProviderReport.dart';
import '../reportPages/taskReport.dart';
import '../reportPages/tenantScreeningReport.dart';
import '../reportsPage.dart';


class LandlordDash extends StatefulWidget {
  const LandlordDash({Key? key}) : super(key: key);

  @override
  State<LandlordDash> createState() => _LandlordDashState();
}

class _LandlordDashState extends State<LandlordDash> {
  _LandlordDashState();
  bool loading = false;

  @override
  void initState() {
    super.initState();

    checkForPaymentMethods();
  }

  checkForPaymentMethods() async {
    String userID = Provider.of<EKodi>(context, listen: false).account.userID!;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(userID)
        .collection("paymentInfo").get().then((value) {
          if(value.docs.isEmpty)
            {
              Timer(const Duration(seconds: 7), () async {

                promptPaymentMethod();
              });
            }
    });
  }

  promptPaymentMethod() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        return AlertDialog(
          title: const Text("Setup Payment Method"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {},
                  leading: Image.asset("assets/mpesa.png", height: 50.0, width: 50.0, fit: BoxFit.contain,),
                  title: const Text("M-Pesa"),
                  subtitle: const Text("Setup your Paybill or Buy Goods"),
                ),
                ListTile(
                  onTap: () {},
                  leading: Image.asset("assets/visa.png", height: 50.0, width: 50.0, fit: BoxFit.contain,),
                  title: const Text("Bank"),
                  subtitle: const Text("Setup your bank details"),
                ),
              ],
            ),
          ),
          actions: [
            RaisedButton(
              color: EKodi().themeColor,
              onPressed: () {Navigator.pop(context);},
              child: const Text("Close", style: TextStyle(color: Colors.white),),
            )
          ],
        );
      }
    );
  }



  addNewProperty() async {

    context.read<TabProvider>().changeTab("AddProperty");

  }


  displayTab(Account account, String currentTab, Size size, SizingInformation sizeInfo,
      List<Property> properties, int occupiedUnits, int vacantUnits, {int? start, int? end}) {

    switch (currentTab) {
      case "Dashboard":
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size.width,
              height: 60.0,
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Text(
                        currentTab,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .apply(
                            color: Colors.black,
                            //fontWeightDelta: 10,
                        ),
                      ),
                      Text(
                        "Hi ${account.name!}, Welcome to e-Ekodi",
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  currentTab == "Accounting" ? RaisedButton.icon(
                    hoverColor: Colors.transparent,
                    label: const Text(
                      "Invoices",
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                    color: Colors.deepPurple.shade100,
                    elevation: 0.0,
                    onPressed: ()=> context.read<AccountingProvider>().changeToInvoicing(true),
                    icon: const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.deepPurple,
                    ),
                  ) : Container(),
                  const DateSelector(),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding:
                        const EdgeInsets.only(top: 10.0, right: 15.0, bottom: 5.0),
                        child: Container(
                          width: size.width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: properties.isNotEmpty
                                  ? Colors.white
                                  : Colors.transparent,
                              boxShadow: properties.isNotEmpty
                                  ? [
                                const BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 1,
                                    spreadRadius: 1.0,
                                    offset: Offset(0.0, 0.0))
                              ]
                                  : [],
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: properties.isNotEmpty ? 0.0 : 1.0,
                              )),
                          child: properties.isNotEmpty
                              ? const RevenueOverview()
                              : Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 30.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RaisedButton.icon(
                                    hoverColor: Colors.transparent,
                                    label: const Text(
                                      "New Property",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    color: EKodi().themeColor,
                                    elevation: 0.0,
                                    onPressed: addNewProperty,
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Expanded(
                              flex: 1,
                              child: RecentTransactionsCard(),
                            ),
                            Expanded(
                              flex: 1,
                              child: ExpiringLeases(),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment:
                    MainAxisAlignment.start,
                    children: [
                      PropertiesCard(
                          properties: properties,
                          vacantUnits: vacantUnits,
                          occupiedUnits: occupiedUnits,
                          onPressed: () => context.read<TabProvider>().changeTab("Properties")
                        // displayProperties(
                        //     account),
                      ),
                      const InvoicesCard(),
                      const OutstandingCard()
                    ],
                  ),
                )
              ],
            )
          ],
        );
      case "Accounting":
        return const Padding(
          padding: EdgeInsets.only(right: 15.0, top: 10.0),
          child: Accounting(),
        );
      case "Reports":
        return const Padding(
          padding: EdgeInsets.only(top: 5.0, right: 10.0),
          child: Reports(),
        );
      case "Messages":
        return Padding(
          padding: const EdgeInsets.only(right: 15.0, top: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              ChatBuilder(),
              SizedBox(height: 15.0,),
              BulkSMSSection(),
              SizedBox(height: 30.0,),
            ],
          ),
        );
      case "Tasks":
        return const Center(
          child: Text("Tasks"),
        );
      case "Profile":
        return const ProfilePage();
      case "Properties":
        return const Properties();
      case "PropertyDetails":
        return const PropertyDetails();
      case "AddTenant":
        return const AddTenant();
      case "PropertyImages":
        return const PropertyImagesPage();
      case "Invoice":
        return InvoicePage(properties: properties,);
      case "AddProperty":
        return const AddProperty();
      case "IncomeExpenseStatement":
        return const IncomeExpenseStatement();
      case "OverdueRentPayments":
        return const OverdueRentPayments();
      case "RentLedgerReport":
        return const RentLedgerReport();
      case "ServiceProviderReport":
        return const ServiceProviderReport();
      case "TaskReport":
        return const TaskReport();
      case "LeaseExpiryReport":
        return const LeaseExpiryReport();
      case "TenantScreeningReport":
        return const TenantScreeningReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    int startDate = context.watch<DatePeriodProvider>().startDate;
    int endDate = context.watch<DatePeriodProvider>().endDate;
    String currentTab = context.watch<TabProvider>().currentTab;

    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('properties')
              .where("publisherID", isEqualTo: account.userID)
              .orderBy("timestamp", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if(!snapshot.hasData)
              {
                return const LoadingAnimation();
              }
            else
              {
                List<Property> properties = [];
                int vacantUnits = 0;
                int occupiedUnits = 0;

                for (var element in snapshot.data!.docs) {
                  Property property = Property.fromDocument(element);

                  properties.add(property);

                  vacantUnits = vacantUnits + property.vacant!.toInt();

                  occupiedUnits = occupiedUnits + property.occupied!.toInt();
                }

                //TODO: AutoGenerate().autoGenerateInvoice(account, properties);


                return Scaffold(
                  backgroundColor: Colors.grey.shade50,
                  body: loading
                      ? const LoadingAnimation()
                      : Row(
                    children: [
                      const Expanded(
                        flex: 2,
                        child: CustomDashDrawer(),
                      ),
                      Expanded(
                        flex: 8,
                        child: Column(
                          //mainAxisSize: MainAxisSize.min,
                          children: [
                            PreferredSize(
                              preferredSize: Size(size.width, 60.0),
                              child: DashboardAppBar(
                                automaticallyImplyLeading: false,
                                addPropertyButton: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 15.0),
                                  child: RaisedButton.icon(
                                    label: const Text(
                                      "New Property",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    color: EKodi().themeColor,
                                    elevation: 0.0,
                                    onPressed: addNewProperty,
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Stack(
                                children: [
                                  SizedBox(
                                    height: size.height,
                                    width: size.width,
                                  ),
                                  Positioned(
                                    top: 0.0,
                                    left: 0.0,
                                    child: Image.asset("assets/images/baner_dec_left.png"),
                                  ),
                                  Positioned(
                                    top: 0.0,
                                    right: 0.0,
                                    child: Image.asset("assets/images/baner_dec_right.png"),
                                  ),
                                  Positioned(
                                    top: 0.0,
                                    bottom: 0.0,
                                    left: 0.0,
                                    right: 0.0,
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: size.width * 0.03),
                                        child: displayTab(account,currentTab, size, sizeInfo,
                                            properties, occupiedUnits, vacantUnits,
                                            start: startDate, end: endDate),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
          },
        );
      },
    );
  }
}

class LandlordDashMobile extends StatefulWidget {
  const LandlordDashMobile({Key? key}) : super(key: key);

  @override
  State<LandlordDashMobile> createState() => _LandlordDashMobileState();
}

class _LandlordDashMobileState extends State<LandlordDashMobile> {
  _LandlordDashMobileState();
  //bool loading = false;

  @override
  void initState() {
    super.initState();

    checkForPaymentMethods();
  }

  checkForPaymentMethods() async {
    String userID = Provider.of<EKodi>(context, listen: false).account.userID!;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(userID)
        .collection("paymentInfo").get().then((value) {
      if(value.docs.isEmpty)
      {
        Timer(const Duration(seconds: 7), () async {

          promptPaymentMethod();
        });
      }
    });
  }

  promptPaymentMethod() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) {
          return AlertDialog(
            title: const Text("Setup Payment Method"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    onTap: () {},
                    leading: Image.asset("assets/mpesa.png", height: 50.0, width: 50.0, fit: BoxFit.contain,),
                    title: const Text("M-Pesa"),
                    subtitle: const Text("Setup your Paybill or Buy Goods"),
                  ),
                  ListTile(
                    onTap: () {},
                    leading: Image.asset("assets/visa.png", height: 50.0, width: 50.0, fit: BoxFit.contain,),
                    title: const Text("Bank"),
                    subtitle: const Text("Setup your bank details"),
                  ),
                ],
              ),
            ),
            actions: [
              RaisedButton(
                color: EKodi().themeColor,
                onPressed: () {Navigator.pop(context);},
                child: const Text("Close", style: TextStyle(color: Colors.white),),
              )
            ],
          );
        }
    );
  }
  
  addNewProperty() async {

    context.read<TabProvider>().changeTab("AddProperty");

  }

  displayTabs(Size size, String currentTab,
      List<Property> properties, int occupiedUnits, int vacantUnits, bool isChatOpen, Account account) {
    switch (currentTab) {
      case "Dashboard":
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: DateSelector(),
              ),
              properties.isNotEmpty
                  ? const RevenueOverview()
                  : Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    child: Container(
                        width: size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.0,
                            )
                        ),
                      child: Center(
                child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RaisedButton.icon(
                            hoverColor: Colors.transparent,
                            label: Text(
                              "New Property",
                              style: TextStyle(color: EKodi().themeColor),
                            ),
                            color: EKodi().themeColor.withOpacity(0.1),
                            elevation: 0.0,
                            onPressed: addNewProperty,
                            icon: Icon(
                              Icons.add,
                              color: EKodi().themeColor,
                            ),
                          ),
                        ],
                      ),
                ),
              ),
                    ),
                  ),
              const ExpiringLeases(),
              PropertiesCard(
                properties: properties,
                vacantUnits: vacantUnits,
                occupiedUnits: occupiedUnits,
                onPressed: () async {
                  context.read<TabProvider>().changeTab("Properties");
                },
              ),
              const InvoicesCard(),
              const RecentTransactionsCard(),
              const OutstandingCard(),
            ],
          ),
        );
      case "Accounting":
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                DateSelector(),
                SizedBox(height: 10.0,),
                Accounting(),
              ],
            ),
          ),
        );
      case "Reports":
        return const Reports();
      case "Messages":
        return isChatOpen ? const ChatDetails() : const ChatHome();
      case "Tasks":
        return const Center(
          child: Text("Tasks"),
        );
      case "Profile":
        return const ProfilePage();
      case "Properties":
        return const Properties();
      case "PropertyDetails":
        return const PropertyDetails();
      case "AddTenant":
        return const AddTenant();
      case "PropertyImages":
        return const PropertyImagesPage();
      case "Invoice":
        return InvoicePage(properties: properties,);
      case "AddProperty":
        return const AddProperty();
      case "IncomeExpenseStatement":
        return const IncomeExpenseStatement();
      case "OverdueRentPayments":
        return const OverdueRentPayments();
      case "RentLedgerReport":
        return const RentLedgerReport();
      case "ServiceProviderReport":
        return const ServiceProviderReport();
      case "TaskReport":
        return const TaskReport();
      case "LeaseExpiryReport":
        return const LeaseExpiryReport();
      case "TenantScreeningReport":
        return const TenantScreeningReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    int startDate = context.watch<DatePeriodProvider>().startDate;
    int endDate = context.watch<DatePeriodProvider>().endDate;
    String currentTab = context.watch<TabProvider>().currentTab;
    bool isChatOpen = context.watch<ChatProvider>().isOpen;

    Size size = MediaQuery.of(context).size;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('properties')
          .where("publisherID", isEqualTo: account.userID)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData)
          {
            return const LoadingAnimation();
          }
        else 
          {
            List<Property> properties = [];
            int vacantUnits = 0;
            int occupiedUnits = 0;

            for (var element in snapshot.data!.docs) {
              Property property = Property.fromDocument(element);

              properties.add(property);

              vacantUnits = vacantUnits + property.vacant!.toInt();

              occupiedUnits = occupiedUnits + property.occupied!.toInt();
            }

            return Scaffold(
              backgroundColor: Colors.grey.shade50,
              drawer: const CustomDashDrawer(),
              floatingActionButton: currentTab == "Dashboard" ? FloatingActionButton(
                child: const Icon(Icons.add, color: Colors.white),
                onPressed: addNewProperty,
                backgroundColor: EKodi().themeColor,
              ) : Container(),
              appBar: PreferredSize(
                preferredSize: Size(size.width, 60.0),
                child: DashboardAppBar(
                  automaticallyImplyLeading: true,
                  addPropertyButton: Container(),
                ),
              ),
              body: Stack(
                children: [
                  SizedBox(
                    height: size.height,
                    width: size.width,
                  ),
                  Positioned(
                    top: 0.0,
                    left: 0.0,
                    child: Image.asset("assets/images/baner_dec_left.png"),
                  ),
                  Positioned(
                    top: 0.0,
                    right: 0.0,
                    child: Image.asset("assets/images/baner_dec_right.png"),
                  ),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    top: 0.0,
                    child: displayTabs(size, currentTab, properties, occupiedUnits, vacantUnits, isChatOpen, account),
                  )
                ],
              ),
            );
          }
      },
    );
  }
}
