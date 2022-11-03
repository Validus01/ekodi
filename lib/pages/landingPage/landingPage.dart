import 'package:flutter/material.dart';
import 'package:rekodi/pages/landingPage/widgets/footer.dart';
import 'package:rekodi/pages/landingPage/widgets/homeProperties.dart';
import 'package:rekodi/pages/landingPage/widgets/intro.dart';
import 'package:rekodi/pages/landingPage/widgets/ratings.dart';
import 'package:rekodi/pages/landingPage/widgets/welcome.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: RawScrollbar(
        controller: _controller,
        isAlwaysShown: true,
        radius: const Radius.circular(5.0),
        thumbColor: Colors.grey,
        thickness: 10,
        child: SingleChildScrollView(
          controller: _controller,
          child: Column(
            children: const [
              Intro(),
              Welcome(),
              HomeProperties(),
              Ratings(),
              Footer()
            ],
          ),
        ),
      ),
    );
  }
}
