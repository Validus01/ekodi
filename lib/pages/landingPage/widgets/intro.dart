import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rekodi/pages/landingPage/widgets/landingButton.dart';
import 'package:rekodi/pages/landingPage/widgets/staticAppbar.dart';
import 'package:seo_renderer/renderers/text_renderer/text_renderer_vm.dart';

class Intro extends StatefulWidget {
  const Intro({Key? key}) : super(key: key);

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  List<String> buttons = ["HOME", "PROPERTIES", "ABOUT", "CONTACT US"];
  late final Timer timer;
  final List<String> imageUrls = [
    "assets/carousel/1.jpg",
    "assets/carousel/2.jpg"
  ];
  int _index = 0;

  // @override
  // void initState() {
  //   super.initState();
  //   timer = Timer.periodic(const Duration(seconds: 5), (timer) {
  //     setState(() => _index++);
  //   });
  // }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const StaticAppBar(
          isShrink: true,
          isAuth: false,
        ),
        Stack(
          children: [
            // AnimatedSwitcher(
            //   duration: const Duration(seconds: 5),
            //   switchInCurve: Curves.easeIn,
            //   switchOutCurve: Curves.easeOut,
            //   child: Image.asset(
            //     imageUrls[_index % imageUrls.length],
            //     height: size.height * 0.7,
            //     width: size.width,
            //     fit: BoxFit.cover,
            //   ),
            // ),
            Image.asset(
              imageUrls[0],
              height: size.height * 0.7,
              width: size.width,
              fit: BoxFit.cover,
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(left: size.width * 0.05),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: size.width * 0.5),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(5.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextRenderer(
                                text:
                                    "We are your biggest home ownership advocate!",
                                child: Text(
                                    "We are your biggest \nhome ownership advocate!",
                                    style: GoogleFonts.nunito(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              const TextRenderer(
                                text:
                                    "We provide a one-stop source for real estate services covering the country Kenya.",
                                child: Text(
                                    "We provide a one-stop source for real estate services covering the country Kenya."),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    LandingButton(
                      onTap: () {},
                      hoverFillColor: Colors.pink,
                      fillColor: Colors.pink,
                      hoverBorderColor: Colors.transparent,
                      borderColor: Colors.transparent,
                      hoverTextColor: Colors.white,
                      textColor: Colors.white,
                      fontSize: 14.0,
                      iconColor: Colors.pink,
                      iconData: Icons.arrow_forward_ios_rounded,
                      hoverIconColor: Colors.white,
                      title: "SEARCH PROPERTIES",
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
