import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({Key? key}) : super(key: key);

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if(!isEmailVerified) // send verification email
      {
        sendVerificationEmail();

        timer = Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
    }
  }

  Future sendVerificationEmail() async {
    try {

      User user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() {
        canResendEmail = false;
      });

      await Future.delayed(const Duration(seconds: 5));

      setState(() {
        canResendEmail = true;
      });

    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified =  FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if(isEmailVerified) timer?.cancel();

    Navigator.pop(context, "verified");
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/images/about-left-image.png", width: 100.0, height: 100.0, fit: BoxFit.contain,),
            const SizedBox(height: 10.0,),
            const Text("Verifying your email...", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),),
            const Text("A verification email has been sent to your email address",textAlign: TextAlign.center, style: TextStyle( color: Colors.grey),),
            const SizedBox(height: 10.0,),
            RaisedButton.icon(
              color: Colors.teal,
              onPressed: canResendEmail ? sendVerificationEmail : null,
              icon: const Icon(Icons.email_outlined, color: Colors.white),
              label: const Text("Resend Email", style: TextStyle( color: Colors.white),),
            ),
            const SizedBox(height: 5.0,),
            TextButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50.0)
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                Navigator.pop(context, "unverified");
              },
              child: const Text("Cancel", style: TextStyle( color: Colors.teal)),
            )
          ],
        ),
      ),
    );
  }
}
