import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../config.dart';
import '../main.dart';
import '../model/account.dart';
import '../providers/tabProvider.dart';

class CustomDashDrawer extends StatelessWidget {
  const CustomDashDrawer({Key? key}) : super(key: key);

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
          style: const TextStyle( fontSize: 11.0),
        ),
      ],
    );
  }

  // Drawer _buildForMobile(BuildContext context, Account account, Size size, String currentTab) {
  //   return Drawer(
  //     elevation: 0.0,
  //     child: ListView(
  //       children: [
  //         DrawerHeader(
  //           padding: EdgeInsets.zero,
  //           child: Center(
  //             child: displayUserProfile(context, account),
  //           ),
  //         ),
  //         ListTile(
  //           onTap: () {
  //             context.read<TabProvider>().changeTab("Dashboard");
  //           },
  //           leading: Icon(
  //             Icons.dashboard,
  //             color:
  //             currentTab == "Dashboard" ? EKodi().themeColor : Colors.grey,
  //           ),
  //           title: Text(
  //             "Dashboard",
  //             style: TextStyle(
  //               color:
  //               currentTab == "Dashboard" ?  EKodi().themeColor : Colors.grey,
  //             ),
  //           ),
  //         ),
  //         ListTile(
  //           onTap: () {
  //             context.read<TabProvider>().changeTab("Accounting");
  //           },
  //           leading: Icon(
  //             Icons.paid_outlined,
  //             color:
  //             currentTab == "Accounting" ?  EKodi().themeColor : Colors.grey,
  //           ),
  //           title: Text(
  //             "Accounting",
  //             style: TextStyle(
  //               color: currentTab == "Accounting"
  //                   ?  EKodi().themeColor : Colors.grey,
  //             ),
  //           ),
  //         ),
  //         ListTile(
  //           onTap: () {
  //             context.read<TabProvider>().changeTab("Reports");
  //           },
  //           leading: Icon(
  //             Icons.receipt_long_outlined,
  //             color: currentTab == "Reports" ?  EKodi().themeColor : Colors.grey,
  //           ),
  //           title: Text(
  //             "Reports",
  //             style: TextStyle(
  //               color:
  //               currentTab == "Reports" ?  EKodi().themeColor : Colors.grey,
  //             ),
  //           ),
  //         ),
  //         ListTile(
  //           onTap: () {
  //             context.read<TabProvider>().changeTab("Messages");
  //           },
  //           leading: Icon(
  //             Icons.question_answer_outlined,
  //             color: currentTab == "Messages" ?  EKodi().themeColor : Colors.grey,
  //           ),
  //           title: Text(
  //             "Messages",
  //             style: TextStyle(
  //               color:
  //               currentTab == "Messages" ?  EKodi().themeColor : Colors.grey,
  //             ),
  //           ),
  //         ),
  //         ListTile(
  //           onTap: () {
  //             context.read<TabProvider>().changeTab("Tasks");
  //           },
  //           leading: Icon(
  //             Icons.check_box_outlined,
  //             color: currentTab == "Tasks" ?  EKodi().themeColor : Colors.grey,
  //           ),
  //           title: Text(
  //             "Tasks",
  //             style: TextStyle(
  //               color: currentTab == "Tasks" ?  EKodi().themeColor : Colors.grey,
  //             ),
  //           ),
  //         ),
  //         ListTile(
  //           onTap: () {
  //             context.read<TabProvider>().changeTab("Profile");
  //           },
  //           leading: Icon(
  //             Icons.person,
  //             color:
  //             currentTab == "Account" ?  EKodi().themeColor : Colors.grey,
  //           ),
  //           title: Text(
  //             "Account",
  //             style: TextStyle(
  //               color:
  //               currentTab == "Account" ?  EKodi().themeColor : Colors.grey,
  //             ),
  //           ),
  //         ),
  //         ListTile(
  //           onTap: () async {
  //             await FirebaseAuth.instance.signOut();

  //             Route route = MaterialPageRoute(
  //                 builder: (context) => const SplashScreen());

  //             Navigator.pushReplacement(context, route);
  //           },
  //           leading: const Icon(
  //             Icons.logout_rounded,
  //             color: Colors.grey,
  //           ),
  //           title: const Text(
  //             "Logout",
  //             style: TextStyle(
  //               color:
  //               Colors.grey,
  //             ),
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

  Drawer _buildForDesktop(BuildContext context, Account account, Size size, String currentTab) {
    bool isTenant = account.accountType == "Tenant";

    return Drawer(
      backgroundColor: EKodi().themeColor,
      elevation: 0.0,
      child: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
          ),
          Image.asset("assets/images/drawer.png", height: size.height, width: size.width, fit: BoxFit.cover,),
          Positioned(
            top: 0.0,
            right: 0.0,
            left: 0.0,
            bottom: 0.0,
            child: ListView(
              children: [
                SizedBox(
                  height: size.height*0.2,
                  width: size.width,
                  child: Center(child: Text("e-KODI", style: GoogleFonts.titanOne(color: Colors.white, fontSize: 20.0),)),
                ),
                InkWell(
                  onTap: () {
                    context.read<TabProvider>().changeTab("Dashboard");
                  },
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    height: 50.0,
                    margin:const EdgeInsets.only(left: 10.0),
                    decoration: BoxDecoration(
                        color: currentTab == "Dashboard" ? Colors.white : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(25.0))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: ListTile(
                        //contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.dashboard,
                          color:
                          currentTab == "Dashboard" ? EKodi().themeColor : Colors.white,
                        ),
                        title: Text(
                          "Dashboard",
                          style: TextStyle(
                            color:
                            currentTab == "Dashboard" ?  EKodi().themeColor : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    context.read<TabProvider>().changeTab("Accounting");
                  },
                  child: Container(
                    height: 50.0,
                    margin:const EdgeInsets.only(left: 10.0),
                    decoration: BoxDecoration(
                        color: currentTab == "Accounting" ? Colors.white : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(25.0))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: ListTile(
                        leading: Icon(
                          Icons.paid_outlined,
                          color:
                          currentTab == "Accounting" ? EKodi().themeColor : Colors.white,
                        ),
                        title: Text(
                          "Accounting",
                          style: TextStyle(
                            color: currentTab == "Accounting"
                                ? EKodi().themeColor
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                isTenant ? InkWell(
                  onTap: () {
                    context.read<TabProvider>().changeTab("Invoice");
                  },
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    height: 50.0,
                    margin:const EdgeInsets.only(left: 10.0),
                    decoration: BoxDecoration(
                        color: currentTab == "Invoice" ? Colors.white : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(25.0))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: ListTile(
                        leading: Icon(
                          Icons.receipt_long_outlined,
                          color: currentTab == "Invoice" ? EKodi().themeColor : Colors.white,
                        ),
                        title: Text(
                          "Invoices",
                          style: TextStyle(
                            color:
                            currentTab == "Invoice" ? EKodi().themeColor : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ) : InkWell(
                  onTap: () {
                    context.read<TabProvider>().changeTab("Reports");
                  },
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    height: 50.0,
                    margin:const EdgeInsets.only(left: 10.0),
                    decoration: BoxDecoration(
                        color: currentTab == "Reports" ? Colors.white : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(25.0))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: ListTile(
                        leading: Icon(
                          Icons.receipt_long_outlined,
                          color: currentTab == "Reports" ? EKodi().themeColor : Colors.white,
                        ),
                        title: Text(
                          "Reports",
                          style: TextStyle(
                            color:
                            currentTab == "Reports" ? EKodi().themeColor : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    context.read<TabProvider>().changeTab("Messages");
                  },
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    height: 50.0,
                    margin:const EdgeInsets.only(left: 10.0),
                    decoration: BoxDecoration(
                        color: currentTab == "Messages" ? Colors.white : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(25.0))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: ListTile(
                        leading: Icon(
                          Icons.question_answer_outlined,
                          color: currentTab == "Messages" ? EKodi().themeColor : Colors.white,
                        ),
                        title: Text(
                          "Messages",
                          style: TextStyle(
                            color:
                            currentTab == "Messages" ? EKodi().themeColor : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    context.read<TabProvider>().changeTab("Tasks");
                  },
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    height: 50.0,
                    margin:const EdgeInsets.only(left: 10.0),
                    decoration: BoxDecoration(
                        color: currentTab == "Tasks" ? Colors.white : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(25.0))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: ListTile(
                        leading: Icon(
                          Icons.check_box_outlined,
                          color: currentTab == "Tasks" ? EKodi().themeColor : Colors.white,
                        ),
                        title: Text(
                          "Tasks",
                          style: TextStyle(
                            color: currentTab == "Tasks" ? EKodi().themeColor : Colors.white,
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
                    margin:const EdgeInsets.only(left: 10.0),
                    decoration: BoxDecoration(
                        color: currentTab == "Profile" ? Colors.white : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(25.0))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: ListTile(
                        leading: Icon(
                          Icons.person,
                          color:
                          currentTab == "Profile" ? EKodi().themeColor : Colors.white,
                        ),
                        title: Text(
                          "Account",
                          style: TextStyle(
                            color:
                            currentTab == "Profile" ? EKodi().themeColor : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0,),
                const Divider(color: Colors.white30,),
                const SizedBox(height: 20.0,),
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
                        color:
                        Colors.white,
                      ),
                    ),
                  ),
                ),
                // RaisedButton(
                //   onPressed: () {
                //     FirebaseFirestore.instance.collection("mymail").add({
                //       "to": ['briannamutali586@gmail.com'],
                //       "message": {
                //         "subject": 'Hello from Firebase!',
                //         "text": 'This is the plaintext section of the email body.',
                //         "html": 'This is the <code>HTML</code> section of the email body.',
                //       }
                //     });
                //   },
                // )
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
        return isMobile ? _buildForDesktop(context, account, size, currentTab) : _buildForDesktop(context, account, size, currentTab);
      },
    );
  }
}
