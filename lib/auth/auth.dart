import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/model/account.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:rekodi/providers/loader.dart';
import 'package:rekodi/widgets/customTextField.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../commonFunctions/fileManager.dart';
import '../config.dart';
import '../pages/otpScreen.dart';

class Authentication {
  performAuthentication(
      BuildContext context, String authType, bool isSignUp) async {
    if (isSignUp) {
      //New users
      switch (authType) {
        case "google":
          UserCredential userCredential;
          TextEditingController _name = TextEditingController();
          TextEditingController _phone = TextEditingController();

          if (kIsWeb) {
            userCredential = await webSignInWithGoogle();
          } else {
            userCredential = await nativeSignInWithGoogle();
          }

          //TODO: Display popup to take the remaining data
          await showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return ResponsiveBuilder(
                builder: (context, sizeInfo) {
                  Size size = MediaQuery.of(context).size;
                  bool isMobile = sizeInfo.isMobile;
                  bool isTablet = sizeInfo.isTablet;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile
                            ? 7.0
                            : isTablet
                                ? size.width * 0.1
                                : size.width * 0.25),
                    child: AlertDialog(
                      title: const Text('Continue with Google'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            CustomTextField(
                              controller: _name,
                              hintText: "Name",
                            ),
                            CustomTextField(
                              controller: _phone,
                              hintText: "Phone (+254)",
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        RaisedButton.icon(
                          color: Colors.red,
                          icon: const Icon(
                            Icons.done_rounded,
                            color: Colors.white,
                          ),
                          label: const Text('Proceed',
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            if (_name.text.isNotEmpty &&
                                _phone.text.isNotEmpty) {
                              context.read<Loader>().switchLoadingState(true);

                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );

          Account account = Account(
            name: _name.text.trim(),
            userID: userCredential.user!.uid,
            email: userCredential.user!.email,
            phone: _phone.text.trim(),
            idNumber: "",
            accountType: "",
            timestamp: DateTime.now().millisecondsSinceEpoch,
            photoUrl: userCredential.user!.photoURL ?? "",
            verified: false,
            verification: {
              "verified": false,
              "status": "unverified",
              "timestamp": DateTime.now().millisecondsSinceEpoch
            },
            deviceTokens: [],
          );

          String res = await saveUserInfoToFirestore(account);

          print(res + " 2");

          print(res + " 3");

          return res;

        case "apple":
          // do something else
          return "";

        case "facebook":
          // do something else
          return "";

        case "mail":
          TextEditingController _name = TextEditingController();
          TextEditingController _phone = TextEditingController();
          //TextEditingController _id = TextEditingController();
          TextEditingController _email = TextEditingController();
          TextEditingController _password = TextEditingController();
          TextEditingController _cPassword = TextEditingController();

          // TODO: Display popup
          await showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return ResponsiveBuilder(
                builder: (context, sizeInfo) {
                  Size size = MediaQuery.of(context).size;
                  bool isMobile = sizeInfo.isMobile;
                  bool isTablet = sizeInfo.isTablet;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile
                            ? 7.0
                            : isTablet
                                ? size.width * 0.1
                                : size.width * 0.25),
                    child: AlertDialog(
                      title: const Text('Continue with Email'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            CustomTextField(
                              controller: _name,
                              hintText: "Name",
                            ),
                            CustomTextField(
                              controller: _phone,
                              hintText: "Phone (+254)",
                            ),
                            // CustomTextField(
                            //   controller: _id,
                            //   hintText: "ID Number",
                            // ),
                            CustomTextField(
                              controller: _email,
                              hintText: "Email",
                            ),
                            CustomTextField(
                              controller: _password,
                              hintText: "Password",
                            ),
                            CustomTextField(
                              controller: _cPassword,
                              hintText: "Confirm Password",
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        RaisedButton.icon(
                          color: Colors.red,
                          icon: const Icon(
                            Icons.done_rounded,
                            color: Colors.white,
                          ),
                          label: const Text('Proceed',
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            if (_name.text.isNotEmpty &&
                                _phone.text.isNotEmpty &&
                                _email.text.isNotEmpty //&& _id.text.isNotEmpty
                                &&
                                _password.text.isNotEmpty &&
                                _cPassword.text.isNotEmpty &&
                                _password.text == _cPassword.text) {
                              context.read<Loader>().switchLoadingState(true);

                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );

          String res = await createUserWithEmail(
            name: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text.trim(),
            phone: _phone.text.trim(),
            accountType: "",
            //idNo: _id.text.trim()
          );

          return res;
      }
    } else {
      switch (authType) {
        case "google":
          UserCredential userCredential;

          if (kIsWeb) {
            userCredential = await webSignInWithGoogle();
          } else {
            userCredential = await nativeSignInWithGoogle();
          }
          String userID = userCredential.user!.uid;

          return "success+$userID";
        case "apple":
          // do something else
          return "";
        case "facebook":
          // do something else
          return "";
        case "mail":
          String res = await loginUserWithEmail();

          return res;
      }
    }
  }

  Future<String> saveUserInfoToFirestore(Account account) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(account.userID)
        .set(account.toMap());

    return "success+${account.userID}";
  }

  Future<String> loginUserWithEmail({String? email, String? password}) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email!,
        password: password!,
      );

      String userID = credential.user!.uid;

      return "success+$userID";
    } catch (e) {
      print(e.toString());

      return "failed";
    }
  }

  Future<String> createUserWithEmail(
      {String? name,
      String? idNumber,
      String? email,
      String? password,
      String? phone,
      String? accountType}) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email!,
        password: password!,
      );

      Account account = Account(
          name: name!,
          userID: credential.user!.uid,
          email: credential.user!.email,
          phone: phone!,
          idNumber: idNumber,
          accountType: accountType!,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          photoUrl: credential.user!.photoURL ?? "",
          verified: false,
          verification: {
            "verified": false,
            "status": "unverified",
            "timestamp": DateTime.now().millisecondsSinceEpoch
          },
          deviceTokens: []);

      String res = await saveUserInfoToFirestore(account);

      return res;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return "weak password";
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');

        return "user exists";
      } else {
        return "failed";
      }
    } catch (e) {
      print(e);
      return "failed";
    }
  }

  Future<String> verifyUserWithPhone(
    BuildContext context,
    bool isSignUp, {
    String? name,
    String? idNumber,
    String? email,
    String? password,
    String? phone,
    String? accountType,
    XFile? pickedFile,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    String result = "";

    await auth.verifyPhoneNumber(
      phoneNumber: phone!,
      timeout: const Duration(minutes: 3),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // ANDROID ONLY!

        UserCredential userCredential =
            await auth.signInWithCredential(credential);

        if (isSignUp) {
          await FirebaseFirestore.instance
              .collection("users")
              .where("idNumber", isEqualTo: idNumber)
              .get()
              .then((value) async {
            if (value.docs.isEmpty) {
              result = await createUserWithPhoneNative(context,
                  name: name,
                  idNumber: idNumber,
                  email: email,
                  password: password,
                  phone: phone,
                  accountType: accountType,
                  pickedFile: pickedFile,
                  userCredential: userCredential);
            } else {
              result = "User Already Exists!";
            }
          });
        } else {
          result = "success+${userCredential.user!.uid}";
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');

          result = 'The provided phone number is not valid.';
        }
        //  Handle other errors
        result = "Verification Failed.";
      },
      codeSent: (String verificationId, int? resendToken) async {
        String smsCode = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OTPScreen(
                      phoneNumber: phone,
                    )));

        if (smsCode != "cancelled") {
          PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verificationId, smsCode: smsCode);

          UserCredential userCredential =
              await auth.signInWithCredential(credential);

          if (isSignUp) {
            await FirebaseFirestore.instance
                .collection("users")
                .where("idNumber", isEqualTo: idNumber)
                .get()
                .then((value) async {
              if (value.docs.isEmpty) {
                result = await createUserWithPhoneNative(context,
                    name: name,
                    idNumber: idNumber,
                    email: email,
                    password: password,
                    phone: phone,
                    accountType: accountType,
                    pickedFile: pickedFile,
                    userCredential: userCredential);
              } else {
                result = "User Aready Exists!";
              }
            });
          } else {
            result = "success+${userCredential.user!.uid}";
          }
        } else {
          result = "Cancelled";
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // TODO Auto-resolution timed out...

        Fluttertoast.showToast(msg: "Timeout!");

        result = "Timeout!";
      },
    );

    return result;
  }

  Future<String> createUserWithPhoneNative(
    BuildContext context, {
    String? name,
    String? idNumber,
    String? email,
    String? password,
    String? phone,
    String? accountType,
    XFile? pickedFile,
    UserCredential? userCredential,
  }) async {
    String photoURL = "";

    if (pickedFile != null) {
      photoURL = await FileManager()
          .uploadProfilePhoto(userCredential!.user!.uid, pickedFile);
    }

    // get userID AND SAVE TO FIRESTORE
    Account account = Account(
        name: name,
        userID: userCredential!.user!.uid,
        email: email,
        phone: phone,
        idNumber: idNumber,
        accountType: accountType,
        photoUrl: photoURL,
        verified: false,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        verification: {
          "verified": false,
          "status": "unverified",
          "timestamp": DateTime.now().millisecondsSinceEpoch
        },
        deviceTokens: []);

    String result = await Authentication().saveUserInfoToFirestore(account);

    return result;
  }

  Future<String> createUserWithPhoneWeb(
    BuildContext context, {
    String? name,
    String? idNumber,
    String? email,
    String? password,
    String? phone,
    String? accountType,
    XFile? pickedFile,
  }) async {
    try {
      ConfirmationResult confirmationResult =
          await FirebaseAuth.instance.signInWithPhoneNumber(
        phone!,
        // RecaptchaVerifier(
        //   container: 'recaptcha',
        //   size: RecaptchaVerifierSize.compact,
        //   theme: RecaptchaVerifierTheme.light,
        //   // onSuccess: () => print('reCAPTCHA Completed!'),
        // onError: (FirebaseAuthException error) => print(error),
        // onExpired: () => print('reCAPTCHA Expired!'),
        // )
      );

      // update UI
      String smsCode = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OTPScreen(
                    phoneNumber: phone,
                  )));

      UserCredential userCredential = await confirmationResult.confirm(smsCode);

      String photoURL = "";

      if (pickedFile != null) {
        photoURL = await FileManager()
            .uploadProfilePhoto(userCredential.user!.uid, pickedFile);
      }

      // get userID AND SAVE TO FIRESTORE
      Account account = Account(
          name: name,
          userID: userCredential.user!.uid,
          email: email,
          phone: phone,
          idNumber: idNumber,
          accountType: accountType,
          photoUrl: photoURL,
          verified: false,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          verification: {
            "verified": false,
            "status": "unverified",
            "timestamp": DateTime.now().millisecondsSinceEpoch
          },
          deviceTokens: []);

      String res = await Authentication().saveUserInfoToFirestore(account);

      return res;
    } catch (e) {
      print(e);
      return "failed";
    }
  }

  Future<String> loginUserWithPhoneWeb(
    BuildContext context, {
    String? phone,
  }) async {
    try {
      ConfirmationResult confirmationResult =
          await FirebaseAuth.instance.signInWithPhoneNumber(
        phone!,
        // RecaptchaVerifier(
        //   container: 'recaptcha',
        //   size: RecaptchaVerifierSize.compact,
        //   theme: RecaptchaVerifierTheme.light,
        //   onSuccess: () => print('reCAPTCHA Completed!'),
        //   onError: (FirebaseAuthException error) => print(error),
        //   onExpired: () => print('reCAPTCHA Expired!'),
        // )
      );

      // update UI
      String smsCode = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OTPScreen(
                    phoneNumber: phone,
                  )));

      UserCredential userCredential = await confirmationResult.confirm(smsCode);

      String userID = userCredential.user!.uid;

      return "success+$userID";
    } catch (e) {
      print(e);
      return "failed";
    }
  }

  Future<UserCredential> nativeSignInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> webSignInWithGoogle() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    // googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
    // googleProvider.setCustomParameters({
    //   'login_hint': email!
    // });

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);

    // Or use signInWithRedirect
    // return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
  }
}
