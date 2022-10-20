import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/APIs/locationAPI.dart';
import 'package:rekodi/config.dart';
import 'package:rekodi/model/locationInfo.dart';
import 'package:rekodi/pages/dashboards/landlordDash.dart';
import 'package:rekodi/pages/dashboards/serviceDash.dart';
import 'package:rekodi/pages/dashboards/tenantDash.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../model/account.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    checkDeviceTokens();
    getUserLocation();
    super.initState();
  }

  getUserLocation() async {
    try{
      Position position = await LocationAPI().determinePosition();

      int timestamp = DateTime.now().millisecondsSinceEpoch;

      LocationInfo locationInfo = LocationInfo(
        locationID: timestamp.toString(),
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: timestamp,
      );

      String userID = Provider.of<EKodi>(context, listen: false).account.userID!;

      await FirebaseFirestore.instance.collection("users").doc(userID).collection("location").doc(locationInfo.locationID).set(locationInfo.toMap()).then((value) => print("Location: ${position.latitude}, ${position.longitude}"));
    } catch(e){
      Fluttertoast.showToast(msg: "ERROR: Could not get location");
    }
  }

  checkDeviceTokens() async {
    Account account = Provider.of<EKodi>(context, listen: false).account;

    String? fcmToken = await getMessagingTokens();

    print(fcmToken);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(account.userID)
        .get()
        .then((value) async {
      Account account = Account.fromDocument(value);

      List<dynamic> tokens = account.deviceTokens!;

      if (!account.deviceTokens!.contains(fcmToken)) {
        tokens.add(fcmToken);

        await value.reference.update({"deviceTokens": tokens});
      }
    });
  }

  Future<String?> getMessagingTokens() async {
    if (kIsWeb) {
      // NotificationSettings settings = await messaging.requestPermission(
      //   alert: true,
      //   announcement: false,
      //   badge: true,
      //   carPlay: false,
      //   criticalAlert: false,
      //   provisional: false,
      //   sound: true,
      // );

      final fcmToken =
          await FirebaseMessaging.instance.getToken(vapidKey: EKodi.vapidKey);

      return fcmToken;
    } else {
      final fcmToken = await FirebaseMessaging.instance.getToken();

      return fcmToken;
    }
  }

  @override
  Widget build(BuildContext context) {
    String? accountType = context.watch<EKodi>().account.accountType!;

    switch (accountType) {
      case "Landlord":
        return ScreenTypeLayout.builder(
          mobile: (BuildContext context) => const LandlordDashMobile(),
          tablet: (BuildContext context) => const LandlordDashMobile(),
          desktop: (BuildContext context) => const LandlordDash(),
          watch: (BuildContext context) => Container(color: Colors.purple),
        );
      case "Agent":
        return ScreenTypeLayout.builder(
          mobile: (BuildContext context) => const LandlordDashMobile(),
          tablet: (BuildContext context) => const LandlordDashMobile(),
          desktop: (BuildContext context) => const LandlordDash(),
          watch: (BuildContext context) => Container(color: Colors.purple),
        );
      case "Tenant":
        return ScreenTypeLayout.builder(
          mobile: (BuildContext context) => const TenantDashMobile(),
          tablet: (BuildContext context) => const TenantDashMobile(),
          desktop: (BuildContext context) => const TenantDash(),
          watch: (BuildContext context) => Container(color: Colors.purple),
        );
      case "Service Provider":
        return ScreenTypeLayout.builder(
          mobile: (BuildContext context) => const ServiceDash(),
          tablet: (BuildContext context) => const ServiceDash(),
          desktop: (BuildContext context) => const ServiceDash(),
          watch: (BuildContext context) => Container(color: Colors.purple),
        );
      default:
        return const TenantDash();
    }
  }
}
