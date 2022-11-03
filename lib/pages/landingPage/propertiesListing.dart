import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rekodi/model/property.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../model/propertyImagesModel.dart';
import '../../routes.dart';
import '../../widgets/ProgressWidget.dart';
import '../../widgets/customButton.dart';
import 'widgets/footer.dart';
import 'widgets/staticAppbar.dart';

class PropertiesListing extends StatefulWidget {
  const PropertiesListing({Key? key}) : super(key: key);

  @override
  State<PropertiesListing> createState() => _PropertiesListingState();
}

class _PropertiesListingState extends State<PropertiesListing> {
  final ScrollController _controller = ScrollController();
  int limit = 15;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(size.width, 50.0),
          child: const StaticAppBar(
            isShrink: true,
            isAuth: false,
          )),
      body: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          bool isMobile = sizingInformation.isMobile;

          return RawScrollbar(
            controller: _controller,
            isAlwaysShown: true,
            radius: const Radius.circular(6.0),
            thumbColor: Colors.grey,
            thickness: 7.0,
            child: SingleChildScrollView(
              controller: _controller,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 800.0,
                      minWidth: 450.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isMobile
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Properties",
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () => CustomRoutes.router
                                            .navigateTo(context, "/"),
                                        child: Text(
                                          "Home ",
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Colors.grey,
                                        size: 12.0,
                                      ),
                                      Text(
                                        " Properties",
                                        style:
                                            Theme.of(context).textTheme.caption,
                                      )
                                    ],
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Properties",
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () => CustomRoutes.router
                                            .navigateTo(context, "/"),
                                        child: Text(
                                          "Home ",
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Colors.grey,
                                        size: 12.0,
                                      ),
                                      Text(
                                        " Properties",
                                        style:
                                            Theme.of(context).textTheme.caption,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                        FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection("properties")
                              .orderBy("timestamp", descending: true)
                              .limit(limit)
                              .get(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return circularProgress();
                            } else {
                              List<Property> properties = [];

                              snapshot.data!.docs.forEach((element) {
                                Property post = Property.fromDocument(element);

                                properties.add(post);
                              });

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: properties.length,
                                    itemBuilder: (context, index) {
                                      Property property = properties[index];

                                      return ListingItem(
                                        property: property,
                                      );
                                    },
                                  ),
                                  properties.length < 15
                                      ? Container()
                                      : CustomButton(
                                          title: "Load More",
                                          color: Colors.pink,
                                          onTap: () {
                                            setState(() {
                                              limit = limit + 10;
                                            });
                                          },
                                        ),
                                  const SizedBox(
                                    height: 50.0,
                                  )
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const Footer()
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ListingItem extends StatefulWidget {
  final Property? property;
  const ListingItem({Key? key, this.property}) : super(key: key);

  @override
  State<ListingItem> createState() => _ListingItemState();
}

class _ListingItemState extends State<ListingItem> {
  bool onHover = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        bool isMobile = sizingInformation.isMobile;

        return InkWell(
          onTap: () {
            CustomRoutes.router.navigateTo(
              context,
              "/properties/${widget.property!.propertyID}",
            );
          },
          hoverColor: Colors.transparent,
          onHover: (v) {
            setState(() {
              onHover = v;
            });
          },
          child: Card(
            color: Colors.white,
            shadowColor: Colors.black,
            elevation: onHover ? 10.0 : 5.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Container(
              height: isMobile ? 150.0 : 300.0,
              //padding: const EdgeInsets.all(10.0),
              width: size.width,
              decoration: const BoxDecoration(
                  borderRadius:
                      BorderRadius.horizontal(left: Radius.circular(10.0))),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("properties")
                        .doc(widget.property!.propertyID)
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
                          return ClipRRect(
                            borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(10.0)),
                            child: Image.network(
                              imagesCollection[0].imageUrls![0],
                              height: size.height,
                              width: isMobile ? 150.0 : 300.0,
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.property!.name!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                widget.property!.city! +
                                    ", " +
                                    widget.property!.country!,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                          Text(
                            widget.property!.notes!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(
                                    Icons.hotel,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  Text(
                                    widget.property!.priceRange!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
