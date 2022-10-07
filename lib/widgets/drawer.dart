import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rekodi/pages/authPage.dart';

class CustomDrawer extends StatelessWidget {
  final ScrollController? controller;
  const CustomDrawer({Key? key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Center(
              child: RichText(
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
              ),
            ),
          ),
          ListTile(
            onTap: () {
              controller!.animateTo(0.0, duration: const Duration(seconds: 2), curve: Curves.ease);
            },
            leading: const Icon(
              Icons.home,
              color: Colors.grey,
            ),
            title: Text("Home", style: GoogleFonts.baloo2()),
          ),
          ListTile(
            onTap: () => controller!.animateTo(900.0, duration: const Duration(seconds: 2), curve: Curves.ease),
            leading: const Icon(
              Icons.engineering_outlined,
              color: Colors.grey,
            ),
            title: Text("Services", style: GoogleFonts.baloo2()),
          ),
          ListTile(
            onTap: () {
              controller!.animateTo(2500.0, duration: const Duration(seconds: 2), curve: Curves.ease);
            },
            leading: const Icon(
              Icons.live_help_outlined,
              color: Colors.grey,
            ),
            title: Text("Why Us", style: GoogleFonts.baloo2()),
          ),
          ListTile(
            onTap: () {
              controller!.animateTo(3200.0, duration: const Duration(seconds: 2), curve: Curves.ease);
            },
            leading: const Icon(
              Icons.auto_awesome,
              color: Colors.grey,
            ),
            title: Text("Features", style: GoogleFonts.baloo2()),
          ),
          ListTile(
            onTap: () {
              controller!.animateTo(4000.0, duration: const Duration(seconds: 2), curve: Curves.ease);
            },
            leading: const Icon(
              Icons.support_agent,
              color: Colors.grey,
            ),
            title: Text("Contact", style: GoogleFonts.baloo2()),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: RaisedButton(
              onPressed: () {
                Route route =
                    MaterialPageRoute(builder: (context) => const AuthPage());
                Navigator.push(context, route);
              },
              color: Theme.of(context).primaryColor,
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              child: Text("Log In",
                  style: GoogleFonts.baloo2(color: Colors.white)),
            ),
          ),
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
        ],
      ),
    );
  }
}
