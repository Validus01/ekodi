
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:rekodi/APIs/pdfApi.dart';
import 'package:rekodi/model/account.dart';

import '../model/invoice.dart';

class PdfInvoiceApi {
  static Future<String> generateInvoice(Account account, Invoice invoice) async {
    final pdf = Document();

    pdf.addPage(Page(
        pageFormat: PdfPageFormat.a4,
        build: (Context context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildTitle(invoice),
              SizedBox(height: 0.8*PdfPageFormat.cm),
              buildInvoice(invoice),
              Divider(),
              SizedBox(height: 0.8*PdfPageFormat.cm),
              buildTotal(invoice)
            ]
          ); // Center
        })); //

    return PdfApi.saveDocument(name: "INVOICE_${invoice.invoiceID!.toUpperCase()}.pdf", pdf: pdf, account: account);
  }

  static Widget buildTitle(Invoice invoice) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                  text: 'e-',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: PdfColors.blue)),
              TextSpan(
                  text: 'KODI',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: PdfColors.red)),
            ],
          ),
        ),
        SizedBox(height: 0.8*PdfPageFormat.cm),
        Text("INVOICE", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 0.4*PdfPageFormat.cm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Invoice ID:\n${invoice.invoiceID!.toUpperCase()}", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 0.8*PdfPageFormat.cm),
                Text("Bill From", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 0.8*PdfPageFormat.cm),
                Text(invoice.receiverInfo!["name"]),
                SizedBox(height: 0.4*PdfPageFormat.cm),
                Text(invoice.receiverInfo!["email"]),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Invoice Date", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                    Text(DateFormat("yyyy-MM-dd").format(DateTime.fromMillisecondsSinceEpoch(invoice.timestamp!)), textAlign: TextAlign.right,),
                  ],
                ),
                SizedBox(height: 0.8*PdfPageFormat.cm),
                Text("Bill To", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 0.8*PdfPageFormat.cm),
                Text(invoice.senderInfo!["name"]),
                SizedBox(height: 0.4*PdfPageFormat.cm),
                Text(invoice.senderInfo!["email"]),
                SizedBox(height: 0.4*PdfPageFormat.cm),
                Text(invoice.propertyInfo!["name"]),
                SizedBox(height: 0.4*PdfPageFormat.cm),
                Text(invoice.unitInfo!["name"]),
              ],
            ),
          ],
        ),
      ]
    );
  }

  static Widget buildInvoice(Invoice invoice) {

    final headers = [
      "Bill",
      //"Details",
      "Period(DAYS)",
      "Date",
      "Amount(KES)"
      "Paid",
      "Balance"
    ];

    final data = invoice.bills!.map((bill) {
      return [
        bill["billType"],
       // bill["details"],
        bill["period"],
        DateFormat("dd MMM yyyy").format(DateTime.fromMillisecondsSinceEpoch(bill["timestamp"])),
        bill["actualAmount"],
        bill["paidAmount"],
        bill["balance"],
      ];
    }).toList();

    return Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(fontWeight: FontWeight.bold),
      headerDecoration: const BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30.0,
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerRight,
        2: Alignment.centerRight,
        3: Alignment.centerRight,
        4: Alignment.centerRight,
        5: Alignment.centerRight,
        //6: Alignment.centerRight,
      }
    );
  }

  static Widget buildTotal(Invoice invoice) {
    int total = 0;

    for (var bill in invoice.bills!)
      {
        total = (total + bill["paidAmount"]).toInt();
      }

    return Container(
      alignment: Alignment.bottomRight,
      child: Row(
        children: [
          Spacer(flex: 6),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildText(
                  title: "Net total",
                  value: "KES $total",
                  unite: true
                ),
                buildText(
                    title: "VAT 0%",
                    value: "KES 0",
                    unite: true
                ),
                Divider(),
                buildText(
                    title: "Total Amount:",
                    titleStyle: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold
                    ),
                    value: "KES $total",
                    unite: true
                ),
                SizedBox(height: 2*PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
                SizedBox(height: 0.5*PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400)
              ]
            )
          )
        ]
      )
    );
  }

  static buildText({
    required String title,
    required String value,
    double width = double.infinity,
    TextStyle? titleStyle,
    bool unite = false}) {
    final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(child: Text(title, style:  style)),
          Text(value, style: unite ? style : null),
        ]
      )
    );
  }

}