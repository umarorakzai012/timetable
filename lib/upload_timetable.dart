import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timetable/choose_courses.dart';
import 'package:timetable/enum_screen.dart';
import 'package:timetable/full_free.dart';
import 'package:timetable/main.dart';
import 'package:timetable/timetable_data.dart';
import 'package:flutter/material.dart';
import 'package:timetable/navigation_drawer.dart';
import 'package:timetable/your_timetable.dart';

import 'model_theme.dart';

class UploadTimeTableScreen extends StatefulWidget{
  const UploadTimeTableScreen({super.key});

  @override
  State<UploadTimeTableScreen> createState() => _UploadTimeTableScreenState();
}

class _UploadTimeTableScreenState extends State<UploadTimeTableScreen> {

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: pushReplacementToYourTimeTable,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Upload Excel"),
        ),
        body: buildUploadTimeTableScreen(),
        drawer: const MyNavigationDrawer(Screen.uploadExcel),
      ),
    );
  }

  Future<bool> pushReplacementToYourTimeTable(){
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const YourTimeTable(),
        maintainState: false,
      ),
    );
    return Future(() => true);
  }

  Widget buildUploadTimeTableScreen(){
    return Center(
      child: ElevatedButton(
        onPressed: () async{
          if(oncecc){
            var loaded = await ChooseCourse.isLoaded();
            if(loaded){
              var temp = await ChooseCourse.getChooseCourse();
              chooseCourse = temp;
            }

            loaded = await ChooseCourse.getIsCurrentLoaded();
            if(loaded){
              var temp = await ChooseCourse.getCurrent();
              current = temp;
            }
            oncecc = false;
          }

          final PermissionStatus status = await Permission.storage.request();
          if(!status.isGranted) return;

          var result = await FilePicker.platform.pickFiles(withData: true, type: FileType.custom, allowedExtensions: ['xlsx']);
          if(result == null) return;

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          DateTime lastChecked = DateTime.parse(prefs.getString("last checked date")!);
          await prefs.clear();
          prefs.setString("last checked date", lastChecked.toString());

          setState(() {
            showAlertDialog(context);
            Provider.of<ModelTheme>(context, listen: false).setDark(Provider.of<ModelTheme>(context, listen: false).isDark);
            selectionPreferences.setSelection(selectionPreferences.isSelection);
          });

          final fileBytes = result.files.first.bytes;

          Set<String> copy = {};
          copy.addAll(current);
          current.clear();
          yourTimeTableData.clear();
          chooseCourse.course.clear();
          fullTimeTableData.clear();

          await Future.delayed(const Duration(milliseconds: 1500));

          await read(fileBytes);

          File file = File(result.files.first.path!);
          if(file.existsSync()){
            file.deleteSync();
          }

          if(fullTimeTableData.isNotEmpty){
            if(selectionPreferences.isSelection){
              for (var i = 0; i < chooseCourse.course.length; i++) {
                if(copy.contains(chooseCourse.course.elementAt(i))){
                  current.add(chooseCourse.course.elementAt(i));
                }
              }
            }
            await ChooseCourse.setCurrent(true, current);

            if(selectionPreferences.isSelection && current.isNotEmpty){
              for(var key in fullTimeTableData.keys){
                yourTimeTableData[key] = YourTimeTableData();
                yourTimeTableData[key]!.makeYourTimeTable(fullTimeTableData[key]!, current);
              }
              await YourTimeTableData.setYourTimeTableData(true, yourTimeTableData);
            }
          }

          setState(() {
            Navigator.of(context).pop();
            if(fullTimeTableData.isNotEmpty){
              showToast(context, "Data Extracted Successfully");
              loaded = true;
            } else {
              showToast(context, "A problem occurred while extracting data. Could not extract.");
              loaded = false;
            }
          });
        },
        child: const Text("Upload File"),
      ),
    );
  }
}

void showToast(BuildContext context, String msg) {  
  FToast fToast = FToast();
  fToast.init(context);
  fToast.showToast(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.blueAccent,
      ),
      child: Text(msg),
    ),
    toastDuration: const Duration(seconds: 2),
    gravity: ToastGravity.BOTTOM,
  );
}

void showAlertDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: const AlertDialog(  
          content: Text("Please wait a moment while it extracts data..."),
        ),
      );  
    },  
  );  
}

Future read(Uint8List? fileBytes) async {
  if(fileBytes == null) return;

  var excel = Excel.decodeBytes(fileBytes);
  var days = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"];

  for (var table in excel.tables.keys) {

    if(!days.contains(table.toUpperCase().trim())) continue;


    var rowsAndColumn = excel.tables[table]!.rows;

    int additionalRows = -1;
    int additionalColumns = -1;

    for(int i = 0; i < rowsAndColumn.length; i++){
      for(int j = 0; j < rowsAndColumn[i].length; j++){
        var value = rowsAndColumn[i][j] == null ? "free" : rowsAndColumn[i][j]!.value.toString();
        if(value.toUpperCase().trim().compareTo(table.toUpperCase().trim()) == 0){
          additionalRows = i;
          additionalColumns = j;
          break;
        }
      }
      if(additionalRows != -1 && additionalColumns != -1){
        break;
      }
    }

    if(additionalRows == -1 && additionalColumns == -1){
      return;
    }
    
    fullTimeTableData[table] = FullTimeTableData();
    var last = fullTimeTableData[table]!;

    for(int i = 1 + additionalColumns; i < excel.tables[table]!.maxCols; i++){
      var adding = rowsAndColumn[additionalRows + 2][i];
      if(adding == null) continue;
      last.slots.add(adding.value.toString().replaceAll(" ", ""));
    }

    for(int i = 4 + additionalRows; i < excel.tables[table]!.maxRows; i++){
      var value = rowsAndColumn[i][additionalColumns];
      if(value == null) continue;
      last.classes.add(rowsAndColumn[i][additionalColumns]!.value.toString());
    }

    for(int i = 4 + additionalRows; i < last.classes.length + 4 + additionalRows; i++){
      if(last.classes[i - 4 - additionalRows].compareTo("LABS") == 0) continue;
      for(int j = 1 + additionalColumns; j < last.slots.length + 1 + additionalColumns; j++){
        var value = rowsAndColumn[i][j] == null ? "free" : rowsAndColumn[i][j]!.value.toString();
        var split = value.split("\n");
        var txt1 = split[0].trim();
        var txt2 = "";
        if(split.length == 2) txt2 = "\n${split[1].trim()}";
        var txt = "$txt1$txt2";
        last.courses["${last.classes[i - 4 - additionalRows]}...${last.slots[j - 1 - additionalColumns]}"] = txt;
        if(txt.toLowerCase().contains("lab b") || txt.toLowerCase().contains("reserved for ee")) {
          j += 2;
        }
        if(txt == "free") continue;

        chooseCourse.course.add(txt);
      }
    }
  }
  FullTimeTableData.setLoaded(true, fullTimeTableData);
  await ChooseCourse.setLoaded(true, chooseCourse);
}