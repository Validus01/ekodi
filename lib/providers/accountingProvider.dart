import 'package:flutter/material.dart';


class AccountingProvider with ChangeNotifier {
  bool _showAddRent = false;
  bool _showInvoicing = false;
  int _expense = 0;
  int _income = 0;

  bool get showAddRent => _showAddRent;
  bool get showInvoicing => _showInvoicing;
  int get expense => _expense;
  int get income => _income;

  changeToAddRent(bool value) {
    _showAddRent = value;

    notifyListeners();
  }

  setExpense(int v) {
    _expense = v;

    notifyListeners();
  }

  setIncome(int v) {
    _income = v;

    notifyListeners();
  }

  changeToInvoicing(bool value) {
    _showInvoicing =  value;

    notifyListeners();
  }

}