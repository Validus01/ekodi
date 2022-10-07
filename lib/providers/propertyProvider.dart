import 'package:flutter/material.dart';
import 'package:rekodi/model/property.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PropertyProvider with ChangeNotifier {

  Property? _selectedProperty;

  Property get selectedProperty => _selectedProperty!;

  setSelectedProperty(Property p) {
    _selectedProperty = p;

    notifyListeners();
  }

  updatePropertyDB() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String propertiesString = prefs.getString("properties") ?? "";

    List<Property> prefList = Property.decode(propertiesString);
  }
}