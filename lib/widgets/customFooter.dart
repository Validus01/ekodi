import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20.0,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("\u00a9 e-kodi,Inc", textAlign: TextAlign.center, style: GoogleFonts.baloo2(fontSize: 18.0)),
            Text("All Rights Reserved.", textAlign: TextAlign.center, style: GoogleFonts.baloo2(fontSize: 18.0)),
          ],
        ),
        const SizedBox(height: 20.0,),
      ],
    );
  }
}
