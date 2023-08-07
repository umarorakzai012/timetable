import 'package:flutter/material.dart';
import 'package:timetable/full_timetable.dart';
import 'package:timetable/main.dart';
import 'package:timetable/navigation_drawer.dart';
import 'package:timetable/timetable_data.dart';
import 'package:timetable/upload_timetable.dart';
import 'package:timetable/your_timetable.dart';

class ChooseCourseScreen extends StatefulWidget{
  const ChooseCourseScreen({super.key});

  @override
  State<ChooseCourseScreen> createState() => _ChooseCourseScreenState();
}

bool loaded = false;
List<String> selected = [];
Map<String, bool> current = {};

bool _oncecc = true;

class _ChooseCourseScreenState extends State<ChooseCourseScreen> {
  var _showBy = "";

  @override
  Widget build(BuildContext context) {
    if(_oncecc){
      _oncecc = false;
      load();
    }
    Set<String> copyChoose = {};
    for(int i = 0; i < chooseCourse.course.length; i++){
      if(chooseCourse.course.elementAt(i).toLowerCase().contains(_showBy.toLowerCase())){
        copyChoose.add(chooseCourse.course.elementAt(i));
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Course(s)"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () {
          ChooseCourse.setCurrent(true, current);
          ChooseCourse.setSelected(true, selected);
          showToast(context, "Saved");
          yourTimeTableData.clear();
          for(var key in fullTimeTableData.keys){
            yourTimeTableData[key] = YourTimeTableData();
            yourTimeTableData[key]!.makeYourTimeTable(fullTimeTableData[key]!, selected);
          }
          YourTimeTableData.setYourTimeTableData(true, yourTimeTableData);
        },
      ),
      body: copyChoose.isNotEmpty || loaded ? Stack(
        children: [
          Form(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                decoration: const InputDecoration(
                  label: Text("Search"),
                  labelStyle: TextStyle(
                    fontSize: 20,
                  )
                ),
                initialValue: _showBy,
                onChanged: (value) {
                  setState(() {
                    _showBy = value;
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 70),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: copyChoose.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  value: current[copyChoose.elementAt(index)],
                  tristate: false,
                  onChanged: (value) {
                    if(value == null) return;
                    setState(() {
                      current[copyChoose.elementAt(index)] = value;
                    });
                    if(value){
                      selected.add(copyChoose.elementAt(index));
                    } else {
                      selected.remove(copyChoose.elementAt(index));
                    }
                  },
                  title: Text(copyChoose.elementAt(index).replaceAll("\n", " ")),
                );
              },
            ),
          ),
        ],
      ) 
      : const Center(child: Text("Please Upload an Excel File First")),
      drawer: const MyNavigationDrawer(2),
    );
  }

  void load() async {
    var loaded = await ChooseCourse.isLoaded();
    if(loaded){
      var temp = await ChooseCourse.getchooseCourse();
      chooseCourse = temp;
    }

    loaded = await ChooseCourse.getIsSelectedLoaded();
    if(loaded){
      var temp = await ChooseCourse.getSelected();
      selected = temp;
    }

    loaded = await ChooseCourse.getIsCurrentLoaded();
    if(loaded){
      var temp = await ChooseCourse.getCurrent();
      current = temp;
    }
    setState(() {
      
    });
  }
}
