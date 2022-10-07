import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/providers/transactionProvider.dart';
import 'package:rekodi/widgets/spacingColumnChart.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:rekodi/model/transaction.dart' as account_transaction;

import '../config.dart';
import '../model/account.dart';
import '../providers/datePeriod.dart';


class RevenueOverview extends StatefulWidget {
  const RevenueOverview({Key? key}) : super(key: key);

  @override
  State<RevenueOverview> createState() => _RevenueOverviewState();
}

class _RevenueOverviewState extends State<RevenueOverview> {

  bool loading = false;
  int expenses = 0;
  int income = 0;

  @override
  void initState() {
    getTransactions();
    super.initState();
  }

  getTransactions() async {
    setState(() {
      loading = true;
    });

    Account account = Provider
        .of<EKodi>(context, listen: false)
        .account;

    await TransactionProvider().updateTransactionsDB(account);

    List<account_transaction.Transaction> transactions = await TransactionProvider().getAllTransactions(account);

    transactions.forEach((element) {
      if(element.paymentCategory == "Rent")
        {
          income = income + element.paidAmount!;
        }
      else
        {
          expenses = expenses + element.paidAmount!;
        }
    });

    setState(() {
      loading = false;
    });
  }


  Widget _buildForMobile(Size size, int startDate, int endDate) {

    String start = DateFormat("dd MMM yyyy")
        .format(DateTime.fromMillisecondsSinceEpoch(startDate));

    String end = DateFormat("dd MMM yyyy")
        .format(DateTime.fromMillisecondsSinceEpoch(endDate));

    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Container(
        width: size.width,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0.0, 0.0),
                  spreadRadius: 2.0,
                  blurRadius: 2.0)
            ]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
                title: const Text(
                  "Property Revenue Overview",
                  style: TextStyle(
                      fontSize: 15.0, fontWeight: FontWeight.bold),
                ),
                subtitle: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "$start - $end",
                      style: const TextStyle(
                          fontSize: 11.0,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                trailing: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.cloud_download_outlined,
                    color: EKodi().themeColor,
                  ),
                )),
            SizedBox(
              height: 30.0,
              width: size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 30.0,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  width: 2.0, color: Colors.black),
                            ),
                          ),
                          child: const Text(
                            "Overview",
                            style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "Week",
                          style: TextStyle(
                              fontSize: 13.0,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          "Month",
                          style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          "Year",
                          style: TextStyle(
                              fontSize: 13.0,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Container(
              height: 1,
              width: size.width,
              color: Colors.grey.shade300,
            ),
            loading ? Container() : const SpacingColumnChart(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5.0, vertical: 10.0),
                  child: Container(
                    width: size.width * 0.45,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                            color: Colors.grey, width: 0.5)),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Kes $income",
                            style: TextStyle(
                                fontSize: 18.0,
                                color: EKodi().themeColor,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 20.0,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Money in",
                                style: TextStyle(
                                    fontSize: 11.0,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 5.0,
                              ),
                              Icon(
                                Icons.trending_up_rounded,
                                color: EKodi().themeColor,
                              ),
                              // Text(
                              //   "5.8%",
                              //   style: TextStyle(
                              //       fontSize: 11.0,
                              //       color: Colors.teal,
                              //       fontWeight: FontWeight.bold),
                              // ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5.0, vertical: 10.0),
                  child: Container(
                    width: size.width * 0.45,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                            color: Colors.grey, width: 0.5)),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Kes $expenses",
                            style: const TextStyle(
                                fontSize: 18.0,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 20.0,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                "Money out",
                                style: TextStyle(
                                    fontSize: 11.0,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              Icon(
                                Icons.trending_down_rounded,
                                color: Colors.red,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildForDesktop(Size size, int startDate, int endDate) {

    String start = DateFormat("dd MMM yyyy")
        .format(DateTime.fromMillisecondsSinceEpoch(startDate));

    String end = DateFormat("dd MMM yyyy")
        .format(DateTime.fromMillisecondsSinceEpoch(endDate));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
            title: const Text(
              "Property Revenue Overview",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            subtitle: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "$start - $end",
                  style: const TextStyle(
                      fontSize: 13.0,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            trailing: RaisedButton.icon(
              elevation: 0.0,
              hoverColor: Colors.transparent,
              color: EKodi().themeColor.withOpacity(0.1),
              highlightElevation: 0.0,
              icon: Icon(
                Icons.cloud_download_outlined,
                color: EKodi().themeColor,
              ),
              label: Text("Download Report",
                  style: TextStyle(
                      color: EKodi().themeColor, fontWeight: FontWeight.bold)),
              onPressed: () {},
            )),
        SizedBox(
          height: 30.0,
          width: size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      height: 30.0,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 2.0, color: Colors.black),
                        ),
                      ),
                      child: const Text(
                        "Overview",
                        style: TextStyle(
                            fontSize: 13.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      "Week",
                      style: TextStyle(
                          fontSize: 13.0,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      "Month",
                      style: TextStyle(
                          fontSize: 13.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      "Year",
                      style: TextStyle(
                          fontSize: 13.0,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        Divider(
          color: Colors.grey.shade400,
          height: 0.5,
          thickness: 0.5,
        ),
        Row(
          children: [
            Expanded(
              //flex: 3,
              child: loading ? Container() : const SpacingColumnChart(),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: Container(
                    width: size.width * 0.12,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: Colors.grey, width: 0.5)),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            loading ? "loading...":"Kes $income",
                            style: TextStyle(
                                fontSize: 18.0,
                                color: EKodi().themeColor,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 20.0,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Money in",
                                style: TextStyle(
                                    fontSize: 11.0,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 5.0,
                              ),
                              Icon(
                                Icons.trending_up_rounded,
                                color: EKodi().themeColor,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: Container(
                    width: size.width * 0.12,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: Colors.grey, width: 0.5)),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            loading ? "loading...":"Kes $expenses",
                            style: const TextStyle(
                                fontSize: 18.0,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 20.0,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                "Money out",
                                style: TextStyle(
                                    fontSize: 11.0,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              Icon(
                                Icons.trending_down_rounded,
                                color: Colors.red,
                              ),
                              // Text(
                              //   "26.4%",
                              //   style: TextStyle(
                              //       fontSize: 11.0,
                              //       color: Colors.red,
                              //       fontWeight: FontWeight.bold),
                              // ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    int startDate = context.watch<DatePeriodProvider>().startDate;
    int endDate = context.watch<DatePeriodProvider>().endDate;
    Size size = MediaQuery.of(context).size;

    return ScreenTypeLayout.builder(
      mobile: (context) => _buildForMobile(size, startDate, endDate),
      tablet: (context)=> _buildForDesktop(size, startDate, endDate),
      desktop: (context)=> _buildForDesktop(size, startDate, endDate),
    );
  }


}
