import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/model/invoice.dart';
import 'package:rekodi/model/property.dart';
import 'package:rekodi/widgets/addInvoice.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../model/account.dart';
import '../providers/tabProvider.dart';

class InvoicePage extends StatefulWidget {
  final List<Property>? properties;
  const InvoicePage({Key? key, this.properties}) : super(key: key);

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  Future<void> _downloadPdf(String url) async {
    try {
      await launch(url);
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to download");
    }
  }

  viewPdf(Invoice invoice, Size size) {
    showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            title: Text("Invoice: ${invoice.invoiceID}"),
            contentPadding: EdgeInsets.zero,
            content: SizedBox(
              height: size.height * 0.9,
              width: size.width * 0.6,
              child: SfPdfViewer.network(invoice.pdfUrl!,
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

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile || sizeInfo.isTablet;
        return SingleChildScrollView(
          physics: isMobile
              ? const BouncingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20.0,
              ),
              TextButton.icon(
                onPressed: () =>
                    context.read<TabProvider>().changeTab("Accounting"),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.grey,
                ),
                label: const Text(
                  "Back",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Text(
                "Invoices",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(
                height: 10.0,
              ),
              //show recent invoices
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
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Recent Invoices",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Divider(
                        color: Colors.grey.shade300,
                      ),
                      FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("users")
                            .doc(account.userID)
                            .collection("invoices")
                            .orderBy("timestamp", descending: true)
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text("Loading...");
                          } else {
                            List<Invoice> invoices = [];

                            for (var element in snapshot.data!.docs) {
                              invoices.add(Invoice.fromDocument(element));
                            }

                            if (invoices.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.receipt_long_rounded,
                                        color: Colors.grey.shade300,
                                      ),
                                      const SizedBox(
                                        height: 5.0,
                                      ),
                                      const Text("No Invoices")
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children:
                                    List.generate(invoices.length, (index) {
                                  Invoice invoice = invoices[index];

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: ListTile(
                                              leading: Image.asset(
                                                "assets/pdf.png",
                                                width: 50.0,
                                                height: 50.0,
                                                fit: BoxFit.contain,
                                              ),
                                              title: Text(
                                                invoice.invoiceID!
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              subtitle: Text(DateFormat(
                                                      "HH:mm, dd MMM")
                                                  .format(DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          invoice.timestamp!))),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        viewPdf(invoice, size),
                                                    child: const Text(
                                                      "View",
                                                    ),
                                                  ),
                                                  IconButton(
                                                      onPressed: () =>
                                                          _downloadPdf(invoice
                                                              .pdfUrl!), //todo: change to view
                                                      icon: const Icon(
                                                        Icons
                                                            .cloud_download_outlined,
                                                        color: EKodi.themeColor,
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                          ListTile(
                                            title: Text(
                                                "From: ${invoice.senderInfo!["name"]}"),
                                            subtitle: Text(
                                                "To: ${invoice.receiverInfo!["name"]}"),
                                          )
                                        ],
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
              ),
              const SizedBox(
                height: 10.0,
              ),
              Text(
                "Create New Invoice",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(
                height: 10.0,
              ),
              AddInvoice(
                properties: widget.properties,
              ),
              const SizedBox(
                height: 50.0,
              ),
            ],
          ),
        );
      },
    );
  }
}
