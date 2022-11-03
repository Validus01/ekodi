import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/providers/tabProvider.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../config.dart';
import '../model/account.dart';
import '../providers/datePeriod.dart';

class InvoicesCard extends StatelessWidget {
  const InvoicesCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    int startDate = context.watch<DatePeriodProvider>().startDate;
    int endDate = context.watch<DatePeriodProvider>().endDate;

    String period = ((endDate - startDate) / 8.64e+7).round().toString();

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile;

        return Padding(
          padding: EdgeInsets.symmetric(
              vertical: isMobile ? 5.0 : 10.0,
              horizontal: isMobile ? 10.0 : 0.0),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "Last $period days",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(
                      Icons.more_horiz,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Kes 0",
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.teal,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            "paid invoices",
                            style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Kes 0",
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            "open invoices",
                            style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RaisedButton.icon(
                        elevation: 0.0,
                        hoverColor: Colors.transparent,
                        color: EKodi.themeColor.withOpacity(0.1),
                        icon: const Icon(
                          Icons.paid_outlined,
                          color: EKodi.themeColor,
                        ),
                        label: const Text("Receive Payments",
                            style: TextStyle(
                                color: EKodi.themeColor,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          context.read<TabProvider>().changeTab("Accounting");
                        },
                      ),
                      // Text("View All",
                      //     style: TextStyle(
                      //         color: EKodi().themeColor,
                      //         fontWeight:
                      //         FontWeight
                      //             .bold))
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
