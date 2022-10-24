import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/config.dart';
import 'package:rekodi/model/account.dart';
import 'package:rekodi/pages/landingPage/widgets/staticAppbar.dart';
import 'package:rekodi/providers/loader.dart';
import 'package:rekodi/widgets/loadingAnimation.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../auth/auth.dart';
import '../dialog/errorDialog.dart';
import '../routes.dart';
import '../widgets/customTextField.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isSignUp = false;
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController cPassword = TextEditingController();
  TextEditingController idNumber = TextEditingController();
  String accountType = 'Tenant';
  bool showPassword = true;
  bool showCPassword = true;
  PlatformFile? pickedFile;
  //FirebaseAuth auth = FirebaseAuth.instance;

  double getWidth(Size size, SizingInformation sizeInfo) {
    if (sizeInfo.isMobile) {
      return 20.0;
    } else if (sizeInfo.isTablet) {
      return size.width * 0.2;
    } else {
      return size.width * 0.3;
    }
  }

  void handleAuth(BuildContext context) async {
    await context.read<Loader>().switchLoadingState(true);

    if (kIsWeb) {
      String res = "";

      if (isSignUp) {
        res = await Authentication().createUserWithPhoneWeb(context,
            name: name.text.trim(),
            idNumber: idNumber.text.trim(),
            email: email.text.trim(),
            password: password.text.trim(),
            phone: phone.text.trim(),
            accountType: accountType,
            pickedFile: pickedFile);
      } else {
        res = await Authentication()
            .loginUserWithPhoneWeb(context, phone: phone.text.trim());
      }

      if (res.split("+").first == "success") {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(res.split("+").last)
            .get()
            .then((value) {
          Account account = Account.fromDocument(value);

          context.read<EKodi>().switchUser(account);
        });

        CustomRoutes.router.navigateTo(context, "/dashboard");

        await context.read<Loader>().switchLoadingState(false);
      } else {
        showDialog<void>(
          context: context,
          barrierDismissible: true,
          // false = user must tap button, true = tap outside dialog
          builder: (BuildContext dialogContext) {
            return ErrorAlertDialog(
              message: "Error: $res",
            );
          },
        );

        await context.read<Loader>().switchLoadingState(false);
      }
    } else {
      // Native platforms Android, iOS

      String res = await Authentication().verifyUserWithPhone(context, isSignUp,
          name: name.text.trim(),
          idNumber: idNumber.text.trim(),
          email: email.text.trim(),
          password: password.text.trim(),
          phone: phone.text.trim(),
          accountType: accountType,
          pickedFile: pickedFile);

      if (res.split("+").first == "success") {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(res.split("+").last)
            .get()
            .then((value) {
          Account account = Account.fromDocument(value);

          context.read<EKodi>().switchUser(account);
        });

        CustomRoutes.router.navigateTo(context, "/dashboard");

        await context.read<Loader>().switchLoadingState(false);
      } else {
        showDialog<void>(
          context: context,
          barrierDismissible: true,
          // false = user must tap button, true = tap outside dialog
          builder: (BuildContext dialogContext) {
            return ErrorAlertDialog(
              message: "Error: $res",
            );
          },
        );

        await context.read<Loader>().switchLoadingState(false);
      }
    }

    // String res = "";

    // if (isSignUp) {
    //   res = await Authentication().createUserWithEmail(
    //     name: name.text.trim(),
    //     email: email.text.trim(),
    //     password: password.text.trim(),
    //     phone: phone.text.trim(),
    //     accountType: accountType,
    //     idNumber: idNumber.text.trim()
    //   );
    // } else {
    //   res = await Authentication().loginUserWithEmail(
    //     email: email.text.trim(),
    //     password: password.text.trim(),
    //   );
    // }

    // String verificationResult = "";//await Navigator.push(context, MaterialPageRoute(builder: (context)=> const VerifyEmailPage()));

    // await context.read<Loader>().switchLoadingState(false);

    // if (res.split("+").first == "success") {
    //   await FirebaseFirestore.instance
    //       .collection("users")
    //       .doc(res.split("+").last)
    //       .get()
    //       .then((value) {
    //     Account account = Account.fromDocument(value);

    //     context.read<EKodi>().switchUser(account);
    //   });

    //   Route route = MaterialPageRoute(builder: (context) => const Dashboard());

    //   Navigator.pushReplacement(context, route);
    // } else if(verificationResult == "unverified") {
    //   showDialog<void>(
    //     context: context,
    //     barrierDismissible: true,
    //     // false = user must tap button, true = tap outside dialog
    //     builder: (BuildContext dialogContext) {
    //       return const ErrorAlertDialog(
    //         message: "Error: Your email is unverified",
    //       );
    //     },
    //   );
    // } else {
    //   showDialog<void>(
    //     context: context,
    //     barrierDismissible: true,
    //     // false = user must tap button, true = tap outside dialog
    //     builder: (BuildContext dialogContext) {
    //       return ErrorAlertDialog(
    //         message: "Error: $res",
    //       );
    //     },
    //   );
    // }
  }

  Future pickImageFromGallery() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        pickedFile = result.files.first;
      });
    } else {
      // User canceled the picker
    }
  }

  displayPickedFile() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50.0),
      child: Image.memory(
        pickedFile!.bytes!,
        height: 100.0,
        width: 100.0,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool loading = context.watch<Loader>().loading;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile;

        return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size(size.width, 100.0),
              child: const StaticAppBar(
                isShrink: true,
                isAuth: true,
              ),
            ),
            body: loading
                ? const LoadingAnimation()
                : Stack(
                    children: [
                      SizedBox(
                        height: size.height,
                        width: size.width,
                      ),
                      Positioned(
                        top: 0.0,
                        left: 0.0,
                        child: Image.asset("assets/images/baner_dec_left.png"),
                      ),
                      Positioned(
                        top: 0.0,
                        right: 0.0,
                        child: Image.asset("assets/images/baner_dec_right.png"),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: getWidth(size, sizeInfo)),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                      "Welcome to JVALUE Property Management Software",
                                      textAlign: TextAlign.center,
                                      maxLines: null,
                                      style: GoogleFonts.baloo2(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 22.0,
                                      )),
                                ),
                                Text(isSignUp ? "Create Account" : "Log In",
                                    style: GoogleFonts.baloo2(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22.0,
                                    )),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: isSignUp
                                      ? [
                                          Stack(
                                            children: [
                                              pickedFile != null
                                                  ? displayPickedFile()
                                                  : CircleAvatar(
                                                      radius: 50.0,
                                                      backgroundColor: EKodi()
                                                          .themeColor
                                                          .withOpacity(0.1),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50.0),
                                                        child: Image.asset(
                                                          "assets/profile.png",
                                                          height: 100.0,
                                                          width: 100.0,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                              Positioned(
                                                bottom: 0.0,
                                                right: 0.0,
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0)),
                                                  child: CircleAvatar(
                                                    backgroundColor: Theme.of(
                                                            context)
                                                        .scaffoldBackgroundColor,
                                                    child: IconButton(
                                                      hoverColor:
                                                          Colors.transparent,
                                                      onPressed: () =>
                                                          pickImageFromGallery(),
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                          AuthTextField(
                                            controller: name,
                                            prefixIcon: const Icon(
                                              Icons.person,
                                              color: Colors.grey,
                                            ),
                                            hintText: "Full Name",
                                            isObscure: false,
                                            inputType: TextInputType.name,
                                          ),
                                          AuthTextField(
                                            controller: phone,
                                            prefixIcon: const Icon(
                                              Icons.phone,
                                              color: Colors.grey,
                                            ),
                                            hintText: "Phone (+2547...)",
                                            isObscure: false,
                                            inputType: TextInputType.phone,
                                          ),
                                          AuthTextField(
                                            controller: idNumber,
                                            prefixIcon: const Icon(
                                              Icons.badge_outlined,
                                              color: Colors.grey,
                                            ),
                                            hintText: "ID Number",
                                            isObscure: false,
                                            inputType: TextInputType.number,
                                          ),
                                          AuthTextField(
                                            controller: email,
                                            prefixIcon: const Icon(
                                              Icons.email_outlined,
                                              color: Colors.grey,
                                            ),
                                            hintText: "Email Address",
                                            isObscure: false,
                                            inputType:
                                                TextInputType.emailAddress,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Text("Continue as...",
                                                textAlign: TextAlign.start,
                                                style: GoogleFonts.baloo2(
                                                  fontSize: 16.0,
                                                )),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                                vertical: 5.0),
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
                                          AuthTextField(
                                            controller: password,
                                            prefixIcon: const Icon(
                                              Icons.lock_outline_rounded,
                                              color: Colors.grey,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: showPassword
                                                  ? const Icon(Icons
                                                      .visibility_off_outlined)
                                                  : const Icon(
                                                      Icons.visibility),
                                              onPressed: showPassword
                                                  ? () {
                                                      setState(() =>
                                                          showPassword = false);
                                                    }
                                                  : () {
                                                      setState(() =>
                                                          showPassword = true);
                                                    },
                                            ),
                                            hintText: "Password",
                                            isObscure: showPassword,
                                            inputType:
                                                TextInputType.visiblePassword,
                                          ),
                                          AuthTextField(
                                            controller: cPassword,
                                            prefixIcon: const Icon(
                                              Icons.lock_outline_rounded,
                                              color: Colors.grey,
                                            ),
                                            hintText: "Confirm Password",
                                            isObscure: showCPassword,
                                            inputType:
                                                TextInputType.visiblePassword,
                                            suffixIcon: IconButton(
                                              icon: showCPassword
                                                  ? const Icon(Icons
                                                      .visibility_off_outlined)
                                                  : const Icon(
                                                      Icons.visibility),
                                              onPressed: showCPassword
                                                  ? () {
                                                      setState(() =>
                                                          showCPassword =
                                                              false);
                                                    }
                                                  : () {
                                                      setState(() =>
                                                          showCPassword = true);
                                                    },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: RaisedButton.icon(
                                              onPressed: () async {
                                                if (name.text.isNotEmpty &&
                                                    phone.text.isNotEmpty &&
                                                    idNumber.text.isNotEmpty &&
                                                    email.text.isNotEmpty &&
                                                    password.text.isNotEmpty &&
                                                    password.text.trim() ==
                                                        cPassword.text.trim() &&
                                                    cPassword.text.isNotEmpty) {
                                                  FirebaseFirestore.instance
                                                      .collection("users")
                                                      .where("idNumber",
                                                          isEqualTo: idNumber
                                                              .text.isNotEmpty)
                                                      .get()
                                                      .then((querySnapshot) {
                                                    if (querySnapshot
                                                        .docs.isEmpty) {
                                                      handleAuth(context);
                                                    } else {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "User Already Exists!");
                                                    }
                                                  });
                                                }
                                              },
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              elevation: 5.0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0)),
                                              label: Text("Create",
                                                  style: GoogleFonts.baloo2(
                                                      color: Colors.white)),
                                              icon: const Icon(
                                                Icons.done,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                    "Already have an Account? ",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.baloo2(
                                                      fontSize: 16.0,
                                                    )),
                                                const SizedBox(
                                                  width: 5.0,
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      isSignUp = false;
                                                      name.clear();
                                                      phone.clear();
                                                      email.clear();
                                                      password.clear();
                                                      cPassword.clear();
                                                    });
                                                  },
                                                  child: Text("Log In",
                                                      style: GoogleFonts.baloo2(
                                                          color: Colors.pink)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]
                                      : [
                                          AuthTextField(
                                            controller: phone,
                                            prefixIcon: const Icon(
                                              Icons.phone,
                                              color: Colors.grey,
                                            ),
                                            hintText: "Phone (+2547...)",
                                            isObscure: false,
                                            inputType: TextInputType.phone,
                                          ),
                                          AuthTextField(
                                            controller: password,
                                            prefixIcon: const Icon(
                                              Icons.lock_open,
                                              color: Colors.grey,
                                            ),
                                            hintText: "Password",
                                            isObscure: showPassword,
                                            inputType:
                                                TextInputType.visiblePassword,
                                            suffixIcon: IconButton(
                                              icon: showPassword
                                                  ? const Icon(Icons.visibility)
                                                  : const Icon(Icons
                                                      .visibility_off_outlined),
                                              onPressed: showPassword
                                                  ? () {
                                                      setState(() =>
                                                          showPassword = false);
                                                    }
                                                  : () {
                                                      setState(() =>
                                                          showPassword = true);
                                                    },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: RaisedButton.icon(
                                              onPressed: () {
                                                if (phone.text.isNotEmpty &&
                                                    password.text.isNotEmpty) {
                                                  handleAuth(context);
                                                }
                                              },
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              elevation: 5.0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0)),
                                              label: Text("Login",
                                                  style: GoogleFonts.baloo2(
                                                      color: Colors.white)),
                                              icon: const Icon(
                                                Icons.done,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text("Don't have an Account? ",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.baloo2(
                                                      fontSize: 16.0,
                                                    )),
                                                const SizedBox(
                                                  width: 5.0,
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      isSignUp = true;
                                                      phone.clear();
                                                      password.clear();
                                                    });
                                                  },
                                                  child: Text("Create Account",
                                                      style: GoogleFonts.baloo2(
                                                          color: Colors.pink)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ));
      },
    );
  }
}
