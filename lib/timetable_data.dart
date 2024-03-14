import 'package:shared_preferences/shared_preferences.dart';

class FullTimeTableData {
  static const _loadedKey = "fttdloaded";
  List<String> slots = [];
  List<String> classes = [];
  Map<String, String> courses = {}; // key -> classes...slots, value -> value

  static Future<bool> isLoaded() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var loadeded = prefs.getBool(_loadedKey);
    return loadeded ?? false;
  }

  static Future<void> setLoaded(
      bool loaded, Map<String, FullTimeTableData> fttdm) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loadedKey, loaded);
    await prefs.setStringList("fttdm keys", fttdm.keys.toList());

    for (var keys in fttdm.keys) {
      await prefs.setStringList("fttd $keys slots", fttdm[keys]!.slots);
      await prefs.setStringList("fttd $keys classes", fttdm[keys]!.classes);
      await prefs.setStringList(
          "fttd $keys courses keys", fttdm[keys]!.courses.keys.toList());
      await prefs.setStringList(
          "fttd $keys courses value", fttdm[keys]!.courses.values.toList());
    }
  }

  static Future<Map<String, FullTimeTableData>> getFullTimeTableData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var keys = prefs.getStringList("fttdm keys")!;
    Map<String, FullTimeTableData> fttdm = {};
    for (var key in keys) {
      fttdm[key] = FullTimeTableData();
      fttdm[key]!.slots = prefs.getStringList("fttd $key slots")!;
      fttdm[key]!.classes = prefs.getStringList("fttd $key classes")!;
      var fttdKeys = prefs.getStringList("fttd $key courses keys")!;
      var fttdValue = prefs.getStringList("fttd $key courses value")!;
      for (int i = 0; i < fttdKeys.length; i++) {
        fttdm[key]!.courses[fttdKeys[i]] = fttdValue[i];
      }
    }

    return fttdm;
  }
}

class YourTimeTableData {
  Map<String, List<String>> yourCourses =
      {}; // key -> subject and things, value -> classes ... slots

  static Future<bool> isLoadedYourTimeTableData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var isLoadededed = prefs.getBool("YourTimeTableData yourCourses loaded");
    return isLoadededed ?? false;
  }

  static Future<void> clearYourTimeTableData(
      Map<String, YourTimeTableData> yttdm) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("YourTimeTableData yourCourses loaded", false);
    List<String> yttdmKeys = yttdm.keys.toList();
    await prefs.remove("yttdm keys");
    for (var yttdmKey in yttdmKeys) {
      YourTimeTableData yttd = yttdm[yttdmKey]!;
      List<String> yttdKeys = yttd.yourCourses.keys.toList();
      await prefs.remove("yttd $yttdmKey");
      for (var yttdKey in yttdKeys) {
        await prefs.remove("yttd value $yttdmKey $yttdKey");
      }
    }
    yttdm.clear();
  }

  static Future<void> setYourTimeTableData(
      bool loaded, Map<String, YourTimeTableData> yttdm) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("YourTimeTableData yourCourses loaded", loaded);
    List<String> yttdmKeys = yttdm.keys.toList();
    await prefs.setStringList("yttdm keys", yttdmKeys);
    for (var yttdmKey in yttdmKeys) {
      YourTimeTableData yttd = yttdm[yttdmKey]!;
      List<String> yttdKeys = yttd.yourCourses.keys.toList();
      await prefs.setStringList("yttd $yttdmKey", yttdKeys);
      for (var yttdKey in yttdKeys) {
        await prefs.setStringList(
            "yttd value $yttdmKey $yttdKey", yttd.yourCourses[yttdKey]!);
      }
    }
  }

  static Future<Map<String, YourTimeTableData>> getYourTimeTableData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, YourTimeTableData> yttdm = {};
    List<String> yttdmKeys = prefs.getStringList("yttdm keys")!;
    for (var yttdmKey in yttdmKeys) {
      yttdm[yttdmKey] = YourTimeTableData();
      List<String> yttdKeys = prefs.getStringList("yttd $yttdmKey")!;
      for (var yttdKey in yttdKeys) {
        yttdm[yttdmKey]!.yourCourses[yttdKey] =
            prefs.getStringList("yttd value $yttdmKey $yttdKey")!;
      }
    }
    return yttdm;
  }

  void makeYourTimeTable(FullTimeTableData fttd, Set<String> selectedCourses) {
    for (var key in fttd.courses.keys) {
      var value = fttd.courses[key]!;
      if (selectedCourses.contains(value)) {
        List<String> splited = key.split("...");
        String mergedSlot = "";
        String classes = splited[0];
        if (value.toLowerCase().contains("lab b")) {
          mergedSlot =
              "${splited[1].split("-")[0]}-${fttd.slots[fttd.slots.indexOf(splited[1]) + 2].split("-")[1]}";
        } else {
          mergedSlot = splited[1];
        }
        if (yourCourses.containsKey(value)) {
          yourCourses[value]!.add("$classes...$mergedSlot");
        } else {
          yourCourses[value] = ["$classes...$mergedSlot"];
        }
      }
    }
  }
}

class ChooseCourse {
  static const _loadedKey = "ccloaded";
  Set<String> course = {};

  static Future<bool> isLoaded() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loadedKey) == null
        ? false
        : prefs.getBool(_loadedKey)!;
  }

  static Future<void> setLoaded(bool loaded, ChooseCourse cc) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loadedKey, loaded);
    await prefs.setStringList("cccourse", cc.course.toList());
  }

  static Future<void> clearCurrent(Set<String> currents) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("current is loaded", false);
    await prefs.remove("current keys");
    currents.clear();
  }

  static Future<void> setCurrent(bool isLoaded, Set<String> currents) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("current is loaded", isLoaded);
    await prefs.setStringList("current keys", currents.toList());
  }

  static Future<bool> getIsCurrentLoaded() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var loadeded = prefs.getBool("current is loaded");
    return loadeded ?? false;
  }

  static Future<Set<String>> getCurrent() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList("current keys")!.toSet();
  }

  static Future<ChooseCourse> getChooseCourse() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    ChooseCourse cc = ChooseCourse();
    cc.course = prefs.getStringList("cccourse")!.toSet();

    return cc;
  }
}
