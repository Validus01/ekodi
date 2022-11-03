import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rekodi/model/property.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../routes.dart';
import '../../../widgets/ProgressWidget.dart';
import 'PostWidget.dart';

class HomeProperties extends StatefulWidget {
  const HomeProperties({Key? key}) : super(key: key);

  @override
  State<HomeProperties> createState() => _HomePropertiesState();
}

class _HomePropertiesState extends State<HomeProperties> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => const HolidayHomesMobile(),
      tablet: (BuildContext context) => const HolidayHomesTablet(),
      desktop: (BuildContext context) => const HolidayHomesDesktop(),
      watch: (BuildContext context) => Container(color: Colors.white),
    );
  }
}

class HolidayHomesMobile extends StatelessWidget {
  const HolidayHomesMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //const SizedBox(),
              Text(
                "Properties",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline4,
              ),
              TextButton.icon(
                onPressed: () {
                  CustomRoutes.router.navigateTo(
                    context,
                    "/properties",
                  );
                },
                icon: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.pink,
                ),
                label: const Text(
                  "See All",
                  style: TextStyle(color: Colors.pink),
                ),
              )
            ],
          ),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection("properties")
                .orderBy("timestamp", descending: true)
                .limit(6)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              } else {
                List<Property> properties = [];

                snapshot.data!.docs.forEach((element) {
                  Property property = Property.fromDocument(element);

                  properties.add(property);
                });

                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(properties.length, (index) {
                    Property property = properties[index];

                    return PostWidget(
                      property: property,
                    );
                  }),
                );
              }
            },
          )
        ],
      ),
    );
  }
}

class HolidayHomesTablet extends StatelessWidget {
  const HolidayHomesTablet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //const SizedBox(),
              Text(
                "Properties",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline4,
              ),
              TextButton.icon(
                onPressed: () {
                  CustomRoutes.router.navigateTo(
                    context,
                    "/properties",
                  );
                },
                icon: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.pink,
                ),
                label: const Text(
                  "See All",
                  style: TextStyle(color: Colors.pink),
                ),
              )
            ],
          ),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection("properties")
                .orderBy("timestamp", descending: true)
                .limit(8)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              } else {
                List<Property> properties = [];

                snapshot.data!.docs.forEach((element) {
                  Property property = Property.fromDocument(element);

                  properties.add(property);
                });

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2 / 3,
                  children: List.generate(properties.length, (index) {
                    Property property = properties[index];

                    return PostWidget(
                      property: property,
                    );
                  }),
                );
              }
            },
          )
        ],
      ),
    );
  }
}

class HolidayHomesDesktop extends StatelessWidget {
  const HolidayHomesDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 1000.0,
        minWidth: 450.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //const SizedBox(),
              Text(
                "Properties",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline4,
              ),
              TextButton.icon(
                onPressed: () {
                  CustomRoutes.router.navigateTo(
                    context,
                    "/properties",
                  );
                },
                icon: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.pink,
                ),
                label: const Text(
                  "See All",
                  style: TextStyle(color: Colors.pink),
                ),
              )
            ],
          ),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection("properties")
                .orderBy("timestamp", descending: true)
                .limit(9)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              } else {
                List<Property> properties = [];

                snapshot.data!.docs.forEach((element) {
                  Property property = Property.fromDocument(element);

                  properties.add(property);
                });

                return GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2 / 3,
                  children: List.generate(properties.length, (index) {
                    Property property = properties[index];

                    return PostWidget(
                      property: property,
                    );
                  }),
                );
              }
            },
          )
        ],
      ),
    );
  }
}
