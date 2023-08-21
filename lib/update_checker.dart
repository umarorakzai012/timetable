import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timetable/progress_indicator.dart';

class CheckUpdate extends StatefulWidget {
  const CheckUpdate({super.key, required this.fromNavigation});

  final bool fromNavigation;

  @override
  State<CheckUpdate> createState() => _CheckUpdateState();
}

class _CheckUpdateState extends State<CheckUpdate> {

  String fileUrl = "https://github.com/umarorakzai012/apkFilesForMyApps/raw/main";
  final _progressDialogKey = GlobalKey<ProgressDialogState>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkForUpdate();
      deletion();
    });
    return const SizedBox(height: 0, width: 0,);
  }

  Future<bool> checkForToday() async{
    var prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    var lastChecked = prefs.getString("last checked date");
    await prefs.setString("last checked date", today.toString());
    if(lastChecked == null){
      return false;
    }
    if(today.isAfter(DateTime.parse(lastChecked))){
      return false;
    }
    return true;
  }

  Future checkForUpdate() async{
    if(widget.fromNavigation){
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text("Checking For Update"),
            content: Wrap(children: [Center(child: CircularProgressIndicator())]),
          );
        },
      );
    }
    var checkedAlready = await checkForToday();
    if(checkedAlready && !widget.fromNavigation) return;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String readMeUrl = 'https://raw.githubusercontent.com/umarorakzai012/apkFilesForMyApps/main/README.md';

    String name = "${packageInfo.appName}-v${packageInfo.version}";
    var dio = Dio();
    try {
      final response = await dio.get(readMeUrl);
      if(response.statusCode != 200){
        if(widget.fromNavigation) defaultAlertDialog("A Problem Occured", "A problem occuried while checking for update. Could not get response.");
      }
      dio.close();
      var readmeContent = response.data.toString().replaceAll("\n", "").split("<br>");
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
          if(version == ""){
            if(widget.fromNavigation) defaultAlertDialog("A Problem Occured", "A problem occuried while checking for update. Could not get version.");
            return;
          }
          String apkName = await getSupportedApk(version, packageInfo.appName);
          if(apkName == ""){
            if(widget.fromNavigation) defaultAlertDialog("A Problem Occured", "A problem occuried while checking for update. Could not get apk.");
            return;
          }
          _showAvailableUpdateAlertDialog(apkName);
        }
      } else if(widget.fromNavigation){
        defaultAlertDialog("No Update Available", "There is no update available.");
      }
    } catch (e) {
      // doing nothing on failure
    }
  }

  defaultAlertDialog(String title, String content) {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            ElevatedButton(
              child: const Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAvailableUpdateAlertDialog(String apkName) {
    if(widget.fromNavigation) Navigator.of(context).pop();
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

  void _showProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(key: _progressDialogKey, value: 0.0);
      },
    );
  }

  void _networkInstallApk(String apkName) async {
    if(_progressDialogKey.currentState != null) return;
    _showProgressDialog();

    var appDocDir = await getTemporaryDirectory();
    String savePath = "${appDocDir.path}/app.apk";
    // https://github.com/umarorakzai012/apkFilesForMyApps/raw/main/TimeTable
    fileUrl = "$fileUrl/$apkName";
    // https://github.com/umarorakzai012/apkFilesForMyApps/raw/main/TimeTable/$apkName
    final dio = Dio();

    double progressValue = _progressDialogKey.currentState!.progress;

    try {
      await dio.download(fileUrl, savePath, onReceiveProgress: (count, total) {
        if (progressValue < 1.0) {
          progressValue = count / total;
        } else {
          progressValue = 0.0;
        }

        _progressDialogKey.currentState?.updateProgress(progressValue);
      });

      setState(() {
        Navigator.of(context).pop();
      });

      await InstallPlugin.installApk(savePath);


    } catch (e) {
      setState(() {
        Navigator.of(context).pop();
        onFailure(context, "Please try again.");
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
}