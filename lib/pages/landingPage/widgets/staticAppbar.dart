import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../routes.dart';
import 'landingButton.dart';

class StaticAppBar extends StatelessWidget {
  final bool? isShrink;
  final bool? isAuth;

  const StaticAppBar({Key? key, this.isShrink, this.isAuth}) : super(key: key);

  choiceAction(BuildContext context, String choice) {
    switch (choice) {
      case "HOME":
        CustomRoutes.router.navigateTo(context, "/home");
        break;
      case "PROPERTIES":
        CustomRoutes.router.navigateTo(context, "/properties");
        break;
      case "ABOUT":
        CustomRoutes.router.navigateTo(context, "/about");
        break;
      case "CONTACT US":
        launch("tel:+254700000000");
        break;
      case "LAUNCH":
        CustomRoutes.router.navigateTo(context, "/authentication");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        bool isMobile =
            sizingInformation.isMobile || sizingInformation.isTablet;

        return AnimatedContainer(
          duration: const Duration(seconds: 2),
          decoration: BoxDecoration(
              color: isShrink! ? Colors.white : Colors.transparent),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => CustomRoutes.router.navigateTo(context, "/home"),
                  child: Image.asset(
                    "assets/logo.png",
                    height: 100.0,
                    width: 100.0,
                    fit: BoxFit.contain,
                  ),
                ),
                isMobile
                    ? PopupMenuButton<String>(
                        icon: Icon(
                          Icons.menu,
                          color: isShrink! ? Colors.pink : Colors.white,
                          //size: 25.0,
                        ),
                        offset: const Offset(0.0, 10.0),
                        onSelected: (v) {
                          choiceAction(context, v);
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            "HOME",
                            "PROPERTIES",
                            "ABOUT",
                            "CONTACT US",
                            "LAUNCH"
                          ].map((String choice) {
                            bool isLaunch = choice == "LAUNCH";
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(
                                choice,
                                style: TextStyle(
                                    color:
                                        isLaunch ? Colors.pink : Colors.grey),
                              ),
                            );
                          }).toList();
                        },
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextButton(
                              onPressed: () => CustomRoutes.router
                                  .navigateTo(context, "/home"),
                              child: Text(
                                "HOME",
                                style: TextStyle(
                                    color:
                                        isShrink! ? Colors.grey : Colors.white),
                              )),
                          TextButton(
                              onPressed: () => CustomRoutes.router
                                  .navigateTo(context, "/properties"),
                              child: Text(
                                "PROPERTIES",
                                style: TextStyle(
                                    color:
                                        isShrink! ? Colors.grey : Colors.white),
                              )),
                          TextButton(
                              onPressed: () => CustomRoutes.router
                                  .navigateTo(context, "/about"),
                              child: Text(
                                "ABOUT",
                                style: TextStyle(
                                    color:
                                        isShrink! ? Colors.grey : Colors.white),
                              )),
                          TextButton(
                              onPressed: () {
                                launch("tel:+254700000000");
                              },
                              child: Text(
                                "CONTACT US",
                                style: TextStyle(
                                    color:
                                        isShrink! ? Colors.grey : Colors.white),
                              )),
                          isAuth!
                              ? Container()
                              : LandingButton(
                                  onTap: () {
                                    CustomRoutes.router
                                        .navigateTo(context, "/authentication");
                                  },
                                  hoverFillColor: Colors.pink,
                                  hoverBorderColor: Colors.transparent,
                                  borderColor: Colors.transparent,
                                  hoverTextColor: Colors.white,
                                  textColor: Colors.pink,
                                  fontSize: 14.0,
                                  iconColor: Colors.pink,
                                  //iconData: Icons.add,
                                  hoverIconColor: Colors.white,
                                  title: "LAUNCH",
                                ),
                        ],
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
