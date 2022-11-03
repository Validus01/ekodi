import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rekodi/model/property.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../config.dart';
import '../../model/propertyImagesModel.dart';
import '../../widgets/ProgressWidget.dart';
import '../widgets/propertiesDataCard.dart';

class PropertiesTab extends StatefulWidget {
  const PropertiesTab({Key? key}) : super(key: key);

  @override
  State<PropertiesTab> createState() => _PropertiesTabState();
}

class _PropertiesTabState extends State<PropertiesTab> {
  String tab = "All";

  Widget _buildPropertiesList(Size size, List<Property> properties) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$tab Properties",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.grey,
                    //size: 25.0,
                  ),
                  offset: const Offset(0.0, 10.0),
                  onSelected: (v) {
                    setState(() {
                      tab = v;
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      "All",
                    ].map((String choice) {
                      bool isSelected = choice == tab;
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(
                          choice,
                          style: TextStyle(
                              color: isSelected ? Colors.pink : Colors.grey),
                        ),
                      );
                    }).toList();
                  },
                )
              ],
            ),
            const Divider(
              height: 20.0,
              thickness: 1.0,
              color: Colors.grey,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(generatePropertyGroups(properties).length,
                  (index) {
                Property property = generatePropertyGroups(properties)[index];

                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ListTile(
                    onTap: () {}, //TODO
                    leading: FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("properties")
                          .doc(property.propertyID)
                          .collection("images")
                          .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text("Loading...");
                        } else {
                          List<PropertyImages> imagesCollection = [];

                          for (var element in snapshot.data!.docs) {
                            imagesCollection
                                .add(PropertyImages.fromDocument(element));
                          }

                          if (imagesCollection.isEmpty) {
                            return const Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: 20.0,
                            );
                          } else {
                            return ResponsiveBuilder(
                              builder: (context, sizingInformation) {
                                bool isMobile = sizingInformation.isMobile;

                                return Image.network(
                                  imagesCollection[0].imageUrls![0],
                                  height: 150.0,
                                  width: isMobile
                                      ? size.width * 0.3
                                      : size.width * 0.2,
                                  fit: BoxFit.cover,
                                );
                              },
                            );
                          }
                        }
                      },
                    ),
                    title: Text(property.name!),
                    subtitle: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Created: ${DateFormat("HH:mm a, dd MMM yyyy").format(DateTime.fromMillisecondsSinceEpoch(property.timestamp!))}",
                          style: Theme.of(context).textTheme.caption,
                        ),
                        Text(
                          "Occupied Units: ${property.occupied}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Vacant Units: ${property.vacant}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }),
            )
          ],
        ),
      ),
    );
  }

  List<Property> generatePropertyGroups(List<Property> properties) {
    switch (tab) {
      case "All":
        return properties;
      default:
        return properties;
    }
  }

  Widget headerWidget(
    Size size,
  ) {
    return Container(
      height: size.height * 0.25,
      width: size.width,
      color: EKodi.themeColor.withOpacity(0.4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800.0, minWidth: 300),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Properties",
                style: Theme.of(context)
                    .textTheme
                    .headline3!
                    .apply(color: Colors.white),
              ),
              const SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("properties")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        } else {
          List<Property> properties = [];

          snapshot.data!.docs.forEach((element) {
            Property property = Property.fromDocument(element);

            properties.add(property);
          });

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              headerWidget(size),
              PropertiesDataCard(
                properties: properties,
              ),
              const SizedBox(
                height: 20.0,
              ),
              _buildPropertiesList(size, properties),
              const SizedBox(
                height: 50.0,
              ),
            ],
          );
        }
      },
    );
  }
}
