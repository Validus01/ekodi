import 'package:flutter/material.dart';

class TabProvider with ChangeNotifier {
  String _currentTab = "Dashboard";

  String get currentTab => _currentTab;

  changeTab(String tab) {
    _currentTab = tab;

    notifyListeners();
  }
}