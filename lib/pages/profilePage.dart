import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/main.dart';
import 'package:rekodi/model/account.dart';
import 'package:rekodi/widgets/customTextField.dart';
import 'package:rekodi/widgets/loadingAnimation.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../commonFunctions/fileManager.dart';
import '../config.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController idNumber = TextEditingController();
  String accountType = '';
  bool updating = false;
  XFile? pickedFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  getUserInfo() async {
    Account account = Provider.of<EKodi>(context, listen: false).account;

    setState(() {
      name.text = account.name!;
      email.text = account.email!;
      phone.text = account.phone!;
      accountType = account.accountType!;
      idNumber.text = account.idNumber!;
    });
  }

  updateAccountInfo(Account account) async {
    setState(() {
      updating = true;
    });

    if (pickedFile != null) {
      //upload image to storage
      String downloadUrl =
          await FileManager().uploadProfilePhoto(account.userID!, pickedFile!);

      Account newAccount = Account(
          name: name.text.trim(),
          userID: account.userID,
          photoUrl: downloadUrl,
          email: email.text.trim(),
          phone: phone.text.trim(),
          idNumber: idNumber.text.trim(),
          accountType: accountType,
          timestamp: account.timestamp,
          verified: account.verified,
          verification: account.verification,
          deviceTokens: account.deviceTokens);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(account.userID)
          .update(newAccount.toMap());

      setState(() {
        updating = false;
      });

      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const SplashScreen()));
    } else {
      Account newAccount = Account(
          name: name.text.trim(),
          userID: account.userID,
          photoUrl: account.photoUrl,
          email: email.text.trim(),
          phone: phone.text.trim(),
          idNumber: idNumber.text.trim(),
          accountType: accountType,
          timestamp: account.timestamp,
          verified: account.verified,
          verification: account.verification,
          deviceTokens: account.deviceTokens);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(account.userID)
          .update(newAccount.toMap());

      setState(() {
        updating = false;
      });

      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const SplashScreen()));
    }
  }

  // Future pickImageFromGallery() async {
  //   FilePickerResult? result =
  //       await FilePicker.platform.pickFiles(type: FileType.image);

  //   if (result != null) {
  //     setState(() {
  //       pickedFile = result.files.first;
  //     });
  //   } else {
  //     // User canceled the picker
  //   }
  // }

  Future pickImageFromCamera() async {
    final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);

    setState(() {
      pickedFile = photo;
    });
  }

  Widget displayUserProfile(
      BuildContext context, Account account, bool isMobile) {
    Size size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3.0),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 1,
              spreadRadius: 1.0,
              offset: Offset(0.0, 0.0))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50.0),
              child: account.photoUrl! == ""
                  ? Image.asset(
                      "assets/profile.png",
                      height: 100.0,
                      width: 100.0,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      account.photoUrl!,
                      height: 100.0,
                      width: 100.0,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name!,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 20.0),
                ),
                Text(
                  account.accountType!,
                  style: const TextStyle(fontSize: 15.0),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  displayPickedFile() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.0),
      child: kIsWeb
          ? Image.network(
              pickedFile!.path,
              height: 36.0,
              width: 36.0,
              fit: BoxFit.cover,
              errorBuilder: (context, obj, stacktrace) {
                return Text("Error");
              },
            )
          : Image.file(
              File(pickedFile!.path),
              height: 36.0,
              width: 36.0,
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _buildForMobile(Account account, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 10.0,
            ),
            displayUserProfile(context, account, true),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Container(
                width: size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.0),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 1,
                        spreadRadius: 1.0,
                        offset: Offset(0.0, 0.0))
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "About",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.person,
                          color: Colors.grey,
                        ),
                        title: Text(account.name!),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.email_outlined,
                          color: Colors.grey,
                        ),
                        title: Text(account.email!),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.phone,
                          color: Colors.grey,
                        ),
                        title: Text(account.phone!),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.switch_account,
                          color: Colors.grey,
                        ),
                        title: Text(account.accountType!),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Container(
                width: size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.0),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 1,
                        spreadRadius: 1.0,
                        offset: Offset(0.0, 0.0))
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Edit Profile",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ListTile(
                        leading: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18.0),
                              child: account.photoUrl! == ""
                                  ? Image.asset(
                                      "assets/profile.png",
                                      height: 36.0,
                                      width: 36.0,
                                    )
                                  : Image.network(
                                      account.photoUrl!,
                                      height: 36.0,
                                      width: 36.0,
                                    ),
                            ),
                            Positioned(
                              bottom: 0.0,
                              top: 0.0,
                              left: 0.0,
                              right: 0.0,
                              child: pickedFile != null
                                  ? displayPickedFile()
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(18.0),
                                      child: Image.asset(
                                        "assets/profile.png",
                                        height: 36.0,
                                        width: 36.0,
                                      ),
                                    ),
                            )
                          ],
                        ),
                        title: RaisedButton.icon(
                          elevation: 0.0,
                          hoverColor: Colors.transparent,
                          color: EKodi.themeColor,
                          icon: const Icon(
                            Icons.cloud_upload_outlined,
                            color: Colors.white,
                          ),
                          label: const Text("Upload Photo",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          onPressed: () => pickImageFromCamera(),
                        ),
                      ),
                      CustomTextField(
                        controller: name,
                        hintText: "Name",
                        // width: size.width,
                        title: "Your Name",
                        inputType: TextInputType.name,
                      ),
                      CustomTextField(
                        controller: email,
                        hintText: "Email",
                        // width: size.width,
                        title: "Email Address",
                        inputType: TextInputType.name,
                      ),
                      CustomTextField(
                        controller: phone,
                        hintText: "Phone",
                        // width: size.width,
                        title: "Phone Number",
                        inputType: TextInputType.name,
                      ),
                      CustomTextField(
                        controller: idNumber,
                        hintText: "ID Number",
                        // width: size.width,
                        title: "ID Number",
                        inputType: TextInputType.number,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text("Switch Account Type",
                            textAlign: TextAlign.start,
                            style: GoogleFonts.baloo2(
                              fontSize: 16.0,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 5.0),
                        child: DropdownSearch<String>(
                            mode: Mode.MENU,
                            showSelectedItems: true,
                            items: const [
                              "Landlord",
                              "Tenant",
                              "Agent",
                              //"Service Provider"
                            ],
                            hint: "Continue as...",
                            onChanged: (v) {
                              setState(() {
                                accountType = v!;
                              });
                            },
                            selectedItem: "Tenant"),
                      ),
                      RaisedButton.icon(
                        elevation: 0.0,
                        hoverColor: Colors.transparent,
                        color: EKodi.themeColor,
                        icon: Icon(
                          Icons.check,
                          color: updating ? Colors.white30 : Colors.white,
                        ),
                        label: Text(updating ? "Updating..." : "Save",
                            style: TextStyle(
                                color: updating ? Colors.white30 : Colors.white,
                                fontWeight: FontWeight.bold)),
                        onPressed: updating
                            ? () {}
                            : () {
                                if (name.text.isNotEmpty &&
                                    email.text.isNotEmpty &&
                                    phone.text.isNotEmpty) {
                                  updateAccountInfo(account);
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildForDesktop(Account account, Size size) {
    return Padding(
      padding: const EdgeInsets.only(right: 15.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10.0,
            ),
            Text(
              "Profile",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(
              height: 10.0,
            ),
            displayUserProfile(context, account, false),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    width: size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 1,
                            spreadRadius: 1.0,
                            offset: Offset(0.0, 0.0))
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "About",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.person,
                              color: Colors.grey,
                            ),
                            title: Text(account.name!),
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.email_outlined,
                              color: Colors.grey,
                            ),
                            title: Text(account.email!),
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.phone,
                              color: Colors.grey,
                            ),
                            title: Text(account.phone!),
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.switch_account,
                              color: Colors.grey,
                            ),
                            title: Text(account.accountType!),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    width: size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 1,
                            spreadRadius: 1.0,
                            offset: Offset(0.0, 0.0))
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Edit Profile",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ListTile(
                            leading: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(18.0),
                                  child: account.photoUrl! == ""
                                      ? Image.asset(
                                          "assets/profile.png",
                                          height: 36.0,
                                          width: 36.0,
                                        )
                                      : Image.network(
                                          account.photoUrl!,
                                          height: 36.0,
                                          width: 36.0,
                                        ),
                                ),
                                Positioned(
                                  bottom: 0.0,
                                  top: 0.0,
                                  left: 0.0,
                                  right: 0.0,
                                  child: pickedFile != null
                                      ? displayPickedFile()
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                          child: Image.asset(
                                            "assets/profile.png",
                                            height: 36.0,
                                            width: 36.0,
                                          ),
                                        ),
                                )
                              ],
                            ),
                            title: RaisedButton.icon(
                              elevation: 0.0,
                              hoverColor: Colors.transparent,
                              color: EKodi.themeColor,
                              icon: const Icon(
                                Icons.cloud_upload_outlined,
                                color: Colors.white,
                              ),
                              label: const Text("Upload Photo",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () => pickImageFromCamera(),
                            ),
                          ),
                          CustomTextField(
                            controller: name,
                            hintText: "Name",
                            // width: size.width,
                            title: "Your Name",
                            inputType: TextInputType.name,
                          ),
                          CustomTextField(
                            controller: email,
                            hintText: "Email",
                            // width: size.width,
                            title: "Email Address",
                            inputType: TextInputType.name,
                          ),
                          CustomTextField(
                            controller: phone,
                            hintText: "Phone",
                            // width: size.width,
                            title: "Phone Number",
                            inputType: TextInputType.name,
                          ),
                          CustomTextField(
                            controller: idNumber,
                            hintText: "ID Number",
                            // width: size.width,
                            title: "ID Number",
                            inputType: TextInputType.number,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text("Switch Account Type",
                                textAlign: TextAlign.start,
                                style: GoogleFonts.baloo2(
                                  fontSize: 16.0,
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 5.0),
                            child: DropdownSearch<String>(
                                mode: Mode.MENU,
                                showSelectedItems: true,
                                items: const [
                                  "Landlord",
                                  "Tenant",
                                  "Agent",
                                  "Service Provider"
                                ],
                                hint: "Continue as...",
                                onChanged: (v) {
                                  setState(() {
                                    accountType = v!;
                                  });
                                },
                                selectedItem: "Tenant"),
                          ),
                          RaisedButton.icon(
                            elevation: 0.0,
                            hoverColor: Colors.transparent,
                            color: EKodi.themeColor,
                            icon: Icon(
                              Icons.check,
                              color: updating ? Colors.white30 : Colors.white,
                            ),
                            label: Text(updating ? "Updating..." : "Save",
                                style: TextStyle(
                                    color: updating
                                        ? Colors.white30
                                        : Colors.white,
                                    fontWeight: FontWeight.bold)),
                            onPressed: updating
                                ? () {}
                                : () {
                                    if (name.text.isNotEmpty &&
                                        email.text.isNotEmpty &&
                                        phone.text.isNotEmpty) {
                                      updateAccountInfo(account);
                                    }
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 50.0,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    Size size = MediaQuery.of(context).size;

    return updating
        ? const LoadingAnimation()
        : ResponsiveBuilder(
            builder: (context, sizeInfo) {
              bool isMobile = sizeInfo.isMobile || sizeInfo.isTablet;
              return isMobile
                  ? _buildForMobile(account, size)
                  : _buildForDesktop(account, size);
            },
          );
  }
}
