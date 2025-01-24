import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:timetable/choose_courses.dart';
import 'package:timetable/enum_screen.dart';
import 'package:timetable/full_free.dart';
import 'package:timetable/navigation_drawer.dart';
import 'package:timetable/tab_view.dart';
import 'package:timetable/timetable_data.dart';
import 'package:timetable/update/update_checker.dart';
import 'model_theme.dart';

Map<String, YourTimeTableData> yourTimeTableData = {};
bool _onceyttd = true;

class YourTimeTable extends StatefulWidget {
  const YourTimeTable({super.key});

  @override
  State<YourTimeTable> createState() => _YourTimeTableState();
}

class _YourTimeTableState extends State<YourTimeTable> {
  late TextStyle textStyle;

  List<String> readmeContent = [], days = [];

  @override
  Widget build(BuildContext context) {
    double size = 15;
    double baseWidth = 360;
    double screenWidth = MediaQuery.of(context).size.width;
    size += ((screenWidth - baseWidth) / 15);
    if (size > 20) size = 20;
    if (size < 12) size = 12;
    textStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: size,
    );
    if (_onceyttd) {
      load();
    }
    CheckUpdate(fromNavigation: false, context: context);
    days = yourTimeTableData.keys.toList();
    if (yourTimeTableData.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Your TimeTable"),
        ),
        body: loaded
            ? const Center(
                child: Text(
                "Please Select Course(s)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ))
            : const Center(
                child: Text("Please Upload An Excel File",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
        drawer: const MyNavigationDrawer(Screen.yourTimeTable),
      );
    }
    return buildYourTimeTableScreen();
  }

  Widget buildYourTimeTableScreen() {
    days = yourTimeTableData.keys.toList();
    List<List<String>> slots = [], classes = [], value = [];
    List<List<Container>> containers = [];

    List<Tab> tabs = [];
    for (var i = 0; i < days.length; i++) {
      tabs.add(Tab(
        child: Text(days[i]),
      ));
    }

    int index = (DateTime.now().weekday - 1) >= days.length
        ? 0
        : DateTime.now().weekday - 1;

    DateTime now = DateTime.now();
    for (var i = 0; i < days.length; i++) {
      List<DateTime> allAddedSlotDateTime = [];
      slots.add([]);
      classes.add([]);
      value.add([]);
      containers.add([]);
      for (String key in yourTimeTableData[days[i]]!.yourCourses.keys) {
        for (String classesAndSlots
            in yourTimeTableData[days[i]]!.yourCourses[key]!) {
          var splited = classesAndSlots.split("...");
          int insertIndex = slots[i].length;
          DateTime currentSlot = createDateTime(splited[1].split("-")[0], now);
          for (var j = 0; j < allAddedSlotDateTime.length; j++) {
            if (currentSlot.isBefore(allAddedSlotDateTime[j])) {
              insertIndex = j;
              break;
            }
          }
          var index = splited[0].indexOf("(");
          if (index != -1) {
            splited[0] = splited[0].substring(0, index);
          }
          if (insertIndex >= slots[i].length) {
            allAddedSlotDateTime.add(currentSlot);
            value[i].add(key);
            slots[i].add(splited[1]);
            classes[i].add(splited[0]);
          } else {
            allAddedSlotDateTime.insert(insertIndex, currentSlot);
            value[i].insert(insertIndex, key);
            slots[i].insert(insertIndex, splited[1]);
            classes[i].insert(insertIndex, splited[0]);
          }
        }
      }
      for (var j = 0; j < slots[i].length; j++) {
        containers[i]
            .add(makeContainer(slots[i][j], classes[i][j], value[i][j]));
      }
    }
    List<Widget> display = [];
    for (var i = 0; i < days.length; i++) {
      if (value[i].isEmpty) {
        display.add(
          const Center(
            child: AnimationConfiguration.staggeredList(
              position: 0,
              duration: Duration(milliseconds: 375),
              child: SlideAnimation(
                child: FadeInAnimation(
                  child: Text(
                    "Free Day",
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        display.add(
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: MediaQuery.of(context).size.width,
            child: AnimationLimiter(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: containers[i].length,
                itemBuilder: (context, j) {
                  return AnimationConfiguration.staggeredList(
                    position: j,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      child: FadeInAnimation(child: containers[i][j]),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      }
    }
    return MyTabBar(
      tabs: tabs,
      display: display,
      title: "Your TimeTable",
      initialIndex: index,
      drawer: const MyNavigationDrawer(Screen.yourTimeTable),
    );
  }

  String formattingSlots(String slot) {
    if (!slot.contains(":")) {
      slot = "$slot:00";
    }
    slot = slot.trim();
    slot = makingOfLengthFive(slot);
    int indexOf = slot.indexOf(":");
    var subs = slot.substring(0, indexOf);
    if (int.parse(subs) >= 7 && int.parse(subs) < 12) {
      slot = "$slot AM";
    } else {
      slot = "$slot PM";
    }
    slot.replaceAll("  ", " ");

    return slot;
  }

  String makingOfLengthFive(String toFormat) {
    if (toFormat.length == 5) return toFormat;

    var split = toFormat.split(":");
    var first = split[0];
    var end = split[1];
    if (first.length == 1) first = "0$first";
    if (end.length == 1) end = "0$end";
    return "$first:$end";
  }

  Widget makeYourText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      // softWrap: true,
      style: textStyle,
    );
  }

  Container makeContainer(String slot, String classes, String value) {
    String top = slot.split("-")[0];
    String bottom = slot.split("-")[1];
    top = formattingSlots(top);
    bottom = formattingSlots(bottom);

    return Container(
      // height: 85,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: Provider.of<ModelTheme>(context, listen: false).getGradient(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 10),
            child: SizedBox(
              width: 80,
              child: Center(child: makeYourText(classes)),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!value.contains("\n")) ...[
                // SizedBox(
                //   width: MediaQuery.of(context).size.width - 160,
                //   child: makeYourText(value),
                // ),
                makeYourText(value),
              ] else ...[
                makeYourText(value.split("\n")[0]),
                value.split("\n").length == 2
                    ? makeYourText(value.split("\n")[1])
                    : makeYourText(""),
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
              )),
        ],
      ),
    );
  }

  Future<void> load() async {
    _onceyttd = false;
    loaded =
        await FullTimeTableData.isLoaded() && await ChooseCourse.isLoaded();
    if (loaded) {
      var temp = await FullTimeTableData.getFullTimeTableData();
      fullTimeTableData = temp;
    }
    var load = await YourTimeTableData.isLoadedYourTimeTableData();
    if (load) {
      var temp = await YourTimeTableData.getYourTimeTableData();
      yourTimeTableData = temp;
    }
    FlutterNativeSplash.remove();
    setState(() {});
  }

  DateTime createDateTime(String time, DateTime date) {
    var temp = time.split(":");
    var tempInt = int.parse(temp[0]);
    int hour = 0;
    if (tempInt > 7 && tempInt <= 12) {
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
