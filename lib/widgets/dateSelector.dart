import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../providers/datePeriod.dart';

class DateSelector extends StatefulWidget {
  const DateSelector({Key? key}) : super(key: key);

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    /// The argument value will return the changed date as [DateTime] when the
    /// widget [SfDateRangeSelectionMode] set as single.
    ///
    /// The argument value will return the changed dates as [List<DateTime>]
    /// when the widget [SfDateRangeSelectionMode] set as multiple.
    ///
    /// The argument value will return the changed range as [PickerDateRange]
    /// when the widget [SfDateRangeSelectionMode] set as range.
    ///
    /// The argument value will return the changed ranges as
    /// [List<PickerDateRange] when the widget [SfDateRangeSelectionMode] set as
    /// multi range.
    setState(() {
      if (args.value is PickerDateRange) {
        // String _range = '${DateFormat('dd/MM/yyyy').format(args.value.startDate)} -'
        // // ignore: lines_longer_than_80_chars
        //     ' ${DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate)}';

        context.read<DatePeriodProvider>().updatePeriod(
            start: args.value.startDate.millisecondsSinceEpoch,
            end: args.value.endDate.millisecondsSinceEpoch ??
                DateTime.fromMillisecondsSinceEpoch(
                    args.value.startDate.millisecondsSinceEpoch)
                    .subtract(const Duration(days: 30)));
      }
      // else if (args.value is DateTime) {
      //   _selectedDate = args.value.toString();
      // } else if (args.value is List<DateTime>) {
      //   _dateCount = args.value.length.toString();
      // } else {
      //   _rangeCount = args.value.length.toString();
      // }
    });
  }

  displayCalendar(int startDate, int endDate) {
    Size size = MediaQuery.of(context).size;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return ResponsiveBuilder(
          builder: (context, sizeInfo) {
            bool isDesktop = sizeInfo.isDesktop;

            return AlertDialog(
              title: Text("Pick range"),
              content: Container(
                height: isDesktop ? size.height * 0.6 : size.height * 0.4,
                width: isDesktop ? size.width * 0.4 : size.width*0.8,
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
                child: SfDateRangePicker(
                  view: DateRangePickerView.month,
                  onSelectionChanged: _onSelectionChanged,
                  enableMultiView: isDesktop ? true : false,
                  selectionMode: DateRangePickerSelectionMode.range,
                  initialSelectedRange: PickerDateRange(
                      DateTime.fromMillisecondsSinceEpoch(startDate),
                      DateTime.fromMillisecondsSinceEpoch(endDate)),
                ),
              ),
              actions: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.done, color: Theme.of(context).primaryColor),
                  label: Text(
                    "Done",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    int startDate = context.watch<DatePeriodProvider>().startDate;
    int endDate = context.watch<DatePeriodProvider>().endDate;

    String start = DateFormat("dd MMM yyyy")
        .format(DateTime.fromMillisecondsSinceEpoch(startDate));

    String end = DateFormat("dd MMM yyyy")
        .format(DateTime.fromMillisecondsSinceEpoch(endDate));

    return InkWell(
      onTap: () => displayCalendar(startDate, endDate),
      child: Container(
        height: 30.0,
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
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.date_range_rounded,
                color: Colors.grey,
                size: 15.0,
              ),
              const SizedBox(
                width: 5.0,
              ),
              Text(
                "$start - $end",
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                width: 5.0,
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
