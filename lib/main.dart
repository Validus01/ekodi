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
import 'routes.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    CustomRoutes.setupRouter();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JVALUE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      initialRoute: "/",
      onGenerateRoute: CustomRoutes.router.generator,
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
          CustomRoutes.router.navigateTo(context, "/authentication");
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

          CustomRoutes.router.navigateTo(context, "/dashboard");
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
        child: Image.asset(
          "assets/logo.png",
          height: 300.0,
          width: 300.0,
          fit: BoxFit.contain,
        ),
        ),
      );
  }
}
