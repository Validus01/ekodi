import 'package:flutter/material.dart';

import '../widgets/customAppBar.dart';

class ServiceProviderDashboard extends StatefulWidget {
  const ServiceProviderDashboard({Key? key}) : super(key: key);

  @override
  State<ServiceProviderDashboard> createState() =>
      _ServiceProviderDashboardState();
}

class _ServiceProviderDashboardState extends State<ServiceProviderDashboard> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Row(children: [
        Expanded(
          flex: 2,
          child: Container(),
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
                child: Container(),
              ),
            )
          ]),
        )
      ]),
    );
  }
}
