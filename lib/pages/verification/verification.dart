import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/model/account.dart';
import 'package:rekodi/model/verificationInfo.dart';
import 'package:rekodi/widgets/customButton.dart';
import 'package:rekodi/widgets/loadingAnimation.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../commonFunctions/fileManager.dart';
import '../../config.dart';
import '../../routes.dart';

class Verification extends StatefulWidget {
  const Verification({Key? key}) : super(key: key);

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  bool loading = false;
  int currentStep = 0;
  XFile? frontID;
  XFile? backID;

  Widget displayID(Size size, XFile image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5.0),
      child: kIsWeb
          ? Image.network(
              image.path,
              height: size.height * 0.3,
              width: size.width,
              fit: BoxFit.contain,
              errorBuilder: (context, obj, stacktrace) {
                return Text("Error");
              },
            )
          : Image.file(
              File(image.path),
              height: size.height * 0.3,
              width: size.width,
              fit: BoxFit.contain,
              errorBuilder: (context, obj, stacktrace) {
                return Text("Error");
              },
            ),
    );
  }

  List<Step> getSteps(Size size) {
    return <Step>[
      Step(
        state: currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 0,
        title: const Text("Identity Card Front View"),
        content: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Front View',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            frontID == null ? Container() : displayID(size, frontID!),
            CustomButton(
              title: "Capture ID",
              color: Colors.pink,
              onTap: () => takeImage(context, "front"),
            )
          ],
        ),
      ),
      Step(
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 1,
        title: const Text("Identity Card Rear View"),
        content: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Rear View',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            backID == null ? Container() : displayID(size, backID!),
            CustomButton(
              title: "Capture ID",
              color: Colors.pink,
              onTap: () => takeImage(context, "rear"),
            )
          ],
        ),
      ),
      // Step(
      //   state: currentStep > 2 ? StepState.complete : StepState.indexed,
      //   isActive: currentStep >= 2,
      //   title: Text("Payment"),
      //   content: Column(
      //     children: [
      //       Padding(
      //         padding: EdgeInsets.all(20.0),
      //         child: Text(
      //           'Payment Details',
      //           style: TextStyle(
      //             fontSize: 25.0,
      //             fontWeight: FontWeight.w700,
      //           ),
      //         ),
      //       ),
      //       CustomInput(
      //         hint: "Card number",
      //       ),
      //       CustomInput(
      //         hint: "Expiry date",
      //       ),
      //       CustomInput(
      //         hint: "CVV",
      //       ),
      //     ],
      //   ),
      // ),
    ];
  }

  Future pickImage(
      BuildContext context, String view, ImageSource imageSource) async {
    //Navigator.pop(context);

    final XFile? photo = await FileManager().pickPhoto(
      context: context,
      imageSource: imageSource,
      cameraDevice: CameraDevice.front,
    );

    if (view == "front") {
      setState(() {
        frontID = photo;
      });
    } else {
      setState(() {
        backID = photo;
      });
    }
  }

  takeImage(BuildContext context, String view) {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text(
            "Upload Image",
          ),
          children: <Widget>[
            SimpleDialogOption(
              child: const Text("Capture Image with Camera"),
              onPressed: () {
                pickImage(context, view, ImageSource.camera);

                Navigator.pop(context);
              },
            ),
            SimpleDialogOption(
              child: const Text(
                "Select Image from Gallery",
              ),
              onPressed: () {
                pickImage(context, view, ImageSource.gallery);

                Navigator.pop(context);
              },
            ),
            SimpleDialogOption(
              child: const Text(
                "Cancel",
              ),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  uploadIDsAndSavetoFirestore(Account account) async {
    try {
      setState(() {
        loading = true;
      });

      // Upload front view
      String frontTimestamp = DateTime.now().microsecondsSinceEpoch.toString();

      String frontIDUrl = await FileManager()
          .uploadIDPhoto(account.userID!, "frontID_$frontTimestamp", frontID!);

      // Upload rear view

      String backTimestamp = DateTime.now().microsecondsSinceEpoch.toString();

      String backIDUrl = await FileManager()
          .uploadIDPhoto(account.userID!, "backID_$backTimestamp", backID!);

      // upload info to database

      VerificationInfo frontInfo = VerificationInfo(
        id: "frontID_$frontTimestamp",
        view: "front",
        timestamp: frontTimestamp,
        url: frontIDUrl,
      );

      VerificationInfo backInfo = VerificationInfo(
        id: "backID_$backTimestamp",
        view: "back",
        timestamp: backTimestamp,
        url: backIDUrl,
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(account.userID)
          .collection("verification")
          .doc(frontInfo.id)
          .set(frontInfo.toMap());

      await FirebaseFirestore.instance
          .collection("users")
          .doc(account.userID)
          .collection("verification")
          .doc(backInfo.id)
          .set(backInfo.toMap());

      // Update verification status on user

      await FirebaseFirestore.instance
          .collection("users")
          .doc(account.userID)
          .update({
        "verification": {
          "verified": false,
          "status": "pending",
          "timestamp": DateTime.now().millisecondsSinceEpoch
        }
      });

      Fluttertoast.showToast(msg: "Details sent successfully!");

      CustomRoutes.router.navigateTo(context, "/");

      setState(() {
        loading = false;
      });
    } catch (e) {
      print(e.toString());

      setState(() {
        loading = false;
      });

      Fluttertoast.showToast(msg: "An Error ocuured. Try again");
    }
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.pink.shade100,
        leading: IconButton(
          onPressed: () {
            CustomRoutes.router.navigateTo(context, "/dashboard");
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.pink,
          ),
        ),
        title: const Text(
          "Verification",
          style: TextStyle(color: Colors.pink),
        ),
      ),
      body: loading
          ? const LoadingAnimation()
          : ResponsiveWrapper(
              maxWidth: 800,
              minWidth: 480,
              defaultScale: true,
              breakpoints: const [
                ResponsiveBreakpoint.resize(480, name: MOBILE),
                ResponsiveBreakpoint.autoScale(800, name: TABLET),
                ResponsiveBreakpoint.resize(1000, name: DESKTOP),
                ResponsiveBreakpoint.autoScale(2460, name: '4K'),
              ],
              child: Container(
                  padding: const EdgeInsets.all(15),
                  child: Stepper(
                    elevation: 0.0,
                    physics: const BouncingScrollPhysics(),
                    type: StepperType.vertical,
                    currentStep: currentStep,
                    onStepCancel: () => currentStep == 0
                        ? null
                        : setState(() {
                            currentStep -= 1;
                          }),
                    onStepContinue: () {
                      bool isLastStep =
                          (currentStep == getSteps(size).length - 1);
                      if (isLastStep) {
                        //Do something with this information
                        if (frontID != null && backID != null) {
                          uploadIDsAndSavetoFirestore(account);
                        } else {
                          Fluttertoast.showToast(
                              msg: "Please upload your ID Card photos");
                        }
                      } else {
                        setState(() {
                          currentStep += 1;
                        });
                      }
                    },
                    onStepTapped: (step) => setState(() {
                      currentStep = step;
                    }),
                    steps: getSteps(size),
                  )),
            ),
    );
  }
}
