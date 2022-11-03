import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/commonFunctions/fileManager.dart';
import 'package:rekodi/model/propertyImagesModel.dart';
import 'package:rekodi/widgets/loadingAnimation.dart';

import '../config.dart';
import '../model/account.dart';
import '../model/property.dart';
import '../providers/propertyProvider.dart';
import '../providers/tabProvider.dart';

class PropertyImagesPage extends StatefulWidget {
  const PropertyImagesPage({Key? key}) : super(key: key);

  @override
  State<PropertyImagesPage> createState() => _PropertyImagesPageState();
}

class _PropertyImagesPageState extends State<PropertyImagesPage> {
  bool loading = false;

  pickImagesAndUpload(Property property) async {
    setState(() {
      loading = true;
    });

    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: true);

    if (result != null) {
      List<String> imageUrls = [];
      //Upload the images
      for (var platformFile in result.files) {
        String url =
            await FileManager().uploadPropertyPhoto(property, platformFile);

        imageUrls.add(url);
      }

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

      setState(() {
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    Size size = MediaQuery.of(context).size;
    Property property = context.watch<PropertyProvider>().selectedProperty;

    return loading
        ? const LoadingAnimation()
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20.0,
              ),
              TextButton.icon(
                onPressed: () =>
                    context.read<TabProvider>().changeTab("PropertyDetails"),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.grey,
                ),
                label: const Text(
                  "Back",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Property Images",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  RaisedButton.icon(
                    onPressed: () => pickImagesAndUpload(property),
                    icon: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Colors.white,
                    ),
                    color: EKodi.themeColor,
                    label: const Text(
                      "Upload Photos",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              FutureBuilder<QuerySnapshot>(
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
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.photo_library_outlined,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            const Text(
                              "No images",
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            RaisedButton.icon(
                              onPressed: () => pickImagesAndUpload(property),
                              icon: const Icon(
                                Icons.add_photo_alternate_outlined,
                                color: Colors.white,
                              ),
                              color: EKodi.themeColor,
                              label: const Text(
                                "Upload Photos",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      );
                    } else {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            List.generate(imagesCollection.length, (index) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateFormat("dd MMM").format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      imagesCollection[index].timestamp!))),
                              const SizedBox(
                                height: 10.0,
                              ),
                              GridView.count(
                                crossAxisCount: 2,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio: size.width * 0.5 / 300.0,
                                shrinkWrap: true,
                                children: List.generate(
                                    imagesCollection[index].imageUrls!.length,
                                    (imageIndex) {
                                  return Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.network(
                                        imagesCollection[index]
                                            .imageUrls![imageIndex],
                                        width: size.width,
                                        height: 300.0,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          );
                        }),
                      );
                    }
                  }
                },
              )
            ],
          );
  }
}
