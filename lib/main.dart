import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/chat/chatProvider/chatProvider.dart';
import 'package:rekodi/config.dart';
import 'package:rekodi/model/account.dart';
import 'package:rekodi/pages/authPage.dart';
import 'package:rekodi/pages/dashboards/dashboard.dart';
import 'package:rekodi/pages/home.dart';
import 'package:rekodi/providers/accountingProvider.dart';
import 'package:rekodi/providers/datePeriod.dart';
import 'package:rekodi/providers/loader.dart';
import 'package:rekodi/providers/messageProvider.dart';
import 'package:rekodi/providers/propertyProvider.dart';
import 'package:rekodi/providers/tabProvider.dart';
import 'package:rekodi/providers/tenantProvider.dart';
import 'package:rekodi/providers/transactionProvider.dart';
import 'package:url_strategy/url_strategy.dart';

// Import the generated file
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setPathUrlStrategy();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<EKodi>(
        create: (_) => EKodi(),
      ),
      ChangeNotifierProvider<Loader>(create: (_) => Loader()),
      ChangeNotifierProvider<DatePeriodProvider>(
          create: (_) => DatePeriodProvider()),
      ChangeNotifierProvider<ChatProvider>(create: (_) => ChatProvider()),
      ChangeNotifierProvider<MessageProvider>(create: (_) => MessageProvider()),
      ChangeNotifierProvider<PropertyProvider>(
          create: (_) => PropertyProvider()),
      ChangeNotifierProvider<TenantProvider>(create: (_) => TenantProvider()),
      ChangeNotifierProvider<TransactionProvider>(
          create: (_) => TransactionProvider()),
      ChangeNotifierProvider<TabProvider>(create: (_) => TabProvider()),
      ChangeNotifierProvider<AccountingProvider>(
          create: (_) => AccountingProvider())
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'e-KODI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    displaySplash();
  }

  displaySplash() async {
    Timer(const Duration(seconds: 3), () async {
      auth.authStateChanges().listen((User? user) async {
        if (user == null) {
          Route route =
              MaterialPageRoute(builder: (context) => const AuthPage());
          Navigator.pushReplacement(context, route);
        } else {
          final user = FirebaseAuth.instance.currentUser;

          await FirebaseFirestore.instance
              .collection("users")
              .doc(user!.uid)
              .get()
              .then((value) {
            Account account = Account.fromDocument(value);

            context.read<EKodi>().switchUser(account);
          });

          print(user.uid);

          Route route =
              MaterialPageRoute(builder: (context) => const Dashboard());

          Navigator.pushReplacement(context, route);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Center(
        child: RichText(
          text: TextSpan(
            //style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(
                  text: 'e-',
                  style:
                      GoogleFonts.titanOne(color: Colors.blue, fontSize: 20.0)),
              TextSpan(
                  text: 'KODI',
                  style:
                      GoogleFonts.titanOne(color: Colors.red, fontSize: 20.0)),
            ],
          ),
        ),
      ),
    );
  }
}
