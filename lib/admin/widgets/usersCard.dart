import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rekodi/config.dart';
import 'package:rekodi/model/account.dart';
import 'package:rekodi/widgets/ProgressWidget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:collection/collection.dart';

class UsersCard extends StatefulWidget {
  final List<Account>? accounts;
  const UsersCard({Key? key, this.accounts}) : super(key: key);

  @override
  State<UsersCard> createState() => _UsersCardState();
}

class _UsersCardState extends State<UsersCard> {
  int verified = 0;
  int pending = 0;
  int unverified = 0;
  List<AccountGroup> accountGroups = [];

  @override
  void initState() {
    super.initState();

    accountGroups = getAccountGroups(widget.accounts!);

    verified = widget.accounts!
        .where(
          (element) => element.verification!["status"] == "verified",
        )
        .toList()
        .length;

    pending = widget.accounts!
        .where(
          (element) => element.verification!["status"] == "pending",
        )
        .toList()
        .length;

    unverified = widget.accounts!
        .where(
          (element) => element.verification!["status"] == "unverified",
        )
        .toList()
        .length;
  }

  /// The method returns line series to chart.
  List<LineSeries<AccountGroup, dynamic>> _getDefaultLineSeries(
      List<AccountGroup> accountGroups) {
    return <LineSeries<AccountGroup, dynamic>>[
      LineSeries<AccountGroup, dynamic>(
          animationDuration: 2500,
          dataSource: accountGroups,
          xValueMapper: (AccountGroup accountGroup, _) => accountGroup.date,
          yValueMapper: (AccountGroup accountGroup, _) =>
              accountGroup.accounts!.length,
          width: 2,
          color: EKodi.themeColor,
          name: "New Users",
          markerSettings: const MarkerSettings(isVisible: true))
    ];
  }

  List<AccountGroup> getAccountGroups(List<Account> accounts) {
    accounts.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));

    var newMap = accounts.groupListsBy((element) => DateFormat("dd MMM")
        .format(DateTime.fromMillisecondsSinceEpoch(element.timestamp!)));

    List<AccountGroup> accountGroups = newMap.entries
        .map((e) => AccountGroup(date: e.key, accounts: e.value))
        .toList();

    accountGroups.sort((a, b) => a.date!.compareTo(b.date!));
    return accountGroups.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "User Analytics",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(
              height: 20.0,
              thickness: 1.0,
              color: Colors.grey,
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Users",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        widget.accounts!.length.toString(),
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      ListTile(
                        leading: Container(
                          color: Colors.teal,
                          height: 10.0,
                          width: 10.0,
                        ),
                        title: Text("$verified verified"),
                      ),
                      ListTile(
                        leading: Container(
                          color: Colors.orange,
                          height: 10.0,
                          width: 10.0,
                        ),
                        title: Text("$pending pending"),
                      ),
                      ListTile(
                        leading: Container(
                          color: Colors.red,
                          height: 10.0,
                          width: 10.0,
                        ),
                        title: Text("$unverified unverified"),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    title: ChartTitle(text: 'New Users'),
                    legend: Legend(
                        isVisible: true,
                        overflowMode: LegendItemOverflowMode.wrap),
                    primaryXAxis: CategoryAxis(
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        //interval: 2,
                        majorGridLines: const MajorGridLines(width: 0)),
                    primaryYAxis: NumericAxis(
                        maximum: 100,
                        minimum: 0,
                        interval: 5,
                        labelFormat: '{value}',
                        axisLine: const AxisLine(width: 0),
                        majorTickLines:
                            const MajorTickLines(color: Colors.transparent)),
                    series: _getDefaultLineSeries(accountGroups),
                    tooltipBehavior: TooltipBehavior(enable: true),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class AccountGroup {
  final String? date;
  final List<Account>? accounts;

  AccountGroup({this.accounts, this.date});
}
