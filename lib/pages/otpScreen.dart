import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rekodi/config.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:responsive_framework/responsive_framework.dart';

class OTPScreen extends StatefulWidget {
  final String? phoneNumber;
  const OTPScreen({Key? key, this.phoneNumber}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  TextEditingController pin1 = TextEditingController();
  TextEditingController pin2 = TextEditingController();
  TextEditingController pin3 = TextEditingController();
  TextEditingController pin4 = TextEditingController();
  TextEditingController pin5 = TextEditingController();
  TextEditingController pin6 = TextEditingController();


  resendCode() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber!,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) {

      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0.0,
            centerTitle: true,
            title: const Text("Verify",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
            leading: IconButton(
              onPressed: () {Navigator.pop(context, "cancelled");},
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.black,),
            ),
          ),
          body: Center(
            child: ResponsiveWrapper(
                 child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10.0,),
                  const Text("Verification Code", style: TextStyle(fontWeight: FontWeight.bold),),
                  const SizedBox(height: 5.0,),
                  const Text("We have sent the code verification to ",),
                  const SizedBox(height: 5.0,),
                  Text(widget.phoneNumber!, style: const TextStyle(fontWeight: FontWeight.bold),),
                  const SizedBox(height: 10.0,),
                  Form(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: 68.0,
                          width: isMobile ? size.width*0.14 : 64.0,
                          child: TextFormField(
                            onChanged: (value) {
                              if(value.length == 1) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                            controller: pin1,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(Radius.circular(5)),
                                borderSide: BorderSide(width: 1,color:  EKodi().themeColor),
                              ),
                              border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  borderSide: BorderSide(width: 1,)
                              ),
                            ),
                            style: Theme.of(context).textTheme.headline6,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),

                        SizedBox(
                          height: 68.0,
                          width: isMobile ? size.width*0.14 : 64.0,
                          child: TextFormField(
                            onChanged: (value) {
                              if(value.length == 1) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                            controller: pin2,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(Radius.circular(5)),
                                borderSide: BorderSide(width: 1,color: EKodi().themeColor),
                              ),
                              border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  borderSide: BorderSide(width: 1,)
                              ),
                            ),
                            style: Theme.of(context).textTheme.headline6,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),

                        SizedBox(
                          height: 68.0,
                          width: isMobile ? size.width*0.14 : 64.0,
                          child: TextFormField(
                            onChanged: (value) {
                              if(value.length == 1) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                            controller: pin3,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(Radius.circular(5)),
                                borderSide: BorderSide(width: 1,color:  EKodi().themeColor),
                              ),
                              border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  borderSide: BorderSide(width: 1,)
                              ),
                            ),
                            style: Theme.of(context).textTheme.headline6,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),

                        SizedBox(
                          height: 68.0,
                          width: isMobile ? size.width*0.14 : 64.0,
                          child: TextFormField(
                            onChanged: (value) {
                              if(value.length == 1) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                            controller: pin4,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(Radius.circular(5)),
                                borderSide: BorderSide(width: 1,color:  EKodi().themeColor),
                              ),
                              border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  borderSide: BorderSide(width: 1,)
                              ),
                            ),
                            style: Theme.of(context).textTheme.headline6,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),

                        SizedBox(
                          height: 68.0,
                          width: isMobile ? size.width*0.14 : 64.0,
                          child: TextFormField(
                            onChanged: (value) {
                              if(value.length == 1) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                            controller: pin5,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(Radius.circular(5)),
                                borderSide: BorderSide(width: 1,color:  EKodi().themeColor),
                              ),
                              border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  borderSide: BorderSide(width: 1,)
                              ),
                            ),
                            style: Theme.of(context).textTheme.headline6,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),

                        SizedBox(
                          height: 68.0,
                          width: isMobile ? size.width*0.14 : 64.0,
                          child: TextFormField(
                            onChanged: (value) {
                              if(value.length == 1) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                            controller: pin6,
                            style: Theme.of(context).textTheme.headline6,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(Radius.circular(5)),
                                borderSide: BorderSide(width: 1,color:  EKodi().themeColor),
                              ),
                              border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  borderSide: BorderSide(width: 1,)
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {},//TODO
                          child: Container(
                            height: 35.0,
                            decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius
                                    .circular(
                                    5.0),
                                border: Border.all(
                                    color: EKodi().themeColor,
                                    width:
                                    1.0)),
                            child:
                            Padding(
                              padding: const EdgeInsets
                                  .symmetric(
                                  horizontal:
                                  5.0),
                              child: Center(
                                  child: Text(
                                    "Resend",
                                    style: TextStyle(
                                        color: EKodi().themeColor),
                                  )),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0,),
                      Expanded(
                        flex: 1,
                        child: RaisedButton(
                          onPressed: () {
                            if(pin1.text.isNotEmpty
                                && pin2.text.isNotEmpty
                                && pin3.text.isNotEmpty
                                && pin4.text.isNotEmpty
                                && pin5.text.isNotEmpty
                                && pin6.text.isNotEmpty)
                              {
                                String smsCode = pin1.text.trim()+pin2.text.trim()+pin3.text.trim()+pin4.text.trim()+pin5.text.trim()+pin6.text.trim();

                                Navigator.pop(context, smsCode);
                              }
                          },
                          elevation: 0.0,
                          color: EKodi().themeColor,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                                5.0),
                          ),
                          child: const Text("Confirm", style: TextStyle(color: Colors.white)),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
                maxWidth: 1000,
                minWidth: 480,
                defaultScale: true,
                breakpoints: const [
                    ResponsiveBreakpoint.resize(480, name: MOBILE),
                    ResponsiveBreakpoint.autoScale(800, name: TABLET),
                    ResponsiveBreakpoint.resize(1000, name: DESKTOP),
                    ResponsiveBreakpoint.autoScale(2460, name: '4K'),
                ],
            ),
          ),
        );
      },
    );
  }
}
