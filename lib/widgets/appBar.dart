import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rekodi/pages/authPage.dart';
import 'package:responsive_builder/responsive_builder.dart';

class CustomAppBar extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final ScrollController? controller;

  const CustomAppBar({Key? key, this.scaffoldKey, this.controller, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isDesktop = sizeInfo.isDesktop || sizeInfo.isTablet;

        return AppBar(
          title: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
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
          ),
          backgroundColor: Colors.grey.shade200,
          automaticallyImplyLeading: false,
          elevation: 0.0,
          actions: isDesktop
              ? [
            // TextButton(
            //   onPressed: () {
            //     FirebaseFirestore.instance.collection("users").get().then((value) {
            //       value.docs.forEach((element) {
            //         element.reference.set({
            //           "deviceTokens": []
            //         }, SetOptions(merge: true));
            //       });
            //     });
            //   },
            //   child: Text("Add token field", style: GoogleFonts.baloo2()),
            // ),
            // TextButton(
            //   onPressed: () {
            //     FirebaseFirestore.instance.collection("mail").add({
            //       "to": 'briannamutali586@gmail.com',
            //       "from": 'validustechnologiesltd@gmail.com',
            //       "message": {
            //         "subject": 'Hello from Firebase!',
            //         "html": '<p>This is a new email</p>',
            //       },
            //     });
            //   },
            //   child: Text("EMAIL TEST", style: GoogleFonts.baloo2()),
            // ),
                  TextButton(
                    onPressed: () =>controller!.animateTo(0.0, duration: const Duration(seconds: 2), curve: Curves.ease),
                    child: Text("Home", style: GoogleFonts.baloo2()),
                  ),
                  TextButton(
                    onPressed: () =>controller!.animateTo(800.0, duration: const Duration(seconds: 2), curve: Curves.ease),
                    child: Text("Services", style: GoogleFonts.baloo2()),
                  ),
                  TextButton(
                    onPressed: () => controller!.animateTo(1700.0, duration: const Duration(seconds: 2), curve: Curves.ease),
                    child: Text("Why Us", style: GoogleFonts.baloo2()),
                  ),
                  TextButton(
                    onPressed: () => controller!.animateTo(2300.0, duration: const Duration(seconds: 2), curve: Curves.ease),
                    child: Text("Features", style: GoogleFonts.baloo2()),
                  ),
                  TextButton(
                    onPressed: () => controller!.animateTo(2700.0, duration: const Duration(seconds: 2), curve: Curves.ease),
                    child: Text("Contact", style: GoogleFonts.baloo2()),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: RaisedButton(
                      onPressed: () {
                        Route route = MaterialPageRoute(
                            builder: (context) => const AuthPage());
                        Navigator.push(context, route);
                      },
                      color: Theme.of(context).primaryColor,
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      child: Text("Log In",
                          style: GoogleFonts.baloo2(color: Colors.white)),
                    ),
                  )
                ]
              : [
                  IconButton(
                    onPressed: () => scaffoldKey!.currentState!.openDrawer(),
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.black,
                    ),
                  )
                ],
        );
      },
    );
  }
}
