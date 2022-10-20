import 'package:flutter/material.dart';
import 'package:rekodi/model/serviceProvider.dart';

import 'model/account.dart';

class EKodi with ChangeNotifier {
  Account? _account;
  ServiceProvider? _serviceProvider;
  final Color themeColor = Colors.pink; //Color.fromRGBO(232, 60, 74, 1);
  static String vapidKey =
      "BL7WNY4Es4QjhokvQjwt6aDCHkHfmOh-3fGstQXJM0aeDrOMw7HOScHU7Lco6gSaei4caiq9I5ye65aFuLmxH2c";
  // bool? _isServiceProvider;

  Account get account => _account!;
  ServiceProvider get serviceProvider => _serviceProvider!;
  // bool get isServiceProvider => _isServiceProvider!;

  switchUser(Account acc) {
    _account = acc;

    notifyListeners();
  }

  switchServiceProvider(ServiceProvider provider) {
    _serviceProvider = provider;

    notifyListeners();
  }

  // isProvider(bool isProvider) {
  //   _isServiceProvider = isProvider;
  //
  //   notifyListeners();
  // }
}
