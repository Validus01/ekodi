import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/model/serviceProvider.dart';
import 'package:rekodi/serviceProvider/widgets/gettingStarted.dart';
import 'package:rekodi/serviceProvider/widgets/serviceDrawer.dart';
import 'package:rekodi/widgets/ProgressWidget.dart';

import '../config.dart';
import '../model/account.dart';
import '../widgets/customAppBar.dart';

class ServiceProviderDashboard extends StatefulWidget {
  const ServiceProviderDashboard({Key? key}) : super(key: key);

  @override
  State<ServiceProviderDashboard> createState() =>
      _ServiceProviderDashboardState();
}

class _ServiceProviderDashboardState extends State<ServiceProviderDashboard> {

  Widget displayTabs() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("serviceProviders").doc(account.userID).get(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return circularProgress();
          }else{

            return Row(children: [
              const Expanded(
                flex: 2,
                child: ServiceDrawer(),
              ),
              Expanded(
                flex: 8,
                child: Column(children: [
                  PreferredSize(
                    preferredSize: Size(size.width, 60.0),
                    child: DashboardAppBar(
                      automaticallyImplyLeading: false,
                      addPropertyButton: Container(),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: snapshot.data!.exists ? displayTabs() : const GettingStarted(),
                    ),
                  )
                ]),
              )
            ]);
                  
          }
        },
      )
    );
  }
}
