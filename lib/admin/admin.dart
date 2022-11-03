import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/admin/tabs/propertiesTab.dart';
import 'package:rekodi/admin/tabs/usersTab.dart';
import 'package:rekodi/admin/widgets/adminDrawer.dart';
import 'package:rekodi/admin/widgets/usersCard.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../chat/chatBuilder.dart';
import '../config.dart';
import '../model/account.dart';
import '../pages/profilePage.dart';
import '../providers/tabProvider.dart';
import '../widgets/customAppBar.dart';

class Admin extends StatefulWidget {
  const Admin({Key? key}) : super(key: key);

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget displayTabs(String currentTab) {
    switch (currentTab) {
      case "Dashboard":
        return const UsersTab();
      case "Properties":
        return const PropertiesTab();
      case "Tenant Screening":
        return Container();
      case "Messages":
        return Padding(
          padding: const EdgeInsets.only(right: 15.0, top: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              ChatBuilder(),
            ],
          ),
        );
      case "Profile":
        return const ProfilePage();
      default:
        return const UsersTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Account account = context.watch<EKodi>().account;
    String currentTab = context.watch<TabProvider>().currentTab;

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        bool isMobile = sizingInformation.isMobile;

        if (isMobile) {
          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            drawer: const AdminDrawer(),
            appBar: PreferredSize(
              preferredSize: Size(size.width, 60.0),
              child: const DashboardAppBar(
                automaticallyImplyLeading: true,
                addPropertyButton: SizedBox(),
              ),
            ),
            body: SingleChildScrollView(child: displayTabs(currentTab)),
          );
        } else {
          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            body: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: AdminDrawer(),
                ),
                Expanded(
                    flex: 8,
                    child: Column(children: [
                      PreferredSize(
                        preferredSize: Size(size.width, 60.0),
                        child: const DashboardAppBar(
                          automaticallyImplyLeading: true,
                          addPropertyButton: SizedBox(),
                        ),
                      ),
                      Expanded(
                        child: RawScrollbar(
                          controller: _controller,
                          isAlwaysShown: true,
                          radius: const Radius.circular(5.0),
                          thumbColor: Colors.grey,
                          thickness: 10,
                          child: SingleChildScrollView(
                            controller: _controller,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.03),
                              child: displayTabs(currentTab),
                            ),
                          ),
                        ),
                      )
                    ]))
              ],
            ),
          );
        }
      },
    );
  }
}
