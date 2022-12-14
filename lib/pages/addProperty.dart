import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/commonFunctions/fileManager.dart';
import 'package:rekodi/config.dart';
import 'package:rekodi/model/property.dart';
import 'package:rekodi/model/propertyVideos.dart';
import 'package:rekodi/providers/tabProvider.dart';
import 'package:rekodi/widgets/loadingAnimation.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:uuid/uuid.dart';

import '../model/account.dart';
import '../model/propertyImagesModel.dart';
import '../model/unit.dart';
import '../widgets/customTextField.dart';
import '../widgets/videoCard.dart';

class AddProperty extends StatefulWidget {
  const AddProperty({Key? key}) : super(key: key);

  @override
  State<AddProperty> createState() => _AddPropertyState();
}

class _AddPropertyState extends State<AddProperty> {
  TextEditingController city = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController notes = TextEditingController();
  TextEditingController town = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController unitName = TextEditingController();
  TextEditingController unitDesc = TextEditingController();
  TextEditingController lowerLimit = TextEditingController();
  TextEditingController upperLimit = TextEditingController();
  List<Unit> units = [];
  bool isMultiUnit = false;
  String propertyID = Uuid().v4();
  bool loading = false;
  List<PlatformFile> imageFiles = [];
  List<PlatformFile> videoFiles = [];
  List<String> imageUrls = [];
  List<String> videoUrls = [];
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    setState(() {
      country.text = "Kenya";
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  savePropertyToDatabase() async {
    if (name.text.isNotEmpty &&
        country.text.isNotEmpty &&
        city.text.isNotEmpty &&
        address.text.isNotEmpty &&
        imageFiles.isNotEmpty &&
        upperLimit.text.isNotEmpty &&
        lowerLimit.text.isNotEmpty &&
        town.text.isNotEmpty) {
      setState(() {
        loading = true;
      });

      String userID =
          Provider.of<EKodi>(context, listen: false).account.userID!;

      Property property = Property(
        name: name.text.trim(),
        propertyID: propertyID,
        city: city.text.trim(),
        country: country.text.trim(),
        town: town.text.trim(),
        address: address.text.trim(),
        notes: notes.text.trim(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
        units: isMultiUnit ? units.length : 1,
        publisherID: userID,
        vacant: isMultiUnit ? units.length : 1,
        occupied: 0,
        priceRange:
            "KES " + lowerLimit.text.trim() + " - " + upperLimit.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('properties')
          .doc(property.propertyID)
          .set(property.toMap())
          .then((value) async {
        if (isMultiUnit && units.isNotEmpty) {
          units.forEach((unit) async {
            await FirebaseFirestore.instance
                .collection('properties')
                .doc(property.propertyID)
                .collection("units")
                .doc(unit.unitID.toString())
                .set(unit.toMap());
          });
        } else {
          Unit unit = Unit(
            unitID: property.timestamp,
            name: name.text.trim(),
            description: notes.text.trim(),
            tenantInfo: {},
            isOccupied: false,
            rent: 0,
            dueDate: 0,
            propertyID: property.propertyID,
            deposit: 0,
            startDate: 0,
            paymentFreq: "",
            reminder: 0,
            publisherID: userID,
            isAccepted: false,
          );

          await FirebaseFirestore.instance
              .collection('properties')
              .doc(property.propertyID)
              .collection("units")
              .doc(unit.unitID.toString())
              .set(unit.toMap());
        }
      });

      context.read<TabProvider>().changeTab("Dashboard");

      Fluttertoast.showToast(msg: "Uploading Images...");

      await uploadImagesToDatabase(property);

      Fluttertoast.showToast(msg: "Image upload Successful!");

      if (videoFiles.isNotEmpty) {
        Fluttertoast.showToast(msg: "Uploading Videos...");

        await uploadVideosToDatabase(property);

        Fluttertoast.showToast(msg: "Videos upload Successful!");
      }

      setState(() {
        loading = false;
      });
    } else if (imageFiles.isEmpty) {
      Fluttertoast.showToast(msg: "Pick atleast 1 image");
    } else {
      Fluttertoast.showToast(msg: "Kindly fill the required fields");
    }
  }

  Future<void> uploadVideosToDatabase(Property property) async {
    for (var videoFile in videoFiles) {
      String url = await FileManager().uploadPropertyVideo(property, videoFile);

      videoUrls.add(url);
    }

    if (videoUrls.isNotEmpty) {
      PropertyVideos propertyVideos = PropertyVideos(
        timestamp: DateTime.now().millisecondsSinceEpoch,
        videoUrls: videoUrls,
      );

      // save video collection to firestore
      await FirebaseFirestore.instance
          .collection("properties")
          .doc(property.propertyID)
          .collection("videos")
          .doc(propertyVideos.timestamp.toString())
          .set(propertyVideos.toMap());
    }
  }

  Future<void> uploadImagesToDatabase(Property property) async {
    for (var imageFile in imageFiles) {
      String url = await FileManager().uploadPropertyPhoto(property, imageFile);

      imageUrls.add(url);
    }

    if (imageUrls.isNotEmpty) {
      PropertyImages propertyImages = PropertyImages(
        timestamp: DateTime.now().millisecondsSinceEpoch,
        imageUrls: imageUrls,
      );

      //save collection to firestore
      await FirebaseFirestore.instance
          .collection("properties")
          .doc(property.propertyID)
          .collection("images")
          .doc(propertyImages.timestamp.toString())
          .set(propertyImages.toMap());
    }
  }

  pickImages() async {
    setState(() {
      loading = true;
    });

    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: true);

    if (result != null) {
      for (var platformFile in result.files) {
        imageFiles.add(platformFile);
      }

      setState(() {
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  pickVideos() async {
    setState(() {
      loading = true;
    });

    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.video, allowMultiple: true);

    if (result != null) {
      for (var platformFile in result.files) {
        videoFiles.add(platformFile);
      }

      setState(() {
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  Widget addImageButton() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(width: 1.0, color: EKodi.themeColor)),
      child: TextButton.icon(
        onPressed: pickImages,
        icon: const Icon(Icons.image_outlined),
        label: const Text(
          "Add Image",
          style: TextStyle(color: EKodi.themeColor),
        ),
      ),
    );
  }

  Widget addVideoButton() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(width: 1.0, color: EKodi.themeColor)),
      child: TextButton.icon(
        onPressed: pickVideos,
        icon: const Icon(Icons.videocam_outlined),
        label: const Text(
          "Add Video",
          style: TextStyle(color: EKodi.themeColor),
        ),
      ),
    );
  }

  Widget displayVideos() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(videoFiles.length, (index) {
        PlatformFile video = videoFiles[index];

        return VideoCard(
          video: video,
          onPressed: () {
            setState(() {
              videoFiles.remove(video);
            });
          },
        );
      }),
    );
  }

  Widget displayImages() {
    return imageFiles.isNotEmpty
        ? RawScrollbar(
            controller: _controller,
            isAlwaysShown: true,
            radius: const Radius.circular(5.0),
            thumbColor: Colors.grey,
            scrollbarOrientation: ScrollbarOrientation.bottom,
            thickness: 10,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _controller,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(imageFiles.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Stack(
                          children: [
                            Image.memory(
                              imageFiles[index].bytes!,
                              height: 220.0,
                              width: 300.0,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 10.0,
                              right: 10.0,
                              child: CircleAvatar(
                                backgroundColor: Colors.black38,
                                radius: 20.0,
                                child: Center(
                                    child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      imageFiles.remove(imageFiles[index]);
                                    });
                                  },
                                  icon: const Icon(Icons.clear,
                                      color: Colors.white),
                                )),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Account account = context.watch<EKodi>().account;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isDesktop = sizeInfo.isDesktop;

        return loading
            ? const LoadingAnimation()
            : SingleChildScrollView(
                physics: isDesktop
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: isDesktop ? 40.0 : 20.0,
                    ),
                    //Container(width: size.width, height: 1.0,color: Colors.black,),
                    // const SizedBox(
                    //   height: 30.0,
                    // ),
                    Text("Add New Property",
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(
                      height: 10.0,
                    ),
                    displayImages(),
                    const SizedBox(
                      height: 10.0,
                    ),
                    displayVideos(),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      width: isDesktop ? size.width * 0.4 : size.width * 0.95,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white,
                        // boxShadow: const [
                        //   BoxShadow(
                        //       color: Colors.black12,
                        //       blurRadius: 2.0,
                        //       spreadRadius: 2.0,
                        //       offset: Offset(0.0, 0.0)
                        //   )
                        // ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              height: 20.0,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                addImageButton(),
                                const SizedBox(
                                  width: 10.0,
                                ),
                                addVideoButton()
                              ],
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            CustomTextField(
                              controller: name,
                              hintText: "Name",
                              //width:  size.width,
                              title: "Name of Property",
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: isDesktop
                                      ? size.width * 0.15
                                      : size.width * 0.35,
                                  child: CustomTextField(
                                    controller: country,
                                    hintText: "country",
                                    // width:isDesktop ? size.width*0.15 : size.width*0.35,
                                    title: "Country",
                                  ),
                                ),
                                SizedBox(
                                  width: isDesktop
                                      ? size.width * 0.15
                                      : size.width * 0.35,
                                  child: CustomTextField(
                                    controller: city,
                                    hintText: "city",
                                    // width:isDesktop ? size.width*0.15 : size.width*0.35,
                                    title: "City",
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: isDesktop
                                      ? size.width * 0.15
                                      : size.width * 0.35,
                                  child: CustomTextField(
                                    controller: town,
                                    hintText: "Town",
                                    // width:isDesktop ? size.width*0.15 : size.width*0.35,
                                    title: "Town",
                                  ),
                                ),
                                SizedBox(
                                  width: isDesktop
                                      ? size.width * 0.15
                                      : size.width * 0.35,
                                  child: CustomTextField(
                                    controller: address,
                                    hintText: "Physical Address",
                                    // width:isDesktop ? size.width*0.15 : size.width*0.35,
                                    title: "Physical Address",
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 5.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Is this property a multi-unit?",
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )),
                            const SizedBox(
                              height: 5.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 5.0),
                              child: DropdownSearch<String>(
                                  mode: Mode.MENU,
                                  showSelectedItems: true,
                                  items: const ["Yes", "No"],
                                  hint: "Is this property a multi-unit?",
                                  onChanged: (v) {
                                    setState(() {
                                      isMultiUnit = v == "Yes";
                                    });
                                    print(isMultiUnit);
                                  },
                                  selectedItem: "No"),
                            ),
                            isMultiUnit
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: isDesktop
                                                    ? size.width * 0.2
                                                    : size.width * 0.6,
                                                child: CustomTextField(
                                                  controller: unitName,
                                                  hintText: "Name",
                                                  // width: isDesktop ? size.width*0.2 : size.width*0.6,
                                                  title: "Unit Name",
                                                ),
                                              ),
                                              SizedBox(
                                                width: isDesktop
                                                    ? size.width * 0.2
                                                    : size.width * 0.6,
                                                child: CustomTextField(
                                                  controller: unitDesc,
                                                  hintText: "Description",
                                                  // width:isDesktop ? size.width*0.2 : size.width*0.6,
                                                  title: "Description",
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            width: 5.0,
                                          ),
                                          TextButton.icon(
                                            label: const Text(
                                              "Add",
                                              style: TextStyle(
                                                  color: EKodi.themeColor),
                                            ),
                                            icon: const Icon(Icons.add,
                                                color: EKodi.themeColor),
                                            onPressed: () async {
                                              if (unitName.text.isNotEmpty &&
                                                  unitDesc.text.isNotEmpty) {
                                                units.add(Unit(
                                                  name: unitName.text,
                                                  description: unitDesc.text,
                                                  unitID: DateTime.now()
                                                      .millisecondsSinceEpoch,
                                                  tenantInfo: {},
                                                  isOccupied: false,
                                                  rent: 0,
                                                  dueDate: 0,
                                                  propertyID: propertyID,
                                                  deposit: 0,
                                                  startDate: 0,
                                                  paymentFreq: "",
                                                  reminder: 0,
                                                  publisherID: account.userID,
                                                  isAccepted: false,
                                                ));

                                                setState(() {
                                                  unitName.clear();
                                                  unitDesc.clear();
                                                });
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Fill in the unit details");
                                              }
                                            },
                                          )
                                        ],
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: List.generate(units.length,
                                            (index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15.0),
                                            child: Card(
                                              elevation: 3.0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0)),
                                              child: ListTile(
                                                hoverColor:
                                                    Colors.grey.shade300,
                                                title: Text(units[index].name!),
                                                subtitle: Text(
                                                    units[index].description!),
                                                trailing: IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      units
                                                          .remove(units[index]);
                                                    });
                                                  },
                                                  icon: const Icon(
                                                    Icons.cancel_outlined,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      )
                                    ],
                                  )
                                : Container(),
                            CustomTextField(
                              controller: notes,
                              hintText: "Notes",
                              //width:  size.width,
                              title: "Notes",
                              inputType: TextInputType.multiline,
                            ),
                            Text(
                              "Price Range",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            CustomTextField(
                              controller: upperLimit,
                              hintText: "Upper Limit (KES)",
                              //width:  size.width,
                              title: "Upper Limit (KES)",
                              inputType: TextInputType.number,
                            ),
                            CustomTextField(
                              controller: lowerLimit,
                              hintText: "Lower Limit (KES)",
                              //width:  size.width,
                              title: "Lower Limit (KES)",
                              inputType: TextInputType.number,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: RaisedButton.icon(
                                  onPressed: savePropertyToDatabase,
                                  icon: const Icon(Icons.done_rounded,
                                      color: Colors.white),
                                  label: const Text(
                                    "Save",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: EKodi.themeColor),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }
}
