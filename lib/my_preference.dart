import 'package:shared_preferences/shared_preferences.dart';

class MyThemePreferences {
  static const themeKey = "theme_key";

  setTheme(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(themeKey, value);
  }

  getTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(themeKey) ?? false;
  }
}

class MySelectionPreferences {
  static const selectionKey = "selection_key";
  bool isSelection = false;

  MySelectionPreferences() {
    _getSelection();
  }

  Future<void> setSelection(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(selectionKey, value);
    isSelection = value;
  }

  void _getSelection() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    isSelection = sharedPreferences.getBool(selectionKey) ?? false;
  }
}