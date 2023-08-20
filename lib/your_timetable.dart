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

Map<String, YourTimeTableData> yourTimeTableData = {};
bool _onceyttd = true;

class YourTimeTable extends StatefulWidget {
  const YourTimeTable({super.key});

  @override
  State<YourTimeTable> createState() => _YourTimeTableState();
}

class _YourTimeTableState extends State<YourTimeTable> {
  final _progressDialogKey = GlobalKey<ProgressDialogState>();
  final List<GlobalKey<AnimatedListState>> _animatedListStateKey = [];
  String _daySelectedYourTimeTable = "";
  List<List<Container>> containers = [];
  late TextStyle textStyle;
  int containerIndex = 0;

  List<String> readmeContent = [], days = [];
  double _progressValue = 0;
  bool iCalled = true;

  @override
  Widget build(BuildContext context) {
    double size = 15;
    double baseWidth = 360;
    double screenWidth = MediaQuery.of(context).size.width;
    size += ((screenWidth - baseWidth) / 15);
    if(size > 20) size = 20;
    if(size < 12) size = 12;
    textStyle = TextStyle(fontWeight: FontWeight.bold,fontSize: size,);
    if(_onceyttd){
      load();
      deletion();
      checkForUpdate();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your TimeTable"),
      ),
      body: loaded
          ? yourTimeTableData.isEmpty ? const Center(child: Text("Please Select Course(s)"),) : buildYourTimeTableScreen() 
          : const Center(child: Text("Please Upload An Excel File")),
      drawer : MyNavigationDrawer(Screen.yourTimeTable, context),
    );
  }

  double calculatePixel(String value) {
    final Size txtSize = textSize(value, textStyle);
    return (txtSize.width + 40);
  }

  Widget buildYourTimeTableScreen() {
    days = yourTimeTableData.keys.toList();
    List<String> slots = [], classes = [], value = [];
    _animatedListStateKey.add(GlobalKey<AnimatedListState>());
    containers.add([]);

    if(_daySelectedYourTimeTable.compareTo("") == 0){
      int index = (DateTime.now().weekday - 1) >= days.length ? 0 : DateTime.now().weekday - 1;
      _daySelectedYourTimeTable = days[index];
    }
    
    int indexOfCurrentDaySelected = days.indexOf(_daySelectedYourTimeTable);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(!iCalled) return;
      iCalled = false;
      int index = days.indexOf(_daySelectedYourTimeTable);
      if(index == -1) return;

      Future ft = Future(() {});

      int innerIndex = containerIndex;
      for (var i = 0; i < slots.length; i++) {
        ft = ft.then((_) {
          return Future.delayed(const Duration(milliseconds: 50), (){
            if(innerIndex != containerIndex) return;
            
            String slotString = slots[i], classesString = classes[i], valueString = value[i];
            var cont = makeContainer(slotString, classesString, valueString);

            if(innerIndex != containerIndex) return;
            containers[innerIndex].add(cont);
            
            if(innerIndex != containerIndex) return;
            _animatedListStateKey[innerIndex].currentState!.insertItem(containers[innerIndex].length - 1);
          });
        });
      }
    });
    DateTime now = DateTime.now();
    List<DateTime> allAddedSlotDateTime = [];
    for(String key in yourTimeTableData[_daySelectedYourTimeTable]!.yourCourses.keys){
      for(String classesAndSlots in yourTimeTableData[_daySelectedYourTimeTable]!.yourCourses[key]!){
        var splited = classesAndSlots.split("...");
        int insertIndex = slots.length;
        DateTime currentSlot = createDateTime(splited[1].split("-")[0], now);
        for (var j = 0; j < allAddedSlotDateTime.length; j++) {
          if(currentSlot.isBefore(allAddedSlotDateTime[j])){
            insertIndex = j;
            break;
          }
        }
        var index = splited[0].indexOf("(");
        if(index != -1){
          splited[0] = splited[0].substring(0, index);
        } 
        if(insertIndex >= slots.length){
          allAddedSlotDateTime.add(currentSlot);
          value.add(key);
          slots.add(splited[1]);
          classes.add(splited[0]);
        } else {
          allAddedSlotDateTime.insert(insertIndex, currentSlot);
          value.insert(insertIndex, key);
          slots.insert(insertIndex, splited[1]);
          classes.insert(insertIndex, splited[0]);
        }
      }
    }
    Tween<Offset> tweenSlide = Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0));
    Tween<double> tweenFade = Tween<double>(begin: 0, end: 1);
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 78),
          width: MediaQuery.of(context).size.width,
          child: value[indexOfCurrentDaySelected].isEmpty ? 
          const Center(
            child: Text(
              "Free Day",
              style: TextStyle(fontSize: 30),
            ),
          ) :
          AnimatedList(
            key: _animatedListStateKey[containerIndex],
            physics: const BouncingScrollPhysics(),
            initialItemCount: containers[containerIndex].length,
            itemBuilder: (context, j, animation) {
              return SlideTransition(
                position: animation.drive(tweenSlide),
                child: FadeTransition(
                  opacity: animation.drive(tweenFade),
                  child: containers[containerIndex][j],
                ),
              );
            },
          )
        ),
        Positioned(
          bottom: 78,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 2,
            color: Colors.black87,
          ),
        ),
        if(indexOfCurrentDaySelected != 0) Positioned(
          bottom: 10,
          left: 10,
          child: FloatingActionButton(
            onPressed: () => setState(() {
              iCalled = true;
              _daySelectedYourTimeTable = days[indexOfCurrentDaySelected - 1];
              containerIndex++;
            }),
            heroTag: null,
            child: const Icon(Icons.arrow_back),
          ),
        ),
        if(indexOfCurrentDaySelected + 1 != days.length) Positioned(
          bottom: 10,
          right: 10,
          child: FloatingActionButton(
            onPressed: () => setState(() {
              iCalled = true;
              _daySelectedYourTimeTable = days[indexOfCurrentDaySelected + 1];
              containerIndex++;
            }),
            heroTag: null,
            child: const Icon(Icons.arrow_forward),
          ),
        ),
        Positioned(
          bottom: 13,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Center(
              child: DropdownButton(
                value: _daySelectedYourTimeTable,
                underline: const SizedBox(),
                iconSize: 36,
                items: <DropdownMenuItem>[
                  for(int i = 0; i < days.length; i++)...[
                    DropdownMenuItem(
                      value: days[i],
                      child: Text(days[i]),
                    )
                  ]
                ], 
                onChanged: (value) {
                  if(_daySelectedYourTimeTable.compareTo(value) == 0) return;
                  setState(() {
                    iCalled = true;
                    _daySelectedYourTimeTable = value;
                    containerIndex++;
                  });
                },
              ),
            ),
          ),
        )
      ],
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
    return Text(
      text,
      textAlign: TextAlign.center,
      softWrap: true,
      style: textStyle,
    );
  }

  Future checkForUpdate() async{
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
          _showAvailableUpdateAlertDialog(apkName);
        }
      }
    } catch (e) {
      // doing nothing on failure
    }
  }

  void _showAvailableUpdateAlertDialog(String apkName) {
    showDialog(  
      context: context,
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
                _networkInstallApk(apkName);
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

  _networkInstallApk(String apkName) async {
    if (_progressValue != 0 && _progressValue < 1) {
      return;
    }
    _showProgressDialog(context);

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
        iCalled = true;
        containerIndex++;
        _progressValue = 0;
        Navigator.of(context).pop();
      });

      await InstallPlugin.installApk(savePath);


    } catch (e) {
      setState(() {
        iCalled = true;
        containerIndex++;
        _progressValue = 0;
        Navigator.of(context).pop();
        onFailure(context, e.toString());
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
          Container(
            margin: const EdgeInsets.only(left: 10),
            // width: 80,
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
          Container(
            margin: const EdgeInsets.only(right: 10),
            // width: 80,
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
    _onceyttd = false;
    loaded = await FullTimeTableData.isLoaded() && await ChooseCourse.isLoaded();
    if(loaded){
      var temp = await FullTimeTableData.getFullTimeTableData();
      fullTimeTableData = temp;
    }
    var load = await YourTimeTableData.isLoadedYourTimeTableData();
    if(load){
      var temp = await YourTimeTableData.getYourTimeTableData();
      yourTimeTableData = temp;
    }
    FlutterNativeSplash.remove();
    setState(() {
      iCalled = true;
    });
  }

  DateTime createDateTime(String time, DateTime date){ 
    var temp = time.split(":");
    var tempInt = int.parse(temp[0]);
    int hour = 0;
    if(tempInt > 7 && tempInt <= 12){
      hour = tempInt;
    } else {
      hour = tempInt + 12;
    }
    int minute = temp.length == 1 ? 0 : int.parse(temp[1]);
    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
      0, // seconds
      0, // millisecond
      0, // microseconds
    );
  }
}