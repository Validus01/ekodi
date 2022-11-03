import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/model/leaseExpiryModel.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../config.dart';
import '../model/account.dart';

class ExpiringLeases extends StatefulWidget {
  const ExpiringLeases({Key? key}) : super(key: key);

  @override
  State<ExpiringLeases> createState() => _ExpiringLeasesState();
}

class _ExpiringLeasesState extends State<ExpiringLeases> {
  bool loading = false;

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

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile || sizeInfo.isTablet;

        return Padding(
          padding: EdgeInsets.only(
            right: isMobile ? 10 : 15.0,
            left: isMobile ? 10 : 5.0,
            top: isMobile ? 5.0 : 0.0,
            bottom: isMobile ? 5.0 : 0.0,
          ),
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
                border: Border.all(width: 0.5, color: Colors.grey.shade300)),
            child: loading
                ? Text('Loading...')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ListTile(
                        title: Text(
                          'Expiring Leases',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("users")
                            .doc(account.userID)
                            .collection("leaseExpiry")
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text("Loading...");
                          } else {
                            List<LeaseExpiry> expiringLeases = [];

                            for (var element in snapshot.data!.docs) {
                              expiringLeases
                                  .add(LeaseExpiry.fromDocument(element));
                            }

                            if (expiringLeases.isEmpty) {
                              return _buildNoDataCircle(size, isMobile);
                            } else {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(expiringLeases.length,
                                    (index) {
                                  LeaseExpiry leaseExpiry =
                                      expiringLeases[index];

                                  return LeaseProperty(
                                    leaseExpiry: leaseExpiry,
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
        );
      },
    );
  }
}

class LeaseProperty extends StatefulWidget {
  final LeaseExpiry? leaseExpiry;
  const LeaseProperty({Key? key, this.leaseExpiry}) : super(key: key);

  @override
  State<LeaseProperty> createState() => _LeasePropertyState();
}

class _LeasePropertyState extends State<LeaseProperty> {
  bool showUnits = false;

  /// Returns the progress bar.
  Widget _buildProgressBar(BuildContext context, int startDate, int dueDate) {
    final Brightness _brightness = Theme.of(context).brightness;
    double remainingDays =
        (dueDate - DateTime.now().millisecondsSinceEpoch).toDouble();

    return Stack(children: <Widget>[
      Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: SizedBox(
                      height: 30,
                      child: SfLinearGauge(
                        orientation: LinearGaugeOrientation.horizontal,
                        minimum: 0.0,
                        maximum: (dueDate - startDate).toDouble(),
                        showTicks: false,
                        showLabels: false,
                        animateAxis: true,
                        axisTrackStyle: LinearAxisTrackStyle(
                          thickness: 30,
                          edgeStyle: LinearEdgeStyle.bothCurve,
                          borderWidth: 1,
                          borderColor: _brightness == Brightness.dark
                              ? const Color(0xff898989)
                              : Colors.grey[350],
                          color: _brightness == Brightness.dark
                              ? Colors.transparent
                              : Colors.grey[350],
                        ),
                        barPointers: <LinearBarPointer>[
                          LinearBarPointer(
                              value: remainingDays,
                              thickness: 30,
                              edgeStyle: LinearEdgeStyle.bothCurve,
                              color: EKodi.themeColor),
                        ],
                      ))))),
      Align(
          alignment: Alignment.centerLeft,
          child: Padding(
              padding: const EdgeInsets.all(30),
              child: Text(
                (remainingDays / 8.64e+7).round().toString() + ' days left',
                style: const TextStyle(fontSize: 14, color: Color(0xffFFFFFF)),
              ))),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isExpired = DateTime.now().millisecondsSinceEpoch >=
        widget.leaseExpiry!.expiryDate!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(widget.leaseExpiry!.propertyInfo!["name"]),
          subtitle: Text(widget.leaseExpiry!.propertyInfo!["address"] +
              ", " +
              widget.leaseExpiry!.propertyInfo!["city"] +
              " " +
              widget.leaseExpiry!.propertyInfo!["country"]),
          trailing: showUnits
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      showUnits = false;
                    });
                  },
                  icon: const Icon(Icons.arrow_drop_up),
                )
              : IconButton(
                  onPressed: () {
                    setState(() {
                      showUnits = true;
                    });
                  },
                  icon: const Icon(Icons.arrow_drop_down),
                ),
        ),
        showUnits
            ? AnimatedContainer(
                duration: const Duration(seconds: 1),
                width: size.width,
                child: ListTile(
                  title: Text(widget.leaseExpiry!.unitInfo!["name"] +
                      ": " +
                      widget.leaseExpiry!.userInfo!["name"]),
                  subtitle: isExpired
                      ? const Text(
                          "EXPIRED",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red),
                        )
                      : _buildProgressBar(
                          context,
                          widget.leaseExpiry!.timestamp!,
                          widget.leaseExpiry!.expiryDate!),
                  trailing:
                      Text("Kes ${widget.leaseExpiry!.unitInfo!["rent"]}"),
                ),
              )
            : Container()
      ],
    );
  }
}
