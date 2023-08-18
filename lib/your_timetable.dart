import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:timetable/choose_courses.dart';
import 'package:timetable/enum_screen.dart';
import 'package:timetable/full_free.dart';
import 'package:timetable/navigation_drawer.dart';
import 'package:timetable/progress_indicator.dart';
import 'package:timetable/timetable_data.dart';

import 'model_theme.dart';

String readMeUrl = 'https://raw.githubusercontent.com/umarorakzai012/apkFilesForMyApps/main/README.md';
String fileUrl = "https://github.com/umarorakzai012/apkFilesForMyApps/raw/main";

class YourTimeTable extends StatefulWidget {
  const YourTimeTable({super.key});

  @override
  State<YourTimeTable> createState() => _YourTimeTableState();
}

Map<String, YourTimeTableData> yourTimeTableData = {};
int _length = 0;

bool _onceyttd = true;

class _YourTimeTableState extends State<YourTimeTable> {
  final _progressDialogKey = GlobalKey<ProgressDialogState>();
  final GlobalKey<AnimatedListState> _animatedListStateKey = GlobalKey<AnimatedListState>();
  final GlobalKey<__MyTextState> _myTextKey = GlobalKey<__MyTextState>();
  String _daySelectedYourTimeTable = "";
  List<Container> containers = [];

  List<String> readmeContent = [], days = [];
  double _progressValue = 0;
  bool firstTime = true;

