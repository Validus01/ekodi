import 'dart:js';

import 'package:fluro/fluro.dart';
import 'package:rekodi/pages/authPage.dart';

class CustomRoutes {
  static final FluroRouter router = FluroRouter();

  static Handler authHandler = Handler(handlerFunc: (context, Map<String, dynamic> params) {
    return const AuthPage();
  });


  static void setupRouter() {
    router.define("/auth", handler: authHandler, transitionType: TransitionType.fadeIn);
  }
}