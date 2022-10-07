import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';


class GoogleMapsWidget extends StatefulWidget {
  const GoogleMapsWidget({Key? key}) : super(key: key);

  @override
  State<GoogleMapsWidget> createState() => _GoogleMapsWidgetState();
}

class _GoogleMapsWidgetState extends State<GoogleMapsWidget> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile || sizeInfo.isTablet;

        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: isMobile ? 5.0 : 10.0
          ),
          child: Container(
            width:  isMobile ? size.width : size.width*0.5,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0.0, 0.0),
                      spreadRadius: 2.0,
                      blurRadius: 2.0
                  )
                ]
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.location_off_outlined, color: Colors.grey,),
                    SizedBox(height: 10.0,),
                    Text("No location information", style: TextStyle(color: Colors.grey,),)
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