  @override
  Widget build(BuildContext context) {
    if(_onceyttd){
      load();
      deletion();
      checkForUpdate(context);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your TimeTable"),
      ),
      body: loaded
          ? yourTimeTableData.isEmpty ? const Center(child: Text("Please Select Course(s)"),) : buildYourTimeTableScreen() 
          : const Center(child: Text("Please Upload An Excel File")),
      drawer : MyNavigationDrawer(Screen.yourTimeTable, context),
      floatingActionButton: _MyText(key: _myTextKey, length: 0),
    );
  }

  double calculatePixel(String value) {
    double size = 15;
    if(MediaQuery.of(context).size.width < 350){
      size = 11;
    }
    TextStyle textStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: size);
    final Size txtSize = textSize(value, textStyle);
    return (txtSize.width + 40);
  }

  Widget buildYourTimeTableScreen() {
    days = yourTimeTableData.keys.toList();
    List<List<String>> slots = [], classes = [], value = [];

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      int index = days.indexOf(_daySelectedYourTimeTable);
      if(index == -1) return;

      Future ft = Future(() {});

      containers.clear();
      _animatedListStateKey.currentState!.removeAllItems((context, animation) => const Text(""));

      _myTextKey.currentState!.setLength(slots[index].length);
      for (var i = 0; i < slots[index].length; i++) {
        ft = ft.then((_) {
          return Future.delayed(const Duration(milliseconds: 100), (){
            String slotString = slots[index][i], classesString = classes[index][i], valueString = value[index][i];
            containers.add(makeContainer(slotString, classesString, valueString));
            _animatedListStateKey.currentState!.insertItem(containers.length - 1);
          });
        });
      }
        
    });

    if(_daySelectedYourTimeTable.compareTo("") == 0){
      int index = (DateTime.now().weekday - 1) >= days.length ? 0 : DateTime.now().weekday - 1;
      _daySelectedYourTimeTable = days[index];
    }
    for(int i = 0; i < days.length; i++){
      Map<int, int> sorting = {};
      value.add([]);
      slots.add([]);
      classes.add([]);
      for(String key in yourTimeTableData[days[i]]!.yourCourses.keys){
        for(String classesAndSlots in yourTimeTableData[days[i]]!.yourCourses[key]!){
          var splited = classesAndSlots.split("...");
          int indexOfSlot = 0, insertIndex = 0;
          if(!key.toLowerCase().contains("lab b")){
            indexOfSlot = fullTimeTableData[days[i]]!.slots.indexOf(splited[1]);
          } else {
            var splitTheSplited = splited[1].split("-");
            String startingSlot = splitTheSplited[0];  
            String endingSlot = splitTheSplited[1];
            var fttdSlot = fullTimeTableData[days[i]]!.slots;
            for(int j = 0; j < fttdSlot.length; j++){
              if(fttdSlot[j].contains(startingSlot) && fttdSlot[j + 2].contains(endingSlot)){
                indexOfSlot = j;
              }
            }
          }
          if(sorting.isEmpty){
            sorting[indexOfSlot] = insertIndex;
          } 
          else {
            for(int j = indexOfSlot - 1; j >= 0; j--){
              if(sorting.containsKey(j)){
                insertIndex = sorting[j]! + 1;
                break;
              }
            }
            sorting[indexOfSlot] = insertIndex;
            for(int j = indexOfSlot + 1; j < fullTimeTableData[days[i]]!.slots.length; j++){
              if(sorting.containsKey(j)){
                sorting[j] = sorting[j]! + 1;
              }
            }
          }
          var index = splited[0].indexOf("(");
          if(index != -1){
            splited[0] = splited[0].substring(0, index);
          } 
          if(insertIndex >= slots.length){
            value.last.add(key);
            slots.last.add(splited[1]);
            classes.last.add(splited[0]);
          } else {
            value.last.insert(insertIndex, key);
            slots.last.insert(insertIndex, splited[1]);
            classes.last.insert(insertIndex, splited[0]);
          }
        }
      }
    }
    // Tween<Offset> tween = Tween<Offset>(begin: const Offset(0, -2), end: const Offset(0, 0));
    Tween<double> tween = Tween<double>(begin: 0, end: 1);
    int indexOfCurrentDaySelected = days.indexOf(_daySelectedYourTimeTable);
    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: MediaQuery.of(context).size.width,
      child: value[indexOfCurrentDaySelected].isEmpty ? 
      const Center(
        child: Text(
          "Free Day",
          style: TextStyle(fontSize: 30),
        ),
      ) :
      AnimatedList(
        key: _animatedListStateKey,
        physics: const BouncingScrollPhysics(),
        initialItemCount: containers.length,
        itemBuilder: (context, j, animation) {
          return FadeTransition(
            opacity: animation.drive(tween),
            child: containers[j],
          );
        },
      )
    );
  }

  String formattingSlots(String slot){
    if(!slot.contains(":")){
      slot = "$slot:00";
    }
    slot = slot.trim();
    slot = makingOfLengthFive(slot);
    int indexOf = slot.indexOf(":");
    var subs = slot.substring(0, indexOf);
    if(int.parse(subs) >= 7 && int.parse(subs) < 12){
      slot = "$slot AM";
    } else {
      slot = "$slot PM";
    }
    slot.replaceAll("  ", " ");

    return slot;
  }

  String makingOfLengthFive(String toFormat){
    if(toFormat.length == 5) return toFormat;

    var split = toFormat.split(":");
    var first = split[0];
    var end = split[1];
    if(first.length == 1) first = "0$first";
    if(end.length == 1) end = "0$end";
    return "$first:$end";
  }

  Size textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  Widget makeYourText(String text){
    double size = 15;
    if(MediaQuery.of(context).size.width < 350){
      size = 11;
    }
    return Text(
      text,
      textAlign: TextAlign.center,
      softWrap: true,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: size,
      ),
    );
  }

  Future checkForUpdate(BuildContext contextfromAbove) async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String name = "${packageInfo.appName}-v${packageInfo.version}";
    var dio = Dio();
    try {
      final response = await dio.get(readMeUrl);
      dio.close();
      readmeContent = response.data.toString().replaceAll("\n", "").split("<br>");
      if(!readmeContent.contains(name)){
        fileUrl = "$fileUrl/${packageInfo.appName}";
        if(await checkIfExits(fileUrl)){
          String version = "";
          for(int i = 0; i < readmeContent.length; i++){
            var temp = readmeContent[i];
            if(temp.contains("${packageInfo.appName}-v")){
              version = temp.substring("${packageInfo.appName}-v".length); // 1.0.0, something like that
              break;
            }
          }
          if(version == "") return;
          String apkName = await getSupportedApk(version, packageInfo.appName);
          if(apkName == "") return;
          setState(() {
            _showAvailableUpdateAlertDialog(contextfromAbove, apkName);
          });
        }
      }
    } catch (e) {
      // doing nothing on failure
    }
  }

  void _showAvailableUpdateAlertDialog(BuildContext contextfromAbove, String apkName) {
    showDialog(  
      context: contextfromAbove,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Available"),
          content: const Text("There is an update available. Do you want to update your app?"),
          actions: [
            ElevatedButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                _networkInstallApk(contextfromAbove, apkName);
              },
            ),
          ], 
        );  
      },  
    );  
  }

  void _showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(key: _progressDialogKey, value: 0.0);
      },
    );
  }

  _networkInstallApk(BuildContext contextfromAbove, String apkName) async {
    if (_progressValue != 0 && _progressValue < 1) {
      return;
    }
    _showProgressDialog(contextfromAbove);

    _progressValue = 0.0;
    var appDocDir = await getTemporaryDirectory();
    String savePath = "${appDocDir.path}/app.apk";
    // https://github.com/umarorakzai012/apkFilesForMyApps/raw/main/TimeTable
    fileUrl = "$fileUrl/$apkName";
    // https://github.com/umarorakzai012/apkFilesForMyApps/raw/main/TimeTable/$apkName
    final dio = Dio();

    try {
      await dio.download(fileUrl, savePath, onReceiveProgress: (count, total) {
        if (_progressValue < 1.0) {
          _progressValue = count / total;
        } else {
          _progressValue = 0.0;
        }

        _progressDialogKey.currentState?.updateProgress(_progressValue);
      });

      setState(() {
        _progressValue = 0;
        Navigator.of(contextfromAbove).pop();
      });

      await InstallPlugin.installApk(savePath);


    } catch (e) {
      setState(() {
        _progressValue = 0;
        Navigator.of(contextfromAbove).pop();
        onFailure(contextfromAbove, e.toString());
      });
    } finally {
      dio.close();
    }
  }

  void onFailure(BuildContext contextfromAbove, String msg){
    showDialog(
      context: contextfromAbove,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Updating Failed"),
          content: Text(msg),
          actions: [
            ElevatedButton(
              child: const Text("Ok"),
              onPressed: () => Navigator.of(contextfromAbove).pop(),
            ),
          ],
        );
      },
    );
  }
  
  Future<String> getSupportedApk(String version, String appName) async {
    var abi = ffi.Abi.current();
    if(abi == ffi.Abi.androidArm && await checkIfExits("$fileUrl/$appName-armeabi-v7a-v$version.apk")){
      return "$appName-armeabi-v7a-v$version.apk";
    }
    else if(abi == ffi.Abi.androidArm64 && await checkIfExits("$fileUrl/$appName-arm64-v8a-v$version.apk")){
      return "$appName-arm64-v8a-v$version.apk";
    }
    else if(abi == ffi.Abi.androidX64 && await checkIfExits("$fileUrl/$appName-x86_64-v$version.apk")){
      return "$appName-x86_64-v$version.apk";
    }
    else if(await checkIfExits("$fileUrl/$appName-v$version.apk")){
      return "$appName-v$version.apk";
    }
    return "";
  }

  Future<bool> checkIfExits(String url) async {
    var dio = Dio();
    try{
      Response<dynamic> response = await dio.head(url).timeout(const Duration(seconds: 2));
      dio.close();
      return response.statusCode == 200;
    } catch(e){
      // nothing
    }
    return false;
  }

  void deletion() async{
    var appDocDir = await getTemporaryDirectory();
    String savePath = "${appDocDir.path}/app.apk";
    await deleteFile(File(savePath));
  }

  Future<void> deleteFile(File file) async{
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Error in getting access to the file.
    }
  }

  Container makeContainer(String slot, String classes, String value){
    String top = slot.split("-")[0];
    String bottom = slot.split("-")[1];
    top = formattingSlots(top);
    bottom = formattingSlots(bottom);
    return Container(
      height: 85,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: Provider.of<ModelTheme>(context, listen: false).getGradient(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            width: 80,
            child: Center(child: makeYourText(classes))
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if(!value.contains("\n"))...[
                SizedBox(
                  width: MediaQuery.of(context).size.width - 160,
                  child: makeYourText(value),
                ),
              ]
              else...[
                makeYourText(value.split("\n")[0]),
                makeYourText(value.split("\n")[1]),
              ]
            ],
          ),
          SizedBox(
            width: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                makeYourText(top),
                makeYourText("To"),
                makeYourText(bottom),
              ],
            )
          ),
        ],
      ),
    );
  }

  Future<void> load() async {
    loaded = await FullTimeTableData.isLoaded() && await ChooseCourse.isLoaded();
    if(loaded){
      var temp = await FullTimeTableData.getFullTimeTableData();
      fullTimeTableData = temp;
    }
    var load = await YourTimeTableData.isLoadedYourTimeTableData();
    if(load){
      var temp = await YourTimeTableData.getYourTimeTableData();
      setState(() {
        yourTimeTableData = temp;
      });
    }
    FlutterNativeSplash.remove();
    _onceyttd = false;
  }
}

class _MyText extends StatefulWidget {
  final int length;
  const _MyText({super.key, required this.length});

  @override
  State<_MyText> createState() => __MyTextState();
}

class __MyTextState extends State<_MyText> {
  int _length = 0;

  void setLength(int len){
    setState(() {
      _length = len;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text("length $_length");
  }
}