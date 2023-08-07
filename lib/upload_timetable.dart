import 'dart:async';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timetable/choose_courses.dart';
import 'package:timetable/full_timetable.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Excel"),
      ),
      body: buildUploadTimeTableScreen(),
      drawer: const MyNavigationDrawer(3),
    );
  }

  Widget buildUploadTimeTableScreen(){
    return Center(
      child: ElevatedButton(
        onPressed: () async{
          FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true, type: FileType.custom, allowedExtensions: ['xlsx']);

          if(result == null) return;

          final fileBytes = result.files.first.bytes;

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.clear();

          setState(() {
            showAlertDialog(context);
          });

          await Future.delayed(const Duration(seconds: 2));

          Map<String, bool> copy = {};
          copy.addAll(current);
          current.clear();
          selected.clear();
          yourTimeTableData.clear();
          chooseCourse.course.clear();
          fullTimeTableData.clear();

          await read(fileBytes);

          if(fullTimeTableData.isNotEmpty){
            for(int i = 0; i < chooseCourse.course.length; i++){
              if(copy.containsKey(chooseCourse.course.elementAt(i)) && selectionPreferences.isSelection){
                current[chooseCourse.course.elementAt(i)] = copy[chooseCourse.course.elementAt(i)]!;
                if(current[chooseCourse.course.elementAt(i)]!){
                  selected.add(chooseCourse.course.elementAt(i));
                }
              } 
              else {
                current[chooseCourse.course.elementAt(i)] = false;
              }
            }

            ChooseCourse.setCurrent(true, current);
            ChooseCourse.setSelected(true, selected);

            if(selectionPreferences.isSelection && selected.isNotEmpty){
              for(var key in fullTimeTableData.keys){
                yourTimeTableData[key] = YourTimeTableData();
                yourTimeTableData[key]!.makeYourTimeTable(fullTimeTableData[key]!, selected);
              }
              YourTimeTableData.setYourTimeTableData(true, yourTimeTableData);
            }
            
            setState(() {
              Provider.of<ModelTheme>(context, listen: false).setDark(Provider.of<ModelTheme>(context, listen: false).isDark);
              selectionPreferences.setSelection(selectionPreferences.isSelection);
              Navigator.of(context).pop();
              showToast(context, "Data Extracted Successfully");
              loaded = true;
            });
          } else {
            setState(() {
              Provider.of<ModelTheme>(context, listen: false).setDark(Provider.of<ModelTheme>(context, listen: false).isDark);
              selectionPreferences.setSelection(selectionPreferences.isSelection);
              Navigator.of(context).pop();
              showToast(context, "A problem occurred while extracting data. Could not extract.");
              loaded = false;
            });
          }
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
      return const AlertDialog(  
        content: Text("Please wait a moment while it extracts data..."),
      );  
    },  
  );  
}

Future read(Uint8List? fileBytes) async {
  if(fileBytes == null) return;

  var excel = Excel.decodeBytes(fileBytes);
  var days = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"];


  for (var table in excel.tables.keys) {

    if(!days.contains(table.toUpperCase())) continue;

    var rowsAndColumn = excel.tables[table]!.rows;

    int additionalRows = -1;
    int additionalColumns = -1;

    for(int i = 0; i < rowsAndColumn.length; i++){
      for(int j = 0; j < rowsAndColumn[i].length; j++){
        var value = rowsAndColumn[i][j] == null ? "free" : rowsAndColumn[i][j]!.value.toString();
        if(value.toUpperCase().compareTo(table.toUpperCase()) == 0){
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

    for(int i = 1; i < excel.tables[table]!.maxCols; i++){
      last.slots.add(rowsAndColumn[additionalRows + 2][i] == null ? "free" : rowsAndColumn[additionalRows + 2][i]!.value.toString());
    }

    for(int i = 4 + additionalRows; i < excel.tables[table]!.maxRows; i++){
      var value = rowsAndColumn[i][additionalColumns] == null ? "free" : rowsAndColumn[i][additionalColumns]!.value.toString();
      last.classes.add(value);
    }

    for(int i = 4 + additionalRows; i < excel.tables[table]!.maxRows; i++){
      if(last.classes[i - 4 - additionalRows].compareTo("LABS") == 0) continue;
      for(int j = 1 + additionalColumns; j < excel.tables[table]!.maxCols; j++){
        var value = rowsAndColumn[i][j] == null ? "free" : rowsAndColumn[i][j]!.value.toString();
        last.courses["${last.classes[i - 4 - additionalRows]}...${last.slots[j - 1 - additionalColumns]}"] = value;
        if(value.toLowerCase().contains("lab b") || value.toLowerCase().contains("reserved for ee")) {
          j += 2;
        }
        if(value == "free") continue;
        chooseCourse.course.add(value);
      }
    }
  }

  FullTimeTableData.setLoaded(true, fullTimeTableData);
  ChooseCourse.setLoaded(true, chooseCourse);
}