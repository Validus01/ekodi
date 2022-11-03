import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rekodi/model/property.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../config.dart';

class PropertiesDataCard extends StatefulWidget {
  final List<Property>? properties;
  const PropertiesDataCard({Key? key, this.properties}) : super(key: key);

  @override
  State<PropertiesDataCard> createState() => _PropertiesDataCardState();
}

class _PropertiesDataCardState extends State<PropertiesDataCard> {
  List<PropertyGroup> propertyGroups = [];

  @override
  void initState() {
    super.initState();

    propertyGroups = getPropertyGroups(widget.properties!);
  }

  /// The method returns line series to chart.
  List<LineSeries<PropertyGroup, dynamic>> _getDefaultLineSeries(
      List<PropertyGroup> propertyGroups) {
    return <LineSeries<PropertyGroup, dynamic>>[
      LineSeries<PropertyGroup, dynamic>(
          animationDuration: 2500,
          dataSource: propertyGroups,
          xValueMapper: (PropertyGroup propertyGroup, _) => propertyGroup.date,
          yValueMapper: (PropertyGroup propertyGroup, _) =>
              propertyGroup.properties!.length,
          width: 2,
          color: EKodi.themeColor,
          name: "New Properties",
          markerSettings: const MarkerSettings(isVisible: true))
    ];
  }

  List<PropertyGroup> getPropertyGroups(List<Property> properties) {
    properties.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));

    var newMap = properties.groupListsBy((element) => DateFormat("dd MMM")
        .format(DateTime.fromMillisecondsSinceEpoch(element.timestamp!)));

    List<PropertyGroup> propertyGroups = newMap.entries
        .map((e) => PropertyGroup(date: e.key, properties: e.value))
        .toList();

    propertyGroups.sort((a, b) => a.date!.compareTo(b.date!));

    return propertyGroups.toList();
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
              "Property Analytics",
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
                        "Properties",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        widget.properties!.length.toString(),
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    title: ChartTitle(text: 'New Properties'),
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
                    series: _getDefaultLineSeries(propertyGroups),
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

class PropertyGroup {
  final String? date;
  final List<Property>? properties;

  PropertyGroup({this.properties, this.date});
}
