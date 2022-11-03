import 'package:fluro/fluro.dart';
import 'package:rekodi/main.dart';
import 'package:rekodi/pages/authPage.dart';
import 'package:rekodi/pages/dashboards/dashboard.dart';
import 'package:rekodi/pages/landingPage/landingPage.dart';
import 'package:rekodi/pages/landingPage/postDetails.dart';
import 'package:rekodi/pages/landingPage/propertiesListing.dart';
import 'package:rekodi/pages/verification/verification.dart';

class CustomRoutes {
  static final FluroRouter router = FluroRouter();

  static Handler homeHandler =
      Handler(handlerFunc: (context, Map<String, dynamic> params) {
    return const LandingPage();
  });

  static Handler authHandler =
      Handler(handlerFunc: (context, Map<String, dynamic> params) {
    return const AuthPage();
  });

  static Handler verificationHandler =
      Handler(handlerFunc: (context, Map<String, dynamic> params) {
    return const Verification();
  });

  static Handler splashScreenHandler =
      Handler(handlerFunc: (context, Map<String, dynamic> params) {
    return const SplashScreen();
  });

  static Handler dashboardUserHandler =
      Handler(handlerFunc: (context, Map<String, dynamic> params) {
    return const Dashboard();
  });

  static Handler propertiesHandler =
      Handler(handlerFunc: (context, Map<String, dynamic> params) {
    return const PropertiesListing();
  });

  static Handler propertyDetailsHandler =
      Handler(handlerFunc: (context, Map<String, dynamic> params) {
    return PostDetails(
      propertyID: params["id"][0],
    );
  });

  static void setupRouter() {
    router.define("/authentication",
        handler: authHandler, transitionType: TransitionType.fadeIn);

    router.define("/",
        handler: splashScreenHandler, transitionType: TransitionType.fadeIn);

    router.define("/dashboard",
        handler: dashboardUserHandler, transitionType: TransitionType.fadeIn);

    router.define("/home",
        handler: homeHandler, transitionType: TransitionType.fadeIn);

    router.define("/verification",
        handler: verificationHandler, transitionType: TransitionType.fadeIn);

    router.define("/properties",
        handler: propertiesHandler, transitionType: TransitionType.fadeIn);

    router.define("/properties/:id",
        handler: propertyDetailsHandler, transitionType: TransitionType.fadeIn);
  }
}
