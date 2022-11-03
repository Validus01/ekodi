import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/config.dart';
import 'package:rekodi/model/account.dart';
import 'package:rekodi/model/report.dart';
import 'package:rekodi/providers/tabProvider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class Reports extends StatefulWidget {
  const Reports({Key? key}) : super(key: key);

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  Widget _buildLayout(Account account, Size size, bool isMobile) {
    List<Widget> list = [
      ReportCard(
        title: "Income Expense Statement",
        description:
            "This is a profit and loss report that shows you all the income and expenses that have been assigned to a property.",
        onTap: () {
          //Route route = MaterialPageRoute(builder: (context)=> const IncomeExpenseStatement());
          //isMobile ? Navigator.push(context, route) :
          context.read<TabProvider>().changeTab("IncomeExpenseStatement");
        },
      ),
      ReportCard(
        title: "Overdue Rent Payment",
        description:
            "Displays a list of all overdue rent payments within a period of time.",
        onTap: () {
          //Route route = MaterialPageRoute(builder: (context)=> const OverdueRentPayments());
          //isMobile ? Navigator.push(context, route) :
          context.read<TabProvider>().changeTab("OverdueRentPayments");
        },
      ),
      ReportCard(
        title: "Rent Ledger Report",
        description: "Displays a list of all rent payments over a time period",
        onTap: () {
          //Route route = MaterialPageRoute(builder: (context)=> const RentLedgerReport());
          //isMobile ? Navigator.push(context, route) :
          context.read<TabProvider>().changeTab("RentLedgerReport");
        },
      ),
      ReportCard(
        title: "Service Provider Report",
        description: "A detailed report on service providers.",
        onTap: () {
          //Route route = MaterialPageRoute(builder: (context)=> const ServiceProviderReport());
          //isMobile ? Navigator.push(context, route) :
          context.read<TabProvider>().changeTab("ServiceProviderReport");
        },
      ),
      ReportCard(
        title: "Task Report",
        description: "Get Detailed report on recent tasks",
        onTap: () {
          //Route route = MaterialPageRoute(builder: (context)=> const TaskReport());
          //isMobile ? Navigator.push(context, route) :
          context.read<TabProvider>().changeTab("TaskReport");
        },
      ),
      ReportCard(
        title: "Lease Expiry Report",
        description:
            "Displays a report of leases that will expire within the given period.",
        onTap: () {
          //Route route = MaterialPageRoute(builder: (context)=> const LeaseExpiryReport());
          //isMobile ? Navigator.push(context, route) :
          context.read<TabProvider>().changeTab("LeaseExpiryReport");
        },
      ),
      ReportCard(
        title: "Tenant Screening Report",
        description: "Get reports for the tenants you have screened",
        onTap: () {
          //Route route = MaterialPageRoute(builder: (context)=> const TenantScreeningReport());
          //isMobile ? Navigator.push(context, route) :
          context.read<TabProvider>().changeTab("TenantScreeningReport");
        },
      ),
      // RaisedButton(
      //   onPressed: () async {
      //     await FirebaseFirestore.instance
      //         .collection("users")
      //         .doc("tFbsISDntMNzEB4VQIux3eOqvDf2")
      //         .collection("reports")
      //         .get()
      //         .then((querySnapshot) async {
      //       await FirebaseFirestore.instance
      //           .collection("users")
      //           .doc("tFbsISDntMNzEB4VQIux3eOqvDf2")
      //           .collection("reports")
      //           .doc(querySnapshot.docs[0].id)
      //           .set({
      //         "name": "Rent Ledger Report",
      //       }, SetOptions(merge: true)).then(
      //               (value) => print("Updated Successfully"));
      //     });
      //   },
      //   child: Text("Fix Report"),
      // )
    ];

    return isMobile
        ? SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                "Reports",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(
                height: 10.0,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: list,
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                "Recently Generated Reports",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(
                height: 10.0,
              ),
              generatedReports(account, size),
              const SizedBox(
                height: 50.0,
              ),
            ]),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Reports",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(
                height: 10.0,
              ),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                childAspectRatio: size.width * 0.5 / 300.0,
                children: list,
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                "Recently Generated Reports",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(
                height: 10.0,
              ),
              generatedReports(account, size),
              const SizedBox(
                height: 50.0,
              ),
            ],
          );
  }

  viewPdf(Report report, Size size) {
    showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            title: Text("Report: ${report.name}"),
            contentPadding: EdgeInsets.zero,
            content: SizedBox(
              height: size.height * 0.9,
              width: size.width * 0.6,
              child: SfPdfViewer.network(report.url!,
                  pageLayoutMode: PdfPageLayoutMode.single),
            ),
            actions: [
              RaisedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                color: EKodi.themeColor,
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          );
        });
  }

  Future<void> _downloadPdf(String url) async {
    try {
      await launch(url);
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to download");
    }
  }

  Widget generatedReports(Account account, Size size) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(account.userID!)
          .collection("reports")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text("Loading...");
        } else {
          List<Report> reports = [];

          snapshot.data!.docs.forEach((element) {
            Report report = Report.fromDocument(element);

            reports.add(report);
          });

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(reports.length, (index) {
              Report report = reports[index];

              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: Card(
                  child: ListTile(
                    leading: Image.asset(
                      "assets/pdf.png",
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.contain,
                    ),
                    title: Text(
                      report.name!,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat("HH:mm, dd MMM").format(
                            DateTime.fromMillisecondsSinceEpoch(
                                report.timestamp!))),
                        Text("Period: ${report.period}"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => viewPdf(report, size),
                          child: const Text(
                            "View",
                          ),
                        ),
                        IconButton(
                            onPressed: () => _downloadPdf(
                                report.url!), //todo: change to view
                            icon: const Icon(
                              Icons.cloud_download_outlined,
                              color: EKodi.themeColor,
                            )),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Account account = context.watch<EKodi>().account;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile || sizeInfo.isTablet;

        return _buildLayout(account, size, isMobile);
      },
    );
  }
}

class ReportCard extends StatelessWidget {
  final String? title;
  final String? description;
  final Function()? onTap;

  const ReportCard({Key? key, this.title, this.description, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
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
            border: Border.all(width: 0.5, color: Colors.grey.shade300)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.insert_chart_outlined,
                    color: EKodi.themeColor,
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    title!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Text(
                description!,
                style: GoogleFonts.baloo2(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  InkWell(
                    onTap: onTap,
                    child: Container(
                      height: 30.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.0),
                          border:
                              Border.all(color: EKodi.themeColor, width: 1.0)),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Center(
                            child: Text(
                          "View",
                          style: TextStyle(color: EKodi.themeColor),
                        )),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
