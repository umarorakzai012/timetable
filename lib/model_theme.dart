import 'package:flutter/material.dart';
import 'my_preference.dart';

class ModelTheme extends ChangeNotifier {
  late bool _isDark;
  late MyThemePreferences _preferences;
  bool get isDark => _isDark;

  List<Color> colorDark = [
    const Color.fromARGB(255, 90, 43, 219),
    const Color.fromARGB(255, 197, 47, 47),
  ];
  List<Color> colorLight = [
    const Color(0xFF6DE195),
    const Color(0xFFC4E759),
  ];

  ModelTheme() {
    _isDark = false;
    _preferences = MyThemePreferences();
    getPreferences();
  }
  
  void setDark(bool value) {
    _isDark = value;
    _preferences.setTheme(value);
    notifyListeners();
  }

  getPreferences() async {
    _isDark = await _preferences.getTheme();
    notifyListeners();
  }

  LinearGradient getGradient(){
    if(_isDark){
      return LinearGradient(colors: colorDark);
    } else {
      return LinearGradient(colors: colorLight);
    }
  }
}

  