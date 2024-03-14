import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:timetable/update/progress_indicator.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckUpdate {
  CheckUpdate({required this.fromNavigation, required this.context}) {
    deletion();
    checkForUpdate();
  }

  final BuildContext context;
  final bool fromNavigation;
  bool cancelled = false;

  String fileUrl =
      "https://api.github.com/repos/umarorakzai012/timetable/releases/latest";
  String downloadUrl =
      "https://github.com/umarorakzai012/timetable/releases/download";
  final _progressDialogKey = GlobalKey<ProgressDialogState>();

  Future<bool> checkForToday() async {
    var prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    var lastChecked = prefs.getString("last checked date");
    await prefs.setString("last checked date", today.toString());
    if (lastChecked == null) {
      return false;
    }
    if (today.isAfter(DateTime.parse(lastChecked))) {
      return false;
    }
    return true;
  }

  Future checkForUpdate() async {
    bool completed = false;
    if (fromNavigation) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) {
          return const AlertDialog(
            title: Text("Checking For Update"),
            content:
                Wrap(children: [Center(child: CircularProgressIndicator())]),
          );
        },
      ).whenComplete(() => completed = true);
    }
    var checkedAlready = await checkForToday();
    if (checkedAlready && !fromNavigation) return;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var dio = Dio();
    try {
      final response = await dio.get(fileUrl);
      if (response.statusCode != 200) {
        if (fromNavigation) {
          defaultAlertDialog("A Problem Occured",
              "A problem occuried while checking for update. Could not get response.");
        }
      }
      String latestVersion = response.data['tag_name'].toString();
      String currentVersion = "v${packageInfo.version}";
      String appName = packageInfo.appName;
      if (latestVersion != currentVersion) {
        // https://api.github.com/repos/umarorakzai012/battle_ship/releases/latest
        fileUrl = "$fileUrl/$latestVersion";
        // https://github.com/umarorakzai012/battle_ship/releases/download/v0.1.1
        downloadUrl = "$downloadUrl/$latestVersion";
        String apkName =
            await getSupportedApk(latestVersion.substring(1), appName);
        if (apkName == "") {
          if (fromNavigation) {
            defaultAlertDialog("A Problem Occured",
                "A problem occuried while checking for update. Could not get apk.");
          }
          return;
        }
        if (completed) return;

        // https://github.com/umarorakzai012/battle_ship/releases/download/v0.1.1/BattleShip-v0.1.1.apk
        downloadUrl = "$downloadUrl/$apkName";
        _showAvailableUpdateAlertDialog(apkName);
      } else if (fromNavigation) {
        defaultAlertDialog(
            "No Update Available", "There is no update available.");
      }
    } catch (e) {
      if (fromNavigation) {
        defaultAlertDialog("A Problem Occured",
            "A problem occuried while checking for update.");
      }
      // doing nothing on failure
    }
  }

  defaultAlertDialog(String title, String content) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            ElevatedButton(
              child: const Text("Ok"),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAvailableUpdateAlertDialog(String apkName) {
    if (fromNavigation) {
      Navigator.of(context).pop();
    }
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("Update Available"),
          content: const Text(
            "There is an update available. Do you want to update your app?",
          ),
          actions: [
            ElevatedButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            ElevatedButton(
              child: const Text("Yes"),
              onPressed: () {
                Navigator.of(ctx).pop();
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
      builder: (BuildContext ctx) {
        return ProgressDialog(key: _progressDialogKey, value: 0.0);
      },
    ).whenComplete(() => cancelled = true);
  }

  void _networkInstallApk(String apkName) async {
    if (_progressDialogKey.currentState != null) return;
    _showProgressDialog();

    var appDocDir = await getTemporaryDirectory();
    String savePath = "${appDocDir.path}/app.apk";

    while (_progressDialogKey.currentState == null) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    double progressValue = _progressDialogKey.currentState!.progress;

    final dio = Dio();
    var cancelToken = CancelToken();
    try {
      await dio.download(downloadUrl, savePath, cancelToken: cancelToken,
          onReceiveProgress: (count, total) {
        if (progressValue < 1.0) {
          progressValue = count / total;
        } else {
          progressValue = 0.0;
        }

        _progressDialogKey.currentState?.updateProgress(progressValue);
        if (cancelled) cancelToken.cancel("user cancelled");
      });

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      await InstallPlugin.install(savePath);
    } catch (e) {
      if (!cancelToken.isCancelled) {
        defaultAlertDialog("Updating Failed", "Please try again.");
      }
    } finally {
      dio.close();
    }
  }

  Future<String> getSupportedApk(String version, String appName) async {
    var abi = ffi.Abi.current();
    if (abi == ffi.Abi.androidArm &&
        await checkIfExits("$downloadUrl/$appName-armeabi-v7a-v$version.apk")) {
      return "$appName-armeabi-v7a-v$version.apk";
    } else if (abi == ffi.Abi.androidArm64 &&
        await checkIfExits("$downloadUrl/$appName-arm64-v8a-v$version.apk")) {
      return "$appName-arm64-v8a-v$version.apk";
    } else if (abi == ffi.Abi.androidX64 &&
        await checkIfExits("$downloadUrl/$appName-x86_64-v$version.apk")) {
      return "$appName-x86_64-v$version.apk";
    } else if (await checkIfExits("$downloadUrl/$appName-v$version.apk")) {
      return "$appName-v$version.apk";
    }
    return "";
  }

  Future<bool> checkIfExits(String url) async {
    var dio = Dio();
    try {
      Response<dynamic> response =
          await dio.head(url).timeout(const Duration(seconds: 2));
      dio.close();
      return response.statusCode == 200;
    } catch (e) {
      // nothing
    }
    return false;
  }

  void deletion() async {
    var appDocDir = await getTemporaryDirectory();
    String savePath = "${appDocDir.path}/app.apk";
    await deleteFile(File(savePath));
  }

  Future<void> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Error in getting access to the file.
    }
  }
}
