import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../config.dart';
import '../model/account.dart';
import '../providers/transactionProvider.dart';


class SpacingColumnChart extends StatefulWidget {
  const SpacingColumnChart({Key? key}) : super(key: key);

  @override
  State<SpacingColumnChart> createState() => _SpacingColumnChartState();
}

class _SpacingColumnChartState extends State<SpacingColumnChart> {
  _SpacingColumnChartState();

  TooltipBehavior? _tooltipBehavior;
  final double _columnWidth = 0.8;
  final double _columnSpacing = 0.2;

  @override
  void initState() {
    super.initState();
    getData();
    _tooltipBehavior = TooltipBehavior(enable: true);
  }

  getData() async {
    Account account = Provider.of<EKodi>(context, listen: false).account;

    TransactionProvider().getGroupedLandlordTransactions(account);


  }

  //Get the cartesian chart widget
  SfCartesianChart _buildSpacingColumnChart(List<ChatData> transactions) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      // title: ChartTitle(
      //     text: isCardView ? '' : 'Winter olympic medals count - 2022'),
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
          maximum: 50,
          minimum: 0,
          interval: 5,
          labelFormat: '{value}k',
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0)),
      series: _getDefaultColumn(transactions),
      legend: Legend(isVisible: true),
      tooltipBehavior: _tooltipBehavior,
    );
  }

  //Get the column series
  List<ColumnSeries<ChatData, dynamic>> _getDefaultColumn(List<ChatData> transactions) {
    return <ColumnSeries<ChatData, String>>[
      ColumnSeries<ChatData, String>(

        /// To apply the column width here.
          width: _columnWidth,

          /// To apply the spacing betweeen to two columns here.
          spacing: _columnSpacing,
          dataSource: transactions,
          color: EKodi().themeColor,
          xValueMapper: (ChatData data, _) => data.month,
          yValueMapper: (ChatData data, _) => data.incomeAmount!/1000,
          name: 'Income'),
      ColumnSeries<ChatData, String>(
          dataSource: transactions,
          width: _columnWidth,
          spacing: _columnSpacing,
          color: Colors.orange,
          xValueMapper: (ChatData data, _) => data.month,
          yValueMapper: (ChatData data, _) => data.expenseAmount!/1000,
          name: 'Expense'),
    ];
  }


  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;

    return FutureBuilder<List<ChatData>>(
      future: TransactionProvider().getGroupedLandlordTransactions(account),
      builder: (context, snapshot) {
        if(!snapshot.hasData)
        {
          return const Text("Loading...");
        }
        else
        {
          List<ChatData> transactions = snapshot.data!;



          return _buildSpacingColumnChart(transactions);
        }
      },
    );
  }
}
