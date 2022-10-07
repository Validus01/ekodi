import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../commonFunctions/AddToOutstanding.dart';
import '../config.dart';
import '../model/account.dart';
import '../model/unit.dart';
import '../providers/datePeriod.dart';

class SliderWithCircle extends StatelessWidget {
  const SliderWithCircle({Key? key}) : super(key: key);

  /// Returns gradient progress style circular progress bar.
  Widget _buildSliderWithCircle(Size size, int startDate, int dueDate, bool isMobile) {
    int period = dueDate - startDate;
    int remainingPeriod = dueDate - DateTime.now().millisecondsSinceEpoch;
    double maxDays = period / 8.64e+7;

    double remainingDays = remainingPeriod / 8.64e+7;

    return SizedBox(
        height: isMobile ? 200.0 : size.width * 0.1,
        width: isMobile ? 200.0 : size.width * 0.1,
        child: SfRadialGauge(axes: <RadialAxis>[
          RadialAxis(
              showLabels: false,
              showTicks: false,
              startAngle: 270,
              maximum: maxDays, //TODO: Implement for calculating month days
              endAngle: 270,
              radiusFactor: 0.8,
              axisLineStyle: const AxisLineStyle(
                thickness: 0.1,
                thicknessUnit: GaugeSizeUnit.factor,
              ),
              ranges: <GaugeRange>[
                GaugeRange(
                    endValue: remainingDays,
                    startValue: 0.0,
                    sizeUnit: GaugeSizeUnit.factor,
                    color: const Color.fromRGBO(197, 91, 226, 1),
                    gradient: const SweepGradient(
                      colors: <Color>[
                        Color.fromRGBO(115, 67, 189, 1),
                        Color.fromRGBO(197, 91, 226, 1),
                      ],
                    ),
                    endWidth: 0.1,
                    startWidth: 0.1)
              ],
              pointers: <GaugePointer>[
                const MarkerPointer(
                  value: 0.0,
                  overlayRadius: 0,
                  elevation: 5,
                  markerType: MarkerType.circle,
                  markerHeight: 22,
                  markerWidth: 22,
                  enableDragging: false,
                  // onValueChanged: handleFirstPointerValueChanged,
                  // onValueChanging: handleFirstPointerValueChanging,
                  color: Color.fromRGBO(125, 71, 194, 1),
                ),
                MarkerPointer(
                  value: remainingDays,
                  elevation: 5,
                  overlayRadius: 0,
                  markerType: MarkerType.circle,
                  markerHeight: 22,
                  markerWidth: 22,
                  enableDragging: false,
                  // onValueChanged: handleSecondPointerValueChanged,
                  // onValueChanging: handleSecondPointerValueChanging,
                  color: const Color.fromRGBO(125, 71, 194, 1),
                )
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                    positionFactor: 0.1,
                    widget: Text('${remainingDays.round()} Days \n Left'))
              ]),
        ]));
  }

  Widget _buildNoDataCircle(Size size, bool isMobile) {
    return SizedBox(
        height: isMobile ? 200.0 : size.width * 0.1,
        width: isMobile ? 200.0 : size.width * 0.1,
        child: SfRadialGauge(axes: <RadialAxis>[
          RadialAxis(
              showLabels: false,
              showTicks: false,
              startAngle: 270,
              maximum: 100,
              endAngle: 270,
              radiusFactor: 0.8,
              axisLineStyle: const AxisLineStyle(
                thickness: 0.1,
                thicknessUnit: GaugeSizeUnit.factor,
              ),
              ranges: <GaugeRange>[
                GaugeRange(
                    endValue: 75,
                    startValue: 0.0,
                    sizeUnit: GaugeSizeUnit.factor,
                    color: Colors.grey.shade200,
                    gradient: SweepGradient(
                      colors: <Color>[
                        Colors.grey.shade400,
                        Colors.grey.shade200,
                      ],
                    ),
                    endWidth: 0.1,
                    startWidth: 0.1)
              ],
              pointers: const <GaugePointer>[
                MarkerPointer(
                  value: 0.0,
                  overlayRadius: 0,
                  elevation: 5,
                  markerType: MarkerType.circle,
                  markerHeight: 22,
                  markerWidth: 22,
                  enableDragging: false,
                  // onValueChanged: handleFirstPointerValueChanged,
                  // onValueChanging: handleFirstPointerValueChanging,
                  color: Colors.grey,
                ),
                MarkerPointer(
                  value: 75,
                  elevation: 5,
                  overlayRadius: 0,
                  markerType: MarkerType.circle,
                  markerHeight: 22,
                  markerWidth: 22,
                  enableDragging: false,
                  // onValueChanged: handleSecondPointerValueChanged,
                  // onValueChanging: handleSecondPointerValueChanging,
                  color: Colors.grey,
                )
              ],
              annotations: const <GaugeAnnotation>[
                GaugeAnnotation(positionFactor: 0.1, widget: Text('No Data'))
              ]),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    Size size = MediaQuery.of(context).size;
    int startDate = context.watch<DatePeriodProvider>().startDate;
    int endDate = context.watch<DatePeriodProvider>().endDate;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile || sizeInfo.isTablet;

        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            width: size.width,
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
                border: Border.all(
                    width: 0.5, color: Colors.grey.shade300)),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(account.userID)
                  .collection("units")
                  .limit(1)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Text("Loading...");
                } else {
                  List<Unit> units = [];

                  snap.data!.docs.forEach((element) {
                    Unit unit = Unit.fromDocument(element);

                    units.add(unit);
                  });

                  if (units.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: _buildNoDataCircle(size, isMobile),
                      ),
                    );
                  } else {

                    if(DateTime.now().millisecondsSinceEpoch >= units[0].dueDate!) {
                      AddToOutstanding().addToOutstanding(units[0]);
                    }

                    return Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSliderWithCircle(
                            size,
                            units[0].startDate!,
                            units[0].dueDate!, isMobile),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Remind me "),
                            Text(
                              units[0].reminder!.toString() +
                                  " days",
                              style: const TextStyle(
                                  fontWeight:
                                  FontWeight.bold),
                            ),
                            const Text("before due date"),
                          ],
                        )
                      ],
                    );
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }
}
