import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/providers/tabProvider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../main.dart';
import '../model/account.dart';

class DashboardAppBar extends StatelessWidget {
  final Widget? addPropertyButton;
  final bool? automaticallyImplyLeading;

  const DashboardAppBar({Key? key, this.addPropertyButton, this.automaticallyImplyLeading,}) : super(key: key);

  Widget displayUserProfile(BuildContext context, Account account, bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18.0),
          child: account.photoUrl! == ""
              ? Image.asset(
            "assets/profile.png",
            height: 36.0,
            width: 36.0,
            fit: BoxFit.cover,
          )
              : Image.network(
            account.photoUrl!,
            height: 36.0,
            width: 36.0,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(
          width: 10.0,
        ),
        InkWell(
          onTap: () {
            context.read<TabProvider>().changeTab("Profile");
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.name!,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: isMobile ? Colors.white : Colors.black, fontSize: 13.0),
              ),
              Text(
                account.accountType!,
                style: const TextStyle(color: Colors.grey, fontSize: 11.0),
              )
            ],
          ),
        ),
        //const SizedBox(width: 10.0,),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.arrow_drop_down,
            color: isMobile ? Colors.white : Colors.black,
          ),
          offset: const Offset(0.0, 0.0),
          onSelected: (v) async {
            switch (v) {
              case "My Account":
                context.read<TabProvider>().changeTab("Profile");
                break;
              // case "Settings":
              // //Go to settings page
              //   break;
              case "Logout":
              //Logout user
                await FirebaseAuth.instance.signOut();

                Route route = MaterialPageRoute(
                    builder: (context) => const SplashScreen());

                Navigator.pushReplacement(context, route);
            }
          },
          itemBuilder: (BuildContext context) {
            return ["My Account", "Logout"].map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;

    String currentTab = context.watch<TabProvider>().currentTab;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile || sizeInfo.isTablet ;

        return AppBar(
          backgroundColor: isMobile ? Colors.black : Colors.white,
          automaticallyImplyLeading: automaticallyImplyLeading!,
          //elevation: 0.0,
          title: Row(
            children: [
              isMobile ? RichText(
                text: TextSpan(
                  //style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                        text: 'e-',
                        style: GoogleFonts.titanOne(
                            color: Colors.blue, fontSize: 20.0)),
                    TextSpan(
                        text: 'KODI',
                        style: GoogleFonts.titanOne(
                            color: Colors.red, fontSize: 20.0)),
                  ],
                ),
              ) : Container(),
              const SizedBox(
                width: 10.0,
              ),
              const VerticalDivider(
                color: Colors.grey,
              ),
              !isMobile ? Icon(
                Icons.phone,
                color: Colors.blueAccent.shade700,
                size: 15.0,
              ) : Container(),
              const SizedBox(
                width: 10.0,
              ),
              if (!isMobile) InkWell(
                onTap: () => launch("tel:+254701518100"),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "+254701518100",
                      style: TextStyle(color: Colors.black, fontSize: 13.0),
                    ),
                    Text(
                      "Help & Support",
                      style: TextStyle(color: Colors.grey, fontSize: 11.0),
                    ),
                  ],
                ),
              ) else Container()
            ],
          ),
          actions: [
            addPropertyButton!,
            isMobile ? Container() : IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_active_rounded,
                color: Colors.grey,
              ),
            ),
            const SizedBox(
              width: 10.0,
            ),
            isMobile ? Container() : IconButton(
              onPressed: () {
                context.read<TabProvider>().changeTab("Messages");
              },
              icon: Icon(
                Icons.question_answer_outlined,
                color: currentTab == 'Messages' ? isMobile ? Colors.white : EKodi().themeColor : Colors.grey,
              ),
            ),
            const SizedBox(
              width: 10.0,
            ),
            isMobile ? Container() : displayUserProfile(context, account, isMobile),
            const SizedBox(
              width: 20.0,
            ),
          ],
        );
      },
    );
  }
}
