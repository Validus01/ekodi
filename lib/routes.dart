import 'dart:js';

import 'package:fluro/fluro.dart';
import 'package:rekodi/main.dart';
import 'package:rekodi/pages/authPage.dart';
import 'package:rekodi/pages/dashboards/dashboard.dart';

class CustomRoutes {
  static final FluroRouter router = FluroRouter();

  static Handler authHandler =
      Handler(handlerFunc: (context, Map<String, dynamic> params) {
    return const AuthPage();
  });

  static Handler splashScreenHandler =
      Handler(handlerFunc: (context, Map<String, dynamic> params) {
    return const SplashScreen();
  });

  static Handler dashboardUserHandler =
      Handler(handlerFunc: (context, Map<String, dynamic> params) {
    return const Dashboard();
  });

  static void setupRouter() {
    router.define("/auth",
        handler: authHandler, transitionType: TransitionType.fadeIn);

    router.define("/authenticating",
        handler: splashScreenHandler, transitionType: TransitionType.fadeIn);

    router.define("/users/:id",
        handler: dashboardUserHandler, transitionType: TransitionType.fadeIn);
  }
}
