import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/model/property.dart';
import 'package:rekodi/model/propertyImagesModel.dart';
import 'package:rekodi/providers/propertyProvider.dart';
import 'package:rekodi/providers/tabProvider.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../config.dart';
import '../model/account.dart';
import '../model/unit.dart';
import '../widgets/customAppBar.dart';
import '../widgets/loadingAnimation.dart';


class Properties extends StatefulWidget {
  const Properties({Key? key}) : super(key: key);

  @override
  State<Properties> createState() => _PropertiesState();
}

class _PropertiesState extends State<Properties> {
  TextEditingController controller = TextEditingController();
  bool loading = false;

  Widget _buildForMobile(Account account, Size size) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection("properties")
          .where("publisherID", isEqualTo: account.userID)
          .orderBy("timestamp", descending: true)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingAnimation();
        } else {
          List<Property> properties = [];

          for (var element in snapshot.data!.docs) {
            properties.add(Property.fromDocument(element));
          }

          if (properties.isEmpty) {
            return const Center(
              child: Text(
                "You don't have properties",
                style: TextStyle(color: Colors.grey),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: properties.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                Property property = properties[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  child: InkWell(
                    onTap: () async {
                      await context.read<PropertyProvider>().setSelectedProperty(property);

                      context.read<TabProvider>().changeTab("PropertyDetails");
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          showImages(property, size),
                          ListTile(
                            leading: const Icon(
                              Icons.house_rounded,
                              color: Colors.grey,
                              size: 30.0,
                            ),
                            title: Text(
                              property.name!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Published on " +
                                      DateFormat("dd MMM").format(DateTime
                                          .fromMillisecondsSinceEpoch(
                                          property.timestamp!)),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text("Units: ${property.units}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold))
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Text(property.vacant!.toString()),
                                      Text("Vacant")
                                    ]),
                                const SizedBox(
                                  width: 5.0,
                                ),
                                Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Text(property.occupied!.toString()),
                                      Text("Occupied")
                                    ])
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        }
      },
    );
  }

  Widget showImages(Property property, Size size) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection("properties")
          .doc(property.propertyID).collection("images").limit(1).get(),
      builder: (context, snapshot) {
        if(!snapshot.hasData)
          {
            return Container();
          }
        else
          {
            List<PropertyImages> imagesCollection = [];

            for (var element in snapshot.data!.docs) {
              imagesCollection.add(PropertyImages.fromDocument(element));
            }

            if(imagesCollection.isEmpty)
            {
              return Container();
            }
            else
            {
              return CarouselSlider(
                  items: List.generate(imagesCollection[0].imageUrls!.length, (imageIndex) {
                    return ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10.0)),
                      child: Image.network(
                        imagesCollection[0].imageUrls![imageIndex],
                        width: size.width,
                        height: 300.0,
                        fit: BoxFit.cover,
                      ),
                    );
                  }),
                  options: CarouselOptions(
                    height: 300,
                    //aspectRatio: 16/9,
                    viewportFraction: 1.0,
                    initialPage: 0,
                    enableInfiniteScroll: false,
                    //reverse: false,
                    autoPlay: false,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: false,
                    //onPageChanged: callbackFunction,
                    scrollDirection: Axis.horizontal,
                  )
              );
            }
          }
      },
    );
  }

  Widget _buildForDesktop(BuildContext context, Account account, Size size) {
    return Padding(
      padding: EdgeInsets.only(right: size.width*0.2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20.0,),
          Text("Properties", style: Theme.of(context).textTheme.titleMedium,),
          const SizedBox(height: 20.0,),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection("properties")
                .where("publisherID", isEqualTo: account.userID)
                .orderBy("timestamp", descending: true)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const LoadingAnimation();
              } else {
                List<Property> properties = [];

                snapshot.data!.docs.forEach((element) {
                  properties.add(Property.fromDocument(element));
                });

                if (properties.isEmpty) {
                  return const Center(
                    child: Text(
                      "You don't have properties",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: properties.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      Property property = properties[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: InkWell(
                          onTap: () async {
                            context.read<PropertyProvider>().setSelectedProperty(property);

                            context.read<TabProvider>().changeTab("PropertyDetails");
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                showImages(property, size),
                                ListTile(
                                  leading: const Icon(
                                    Icons.house_rounded,
                                    color: Colors.grey,
                                    size: 30.0,
                                  ),
                                  title: Text(
                                    property.name!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Published on " +
                                            DateFormat("dd MMM").format(DateTime
                                                .fromMillisecondsSinceEpoch(
                                                property.timestamp!)),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text("Units: ${property.units}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            Text(property.vacant!.toString()),
                                            const Text("Vacant")
                                          ]),
                                      const SizedBox(
                                        width: 5.0,
                                      ),
                                      Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            Text(property.occupied!.toString()),
                                            const Text("Occupied")
                                          ])
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile;

        return isMobile ? _buildForMobile(account, size) : _buildForDesktop(context, account, size);
      },
    );
  }
}
