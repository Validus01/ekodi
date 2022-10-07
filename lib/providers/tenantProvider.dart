import 'package:flutter/material.dart';
import 'package:rekodi/model/account.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TenantProvider with ChangeNotifier {



  updateTenantsDB(Account account, Account newTenant) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String tenantsString = prefs.getString("${account.userID}_tenants") ?? "";

    List<Account> tenants = Account.decode(tenantsString);

    tenants.add(newTenant);

    final String encodedData = Account.encode(tenants);

    await prefs.setString("${account.userID}_tenants", encodedData);

    notifyListeners();
  }

  Future<List<Account>> getTenants(Account account) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String tenantsString = prefs.getString("${account.userID}_tenants") ?? "";

    List<Account> tenants = Account.decode(tenantsString);

    return tenants;
  }

}