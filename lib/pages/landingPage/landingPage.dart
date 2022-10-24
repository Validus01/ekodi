import 'package:flutter/material.dart';
import 'package:rekodi/pages/landingPage/widgets/footer.dart';
import 'package:rekodi/pages/landingPage/widgets/intro.dart';
import 'package:rekodi/pages/landingPage/widgets/welcome.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: const [Intro(), Welcome(), Footer()],
        ),
      ),
    );
  }
}
