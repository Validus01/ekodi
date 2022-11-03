import 'package:flutter/material.dart';
import 'package:rekodi/model/property.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../config.dart';

class PropertiesCard extends StatefulWidget {
  final void Function()? onPressed;
  final List<Property>? properties;
  final int? vacantUnits;
  final int? occupiedUnits;
  const PropertiesCard(
      {Key? key,
      this.properties,
      this.vacantUnits,
      this.occupiedUnits,
      this.onPressed})
      : super(key: key);

  @override
  State<PropertiesCard> createState() => _PropertiesCardState();
}

class _PropertiesCardState extends State<PropertiesCard> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile || sizeInfo.isTablet;

        return Padding(
          padding: EdgeInsets.symmetric(
              vertical: isMobile ? 5.0 : 10.0,
              horizontal: isMobile ? 10.0 : 0.0),
          child: Container(
            width: size.width,
            //height: 100.0,
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
                ListTile(
                    leading: Icon(
                      Icons.apartment_rounded,
                      size: 30.0,
                      color: EKodi.themeColor.withOpacity(0.5),
                    ),
                    title: Text(
                      widget.properties!.length.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      "Properties",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    trailing: TextButton(
                      onPressed: widget.onPressed,
                      child: const Text(
                        "See all >",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: EKodi.themeColor),
                      ),
                    )),
                //const SizedBox(height: 10.0,),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    width: size.width,
                    decoration: BoxDecoration(
                      color: EKodi.themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                widget.vacantUnits.toString(),
                                style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              const Text(
                                "Vacant",
                                style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const VerticalDivider(
                            width: 1.0,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                widget.occupiedUnits.toString(),
                                style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              const Text(
                                "Occupied",
                                style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          // const VerticalDivider(width: 1.0,),
                          // Column(
                          //   mainAxisSize: MainAxisSize.min,
                          //   crossAxisAlignment: CrossAxisAlignment.center,
                          //   children: const [
                          //     Text("16", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),),
                          //     SizedBox(height: 5.0,),
                          //     Text("Unlisted", style: TextStyle(fontSize: 15.0, color: Colors.grey, fontWeight: FontWeight.bold),),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
