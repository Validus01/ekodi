import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../config.dart';
import '../../main.dart';
import '../../model/account.dart';
import '../../providers/tabProvider.dart';

class ServiceDrawer extends StatelessWidget {
  const ServiceDrawer({ Key? key }) : super(key: key);

  displayUserProfile(BuildContext context, Account account) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(35.0),
          child: account.photoUrl! == ""
              ? Image.asset(
                  "assets/profile.png",
                  height: 70.0,
                  width: 70.0,
                )
              : Image.network(
                  account.photoUrl!,
                  height: 36.0,
                  width: 36.0,
                ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Text(
          account.name!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13.0),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          account.email!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13.0),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          account.accountType!,
          style: const TextStyle(fontSize: 11.0),
        ),
      ],
    );
  }

  Drawer _buildForDesktop(
      BuildContext context, Account account, Size size, String currentTab) {
    return Drawer(
      backgroundColor: EKodi.themeColor,
      elevation: 0.0,
      child: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
          ),
          Image.asset(
            "assets/images/drawer.png",
            height: size.height,
            width: size.width,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 0.0,
            right: 0.0,
            left: 0.0,
            bottom: 0.0,
            child: ListView(
              children: [
                Image.asset(
                  "assets/logo_white.png",
                  //height: size.height * 0.2,
                  width: size.width,
                  fit: BoxFit.fitWidth,
                ),
                InkWell(
                  onTap: () {
                    context.read<TabProvider>().changeTab("Messages");
                  },
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    height: 50.0,
                    margin: const EdgeInsets.only(left: 10.0),
                    decoration: BoxDecoration(
                        color: currentTab == "Messages"
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(25.0))),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: ListTile(
                        leading: Icon(
                          Icons.question_answer_outlined,
                          color: currentTab == "Messages"
                              ? EKodi.themeColor
                              : Colors.white,
                        ),
                        title: Text(
                          "Messages",
                          style: TextStyle(
                            color: currentTab == "Messages"
                                ? EKodi.themeColor
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    context.read<TabProvider>().changeTab("Profile");
                  },
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    height: 50.0,
                    margin: const EdgeInsets.only(left: 10.0),
                    decoration: BoxDecoration(
                        color: currentTab == "Profile"
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(25.0))),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: ListTile(
                        leading: Icon(
                          Icons.person,
                          color: currentTab == "Profile"
                              ? EKodi.themeColor
                              : Colors.white,
                        ),
                        title: Text(
                          "Account",
                          style: TextStyle(
                            color: currentTab == "Profile"
                                ? EKodi.themeColor
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const Divider(
                  color: Colors.white30,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListTile(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();

                      Route route = MaterialPageRoute(
                          builder: (context) => const SplashScreen());

                      Navigator.pushReplacement(context, route);
                    },
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                    ),
                    title: const Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    String currentTab = context.watch<TabProvider>().currentTab;
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile;
        return isMobile
            ? _buildForDesktop(context, account, size, currentTab)
            : _buildForDesktop(context, account, size, currentTab);
      },
    );
  }
}
