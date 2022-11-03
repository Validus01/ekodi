import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rekodi/model/property.dart';
import 'package:rekodi/pages/landingPage/widgets/footer.dart';
import 'package:rekodi/pages/landingPage/widgets/staticAppbar.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../model/propertyImagesModel.dart';
import '../../widgets/ProgressWidget.dart';
import 'widgets/videoCard.dart';

class PostDetails extends StatefulWidget {
  final String? propertyID;
  const PostDetails({Key? key, this.propertyID}) : super(key: key);

  @override
  State<PostDetails> createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  final ScrollController _controller = ScrollController();

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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("properties")
            .doc(widget.propertyID!)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
              height: size.height,
              width: size.width,
              child: circularProgress(),
            );
          } else {
            Property property = Property.fromDocument(snapshot.data!);

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("properties")
                          .doc(property.propertyID)
                          .collection("images")
                          .limit(1)
                          .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return linearProgress();
                        } else {
                          List<PropertyImages> imagesCollection = [];

                          for (var element in snapshot.data!.docs) {
                            imagesCollection
                                .add(PropertyImages.fromDocument(element));
                          }

                          List<dynamic> imageUrls =
                              imagesCollection[0].imageUrls!;

                          return imageUrls.length == 1
                              ? Image.network(
                                  imageUrls[0],
                                  height: size.height * 0.6,
                                  width: size.width,
                                  fit: BoxFit.cover,
                                )
                              : CarouselDisplay(
                                  imageUrls: imageUrls,
                                );
                        }
                      },
                    ),
                    ResponsiveBuilder(
                      builder: (context, sizingInformation) {
                        bool isMobile = sizingInformation.isMobile;

                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 20.0 : size.width * 0.1,
                              vertical: 20.0),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 800.0,
                              minWidth: 300.0,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 40.0,
                                ),
                                // RaisedButton(
                                //   color: Colors.pink.shade50,
                                //   elevation: 0.0,
                                //   shape: RoundedRectangleBorder(
                                //       borderRadius:
                                //           BorderRadius.circular(30.0)),
                                //   child: Text(
                                //     post.type!,
                                //     style: const TextStyle(color: Colors.pink),
                                //   ),
                                //   onPressed: () {
                                //     CustomRoutes.router.navigateTo(
                                //         context, "/categories/${post.type!}");
                                //   },
                                // ),
                                Text(
                                  property.name!,
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                Text(
                                  property.city! + ", " + property.country!,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(property.priceRange!),
                                const SizedBox(
                                  height: 40.0,
                                ),
                                Text(
                                  "Overview",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .apply(
                                        color: Colors.pink,
                                      ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: 1.0,
                                          width: size.width,
                                          color: Colors.pink,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 9,
                                        child: Container(
                                          height: 1.0,
                                          width: size.width,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(property.notes!),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                FutureBuilder<QuerySnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection("properties")
                                      .doc(property.propertyID)
                                      .collection("videos")
                                      .limit(1)
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return circularProgress();
                                    } else {
                                      List<dynamic> videoUrls = [];

                                      if (snapshot.data!.docs.isNotEmpty) {
                                        videoUrls =
                                            snapshot.data!.docs[0]["videoUrls"];
                                      }

                                      if (videoUrls.isEmpty) {
                                        return Container();
                                      } else {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: List.generate(
                                              videoUrls.length, (index) {
                                            return VideoCard(
                                              videoUrl: videoUrls[index],
                                            );
                                          }),
                                        );
                                      }
                                    }
                                  },
                                ),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                // BookingForm(
                                //   post: post,
                                // ),
                                const SizedBox(
                                  height: 40.0,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const Footer(),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class CarouselDisplay extends StatefulWidget {
  final List<dynamic>? imageUrls;
  const CarouselDisplay({Key? key, this.imageUrls}) : super(key: key);

  @override
  State<CarouselDisplay> createState() => _CarouselDisplayState();
}

class _CarouselDisplayState extends State<CarouselDisplay> {
  CarouselController carouselController = CarouselController();
  //bool onHover = false;
  bool onArrowBackHover = false;
  bool onArrowFowardHover = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        bool isMobile = sizingInformation.isMobile;

        return Stack(
          children: [
            CarouselSlider(
                items: List.generate(widget.imageUrls!.length, (index) {
                  return Image.network(
                    widget.imageUrls![index],
                    height: size.height * 0.5,
                    width: size.width,
                    fit: BoxFit.cover,
                  );
                }),
                carouselController: carouselController,
                options: CarouselOptions(
                  height: size.height * 0.5,
                  //aspectRatio: 16 / 9,
                  viewportFraction: isMobile ? 1.0 : 0.4,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: false,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: false,
                  //onPageChanged: callbackFunction,
                  scrollDirection: Axis.horizontal,
                )),
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => carouselController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.fastOutSlowIn),
                        onHover: (v) {
                          setState(() {
                            onArrowBackHover = v;
                          });
                        },
                        child: CircleAvatar(
                          radius: 40.0,
                          backgroundColor:
                              onArrowBackHover ? Colors.pink : Colors.black38,
                          child: const Center(
                              child: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.white,
                          )),
                        ),
                      ),
                      InkWell(
                        onTap: () => carouselController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.fastOutSlowIn),
                        onHover: (v) {
                          setState(() {
                            onArrowFowardHover = v;
                          });
                        },
                        child: CircleAvatar(
                          radius: 40.0,
                          backgroundColor:
                              onArrowFowardHover ? Colors.pink : Colors.black38,
                          child: const Center(
                              child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

// class BookingForm extends StatefulWidget {
//   final Post? post;
//   const BookingForm({Key? key, this.post}) : super(key: key);

//   @override
//   State<BookingForm> createState() => _BookingFormState();
// }

// class _BookingFormState extends State<BookingForm> {
//   TextEditingController name = TextEditingController();
//   TextEditingController phone = TextEditingController();
//   TextEditingController email = TextEditingController();
//   TextEditingController adultsNo = TextEditingController();
//   TextEditingController childrenNo = TextEditingController();
//   TextEditingController message = TextEditingController();
//   DateTime start = DateTime.now();
//   DateTime end = DateTime.now().add(const Duration(days: 3));
//   bool sending = false;

//   void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
//     setState(() {
//       if (args.value is PickerDateRange) {
//         start = args.value.startDate;
//         end = args.value.endDate ??
//             args.value.startDate.add(const Duration(days: 3));
//       }
//     });
//   }

//   displayCalendar() {
//     Size size = MediaQuery.of(context).size;

//     showDialog<void>(
//       context: context,
//       barrierDismissible: true,
//       // false = user must tap button, true = tap outside dialog
//       builder: (BuildContext dialogContext) {
//         return ResponsiveBuilder(
//           builder: (context, sizeInfo) {
//             bool isDesktop = sizeInfo.isDesktop;

//             return AlertDialog(
//               title: const Text("Pick Range"),
//               content: Container(
//                   height: isDesktop ? size.height * 0.6 : size.height * 0.4,
//                   width: isDesktop ? size.width * 0.4 : size.width * 0.8,
//                   decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20.0)),
//                   child: SfDateRangePicker(
//                     view: DateRangePickerView.month,
//                     onSelectionChanged: _onSelectionChanged,
//                     enableMultiView: isDesktop ? true : false,
//                     selectionMode: DateRangePickerSelectionMode.range,
//                     initialSelectedRange: PickerDateRange(
//                       start,
//                       end,
//                     ),
//                   )),
//               actions: [
//                 TextButton.icon(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   icon: Icon(Icons.done, color: Theme.of(context).primaryColor),
//                   label: Text(
//                     "Done",
//                     style: TextStyle(color: Theme.of(context).primaryColor),
//                   ),
//                 )
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   sendRequest() async {
//     setState(() {
//       sending = true;
//     });
//     String bookId = DateTime.now().millisecondsSinceEpoch.toString();

//     BookingRequest bookingRequest = BookingRequest(
//       requestID: bookId,
//       name: name.text.trim(),
//       phone: phone.text.trim(),
//       email: email.text.trim(),
//       message: message.text.isNotEmpty ? message.text : "",
//       adultsNo: adultsNo.text.isNotEmpty ? int.parse(adultsNo.text.trim()) : 0,
//       childrenNo:
//           childrenNo.text.isNotEmpty ? int.parse(childrenNo.text.trim()) : 0,
//       startDate: start.millisecondsSinceEpoch,
//       endDate: end.millisecondsSinceEpoch,
//       post: widget.post!.toMap(),
//     );

//     await FirebaseFirestore.instance
//         .collection("bookingRequests")
//         .doc(bookId)
//         .set(bookingRequest.toMap())
//         .then((value) =>
//             Fluttertoast.showToast(msg: "Request Sent Successfully!"));

//     setState(() {
//       sending = false;
//       name.clear();
//       phone.clear();
//       email.clear();
//       message.clear();
//       adultsNo.clear();
//       childrenNo.clear();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;

//     return sending
//         ? circularProgress()
//         : Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Interested? Fill in the booking form below to book",
//                   style: Theme.of(context).textTheme.headline6),
//               const Text("Fields marked with an * are required"),
//               CustomTextField(
//                 title: "Name *",
//                 controller: name,
//                 hintText: "Name",
//                 inputType: TextInputType.name,
//               ),
//               CustomTextField(
//                 title: "Phone *",
//                 controller: phone,
//                 hintText: "Phone",
//                 inputType: TextInputType.phone,
//               ),
//               CustomTextField(
//                 title: "Email *",
//                 controller: email,
//                 hintText: "Email",
//                 inputType: TextInputType.emailAddress,
//               ),
//               RaisedButton.icon(
//                 onPressed: () => displayCalendar(),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30.0)),
//                 color: Colors.pink.shade50,
//                 icon: const Icon(
//                   Icons.date_range_rounded,
//                   color: Colors.pink,
//                   size: 15.0,
//                 ),
//                 label: Text(
//                   "Start Date: " +
//                       DateFormat("dd MMM yyyy").format(start) +
//                       "\nEnd Date: " +
//                       DateFormat("dd MMM yyyy").format(end),
//                   style: Theme.of(context)
//                       .textTheme
//                       .button!
//                       .apply(color: Colors.pink),
//                 ),
//               ),
//               CustomTextField(
//                 title: "Number of Adults *",
//                 controller: adultsNo,
//                 hintText: "0",
//                 inputType: TextInputType.number,
//               ),
//               CustomTextField(
//                 title: "Number of Children",
//                 controller: childrenNo,
//                 hintText: "0",
//                 inputType: TextInputType.number,
//               ),
//               CustomTextField(
//                 title: "Message / Instructions",
//                 controller: message,
//                 hintText: "Type something here...",
//                 inputType: TextInputType.text,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   CustomButton(
//                     title: "Send Request",
//                     color: Colors.pink,
//                     onTap: () {
//                       if (name.text.isNotEmpty &&
//                           phone.text.isNotEmpty &&
//                           email.text.isNotEmpty &&
//                           adultsNo.text.isNotEmpty) {
//                         sendRequest();
//                       } else {
//                         Fluttertoast.showToast(
//                             msg: "Fill in the required information");
//                       }
//                     },
//                   ),
//                   const SizedBox()
//                 ],
//               )
//             ],
//           );
//   }
// }
