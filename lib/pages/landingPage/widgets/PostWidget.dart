import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rekodi/model/property.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:seo_renderer/renderers/image_renderer/image_renderer_web.dart';

import '../../../model/propertyImagesModel.dart';
import '../../../routes.dart';

class PostWidget extends StatefulWidget {
  final Property? property;
  const PostWidget({Key? key, this.property}) : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        bool isMobile = sizingInformation.isMobile;

        return isMobile
            ? PostWidgetMobile(
                property: widget.property,
              )
            : Padding(
                padding: const EdgeInsets.all(5.0),
                child: Card(
                  color: Colors.white,
                  shadowColor: Colors.black,
                  elevation: 10.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Stack(
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
                                    imagesCollection.add(
                                        PropertyImages.fromDocument(element));
                                  }

                                  if (imagesCollection.isEmpty) {
                                    return const Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                      size: 20.0,
                                    );
                                  } else {
                                    return ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(10.0)),
                                      child: ImageRenderer(
                                        alt: widget.property!.name!,
                                        child: Image.network(
                                          imagesCollection[0].imageUrls![0],
                                          width: size.width,
                                          height: size.height,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),

                            // Positioned(
                            //   bottom: 5.0,
                            //   right: 5.0,
                            //   child: RaisedButton(
                            //     color: Colors.pink,
                            //     elevation: 0.0,
                            //     shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(30.0)),
                            //     child: Text(
                            //       widget.p!.type!,
                            //       style: const TextStyle(color: Colors.white),
                            //     ),
                            //     onPressed: () {
                            //       CustomRoutes.router.navigateTo(context,
                            //           "/categories/${widget.post!.type!}");
                            //     },
                            //   ),
                            // )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
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
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20.0),
                                  ),
                                  Text(
                                    "${widget.property!.city}, ${widget.property!.country}",
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                ],
                              ),
                              Text(
                                widget.property!.notes!,
                                maxLines: 3,
                                style: const TextStyle(
                                    overflow: TextOverflow.fade),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 1.0,
                                    width: size.width,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.property!.priceRange!,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18.0),
                                      ),
                                      RaisedButton(
                                        color: Colors.pink,
                                        elevation: 0.0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0)),
                                        child: const Text(
                                          "Book Now",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          CustomRoutes.router.navigateTo(
                                            context,
                                            "/properties/${widget.property!.propertyID}",
                                          );
                                        },
                                      )
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
      },
    );
  }
}

class PostWidgetMobile extends StatefulWidget {
  final Property? property;
  const PostWidgetMobile({Key? key, this.property}) : super(key: key);

  @override
  State<PostWidgetMobile> createState() => _PostWidgetMobileState();
}

class _PostWidgetMobileState extends State<PostWidgetMobile> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        color: Colors.white,
        shadowColor: Colors.black,
        elevation: 10.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
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
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10.0)),
                          child: ImageRenderer(
                            alt: widget.property!.name!,
                            child: Image.network(
                              imagesCollection[0].imageUrls![0],
                              width: size.width,
                              height: size.height * 0.3,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),

                // Positioned(
                //   bottom: 5.0,
                //   right: 5.0,
                //   child: RaisedButton(
                //     color: Colors.pink,
                //     elevation: 0.0,
                //     shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(30.0)),
                //     child: Text(
                //       widget.post!.type!,
                //       style: const TextStyle(color: Colors.white),
                //     ),
                //     onPressed: () {
                //       CustomRoutes.router.navigateTo(
                //           context, "/categories/${widget.post!.type!}");
                //     },
                //   ),
                // )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                            fontWeight: FontWeight.w700, fontSize: 20.0),
                      ),
                      Text(
                        "${widget.property!.city}, ${widget.property!.country}",
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      widget.property!.notes!,
                      maxLines: 3,
                      style: const TextStyle(overflow: TextOverflow.fade),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 1.0,
                        width: size.width,
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.property!.priceRange!,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 18.0),
                          ),
                          RaisedButton(
                            color: Colors.pink,
                            elevation: 0.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            child: const Text(
                              "Book Now",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              CustomRoutes.router.navigateTo(
                                context,
                                "/properties/${widget.property!.propertyID}",
                              );
                            },
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
