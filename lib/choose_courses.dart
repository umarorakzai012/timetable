import 'package:flutter/material.dart';
import 'package:timetable/enum_screen.dart';
import 'package:timetable/full_free.dart';
import 'package:timetable/main.dart';
import 'package:timetable/navigation_drawer.dart';
import 'package:timetable/timetable_data.dart';
import 'package:timetable/upload_timetable.dart';
import 'package:timetable/your_timetable.dart';

class ChooseCourseScreen extends StatefulWidget {
  const ChooseCourseScreen({super.key});

  @override
  State<ChooseCourseScreen> createState() => _ChooseCourseScreenState();
}

bool loaded = false;
Set<String> current = {};

bool oncecc = true;

class _ChooseCourseScreenState extends State<ChooseCourseScreen> {
  var _showBy = "";
  bool _showSelected = false;

  void pushReplacementToYourTimeTable(bool pop) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const YourTimeTable(),
        maintainState: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (oncecc) {
      load();
      oncecc = false;
    }
    Set<String> copyChoose = {};
    for (int i = 0; i < chooseCourse.course.length; i++) {
      String txt = chooseCourse.course.elementAt(i);
      if (txt.toLowerCase().contains(_showBy.toLowerCase())) {
        copyChoose.add(txt);
      }
    }
    return PopScope(
      canPop: false,
      onPopInvoked: pushReplacementToYourTimeTable,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Choose Course(s)"),
          actions: [
            GestureDetector(
              child: Container(
                margin: const EdgeInsets.only(right: 20),
                child: const Icon(
                  Icons.delete,
                  size: 33,
                ),
              ),
              onTap: () async {
                await ChooseCourse.clearCurrent(current);
                await YourTimeTableData.clearYourTimeTableData(
                    yourTimeTableData);
                setState(() {
                  showToast(context, "Cleared Selection");
                });
              },
            ),
            GestureDetector(
              child: Container(
                margin: const EdgeInsets.only(right: 20),
                child: const Icon(
                  Icons.select_all,
                  size: 33,
                ),
              ),
              onTap: () async {
                setState(() {
                  _showSelected = !_showSelected;
                });
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.save),
          onPressed: () {
            ChooseCourse.setCurrent(true, current);

            showToast(context, "Saved");

            yourTimeTableData.clear();
            for (var key in fullTimeTableData.keys) {
              yourTimeTableData[key] = YourTimeTableData();
              yourTimeTableData[key]!
                  .makeYourTimeTable(fullTimeTableData[key]!, current);
            }
            YourTimeTableData.setYourTimeTableData(true, yourTimeTableData);
          },
        ),
        body: copyChoose.isNotEmpty || loaded
            ? Stack(
                children: [
                  Form(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        decoration: const InputDecoration(
                            label: Text("Search"),
                            labelStyle: TextStyle(
                              fontSize: 20,
                            )),
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
                        bool isSelected =
                            current.contains(copyChoose.elementAt(index));

                        if (_showSelected && !isSelected) {
                          return const SizedBox(width: 0, height: 0);
                        }

                        return CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          value: isSelected,
                          tristate: false,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              if (value) {
                                current.add(copyChoose.elementAt(index));
                              } else {
                                current.remove(copyChoose.elementAt(index));
                              }
                            });
                          },
                          title: Text(copyChoose
                              .elementAt(index)
                              .replaceAll("\n", " ")),
                        );
                      },
                    ),
                  ),
                ],
              )
            : const Center(child: Text("Please Upload an Excel File")),
        drawer: const MyNavigationDrawer(Screen.courseList),
      ),
    );
  }

  void load() async {
    var loaded = await ChooseCourse.isLoaded();
    if (loaded) {
      var temp = await ChooseCourse.getChooseCourse();
      chooseCourse = temp;
    }

    loaded = await ChooseCourse.getIsCurrentLoaded();
    if (loaded) {
      var temp = await ChooseCourse.getCurrent();
      current = temp;
    }
    setState(() {});
  }
}
