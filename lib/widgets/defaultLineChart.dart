import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/providers/transactionProvider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:rekodi/model/transaction.dart' as account_transaction;

import '../config.dart';
import '../model/account.dart';
import 'loadingAnimation.dart';

class DefaultLineChart extends StatefulWidget {
  const DefaultLineChart({Key? key}) : super(key: key);

  @override
  State<DefaultLineChart> createState() => _DefaultLineChartState();
}

class _DefaultLineChartState extends State<DefaultLineChart> {

  bool loading = false;

  @override
  void initState() {
    super.initState();
    getTransactions();
  }

  getTransactions() async {
    setState(() {
      loading = true;
    });

    Account account = Provider.of<EKodi>(context, listen: false).account;

    await TransactionProvider().updateTransactionsDB(account);

    setState(() {
      loading = false;
    });
  }

  /// The method returns line series to chart.
  List<LineSeries<account_transaction.Transaction, dynamic>> _getDefaultLineSeries(List<TransactionGroup> transactions) {
    return List.generate(transactions.length, (index) {
      TransactionGroup transactionGroup = transactions[index];

      return LineSeries<account_transaction.Transaction, dynamic>(
          animationDuration: 2500,
          dataSource: transactionGroup.transactions!,
          xValueMapper: (account_transaction.Transaction transaction, _) => DateFormat("MMM").format(DateTime.fromMillisecondsSinceEpoch(transaction.timestamp!)),
          yValueMapper: (account_transaction.Transaction transaction, _) => int.parse(DateFormat("dd").format(DateTime.fromMillisecondsSinceEpoch(transaction.timestamp!))),
          width: 2,
          name: transactionGroup.paymentCategory,
          markerSettings: const MarkerSettings(isVisible: true));
    });
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;

    return loading ? const Text("Loading...") : FutureBuilder<List<TransactionGroup>>(
      future: TransactionProvider().getGroupedTenantTransactions(account),
      builder: (context, snapshot) {
        if(!snapshot.hasData)
        {
          return const LoadingAnimation();
        }
        else
        {
          List<TransactionGroup> transactions = snapshot.data!;

          if(transactions.isEmpty)
          {
            return SfCartesianChart(
              plotAreaBorderWidth: 0,
              title: ChartTitle(text: 'Billing Dates'),
              legend:
              Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
              primaryXAxis: CategoryAxis(
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  //interval: 2,
                  majorGridLines: const MajorGridLines(width: 0)),
              primaryYAxis: NumericAxis(
                  maximum: 31,
                  minimum: 0,
                  interval: 5,
                  labelFormat: '{value}th',
                  axisLine: const AxisLine(width: 0),
                  majorTickLines: const MajorTickLines(color: Colors.transparent)),
              series: const <LineSeries<account_transaction.Transaction, dynamic>>[],
              tooltipBehavior: TooltipBehavior(enable: true),
            );
          }
          else {
            return SfCartesianChart(
              plotAreaBorderWidth: 0,
              title: ChartTitle(text: 'Billing Dates'),
              legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
              primaryXAxis: CategoryAxis(
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  //interval: 2,
                  majorGridLines: const MajorGridLines(width: 0)),
              primaryYAxis: NumericAxis(
                  maximum: 31,
                  minimum: 0,
                  interval: 5,
                  labelFormat: '{value}th',
                  axisLine: const AxisLine(width: 0),
                  majorTickLines: const MajorTickLines(color: Colors.transparent)),
              series: _getDefaultLineSeries(transactions),
              tooltipBehavior: TooltipBehavior(enable: true),
            );
          }
        }
      },
    );
  }
}
