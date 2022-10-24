import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:seo_renderer/renderers/text_renderer/text_renderer_vm.dart';

class Welcome extends StatelessWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        bool isMobile = sizingInformation.isMobile;

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: isMobile ? size.width : size.width * 0.5),
            child: Container(
              color: Colors.pink.shade300,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextRenderer(
                      text: "Welcome to JVALUE Consultants",
                      child: Text("Welcome to JVALUE Consultants",
                          style: GoogleFonts.nunito(
                              fontSize: 22.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      height: 4.0,
                      width: size.width * 0.2,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.0),
                          color: Colors.white38),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const TextRenderer(
                      text:
                          "JVALUE is a full-service real estate and property management firm that doesn’t specialize in homes but in clients. We look at every client who walks through our door as a true partner and we always pledge to treat them with the care, attention and respect that they deserve as a result. If you’re looking for the perfect place to live, we can help. If you have an existing piece of property that you’re looking to manage more effectively for a more favorable return on investment, we’ll be here for you. Whether you want to dip your toe in the water of real estate investing or leap in with open arms, we’re everything you need us to be at a moment’s notice.",
                      child: Text(
                        "JVALUE is a full-service real estate and property management firm that doesn’t specialize in homes but in clients. We look at every client who walks through our door as a true partner and we always pledge to treat them with the care, attention and respect that they deserve as a result."
                        "\nIf you’re looking for the perfect place to live, we can help. If you have an existing piece of property that you’re looking to manage more effectively for a more favorable return on investment, we’ll be here for you. Whether you want to dip your toe in the water of real estate investing or leap in with open arms, we’re everything you need us to be at a moment’s notice.",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
