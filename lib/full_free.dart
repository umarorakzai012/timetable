import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:timetable/choose_courses.dart';
import 'package:timetable/enum_screen.dart';
import 'package:timetable/navigation_drawer.dart';
import 'package:timetable/tab_view.dart';
import 'package:timetable/timetable_data.dart';
import 'package:timetable/your_timetable.dart';

import 'model_theme.dart';

Map<String, FullTimeTableData> fullTimeTableData = {};

class FullFree extends StatefulWidget {
  const FullFree(this.naviKey, this.appBarText, this.emptySlot, {super.key});
  final Screen naviKey;
  final String appBarText, emptySlot;

  @override
  State<FullFree> createState() => _FullFreeTimeTableState();
}

class _FullFreeTimeTableState extends State<FullFree> {
  Map<String, List<String>> showDayData = {};
  List<String> _allSlot = [], days = [];
  List<List<List<Container>>> containers = [];

  Future<bool> pushReplacementToYourTimeTable(){
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const YourTimeTable(),
        maintainState: false,
      ),
    );
    return Future(() => true);
  }

  @override
  Widget build(BuildContext context) {
    if(!loaded && fullTimeTableData.isEmpty){
      return WillPopScope(
        onWillPop: pushReplacementToYourTimeTable,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.appBarText),
          ),
          body: const Center(child: Text("Please Upload An Excel File", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
          drawer: MyNavigationDrawer(widget.naviKey),
        ), 
      );
    }
    return WillPopScope(
      onWillPop: pushReplacementToYourTimeTable,
      child: buildFullTimeTableScreen(),
    );
  }

  String formattingSlots(String toFormat) {
    var splited = toFormat.split("-");
    var first = splited[0];
    var end = splited[1];
    first = addingColon(first);
    end = addingColon(end);
    var show = "$first-$end";
    return show;
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

  String addingColon(String toFormat) {
    if(toFormat.contains(":")) return makingOfLengthFive(toFormat);
    return makingOfLengthFive("$toFormat:0");
  }

  // time -> 08 OR 8:50
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

  int currentSlotShouldBe(DateTime date, List<String> selectedFromThese) {
    bool afterIsBeforeOfLastOne = true;
    for (var i = 0; i < selectedFromThese.length; i++) {
      var temp = selectedFromThese[i].split("-");
      var from = createDateTime(temp[0], date);
      var to = createDateTime(temp[1], date);
      if((date.isAfter(from) && date.isBefore(to)) || date.isAtSameMomentAs(from)){
        return i;
      }
      if(afterIsBeforeOfLastOne && date.isBefore(from)){
        return i;
      }
      afterIsBeforeOfLastOne = date.isAfter(to);
    }
    return 0;
  }

  Widget buildFullTimeTableScreen() {
    days.clear();
    showDayData.clear();
    containers.clear();
    days.addAll(fullTimeTableData.keys);
    List<Tab> tabs = [];
    List<List<Tab>> nestedTabs = [];
    List<Widget> display = [];
    List<List<Widget>> nestedDisplay = [];

    var date = DateTime.now();
    // print(date); -> 2023-08-14 17:32:00.104376
    int index = (date.weekday - 1) >= days.length ? 0 : date.weekday - 1;

    for (var day in fullTimeTableData.keys) {
      containers.add([]);
      for(var key in fullTimeTableData[day]!.courses.keys){
        var value = fullTimeTableData[day]!.courses[key]!;
        if(value == "free" && widget.naviKey == Screen.fullTimeTable) {
          continue;
        } else if(value != "free" && widget.naviKey == Screen.freeTimeTable) {
          continue;
        }
        var inside = key.split("...");
        var keyClasses = inside[0];
        keyClasses = keyClasses.substring(0, keyClasses.contains("(") ? keyClasses.indexOf("(") : keyClasses.length);
        var keySlot = inside[1];
        if(showDayData.containsKey(keySlot)){
          if(widget.naviKey == Screen.freeTimeTable) {
            showDayData[keySlot]!.add(keyClasses);
          } else {
            showDayData[keySlot]!.add("$keyClasses...$value");
          }
        } else {
          if(widget.naviKey == Screen.freeTimeTable){
            showDayData[keySlot] = [keyClasses];
          } else {
            showDayData[keySlot] = ["$keyClasses...$value"];
          }
        }
      }
      for (var key in showDayData.keys) {
        containers.last.add([]);
        for (var i = 0; i < showDayData[key]!.length; i++) {
          containers.last.last.add(makeContainer(showDayData[key]![i], i));
        }
      }
      showDayData.clear();
    }
    for (var i = 0; i < containers.length; i++) {
      tabs.add(Tab(child: Text(days[i]),));
      _allSlot = fullTimeTableData[days[i]]!.slots;
      nestedTabs.add([]);
      for (var j = 0; j < containers[i].length; j++) {
        nestedTabs[i].add(Tab(child: Text(formatSlot(_allSlot[j])),));
      }
      nestedDisplay.add([]);
      for (var j = 0; j < containers[i].length; j++) {
        if(containers[i][j].isEmpty){
          nestedDisplay[i].add(Container(
          margin: const EdgeInsets.only(top: 10, bottom: 127),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
            child: Center(
              child: AnimationConfiguration.staggeredList(
                position: 0,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  child: FadeInAnimation(
                    child: Text(
                      widget.emptySlot,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
              ) 
            ),
          ));
        } else {
          nestedDisplay[i].add(Container(
            margin: const EdgeInsets.only(top: 10),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: AnimationLimiter(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: containers[i][j].length,
                itemBuilder: (context, k) {
                  return AnimationConfiguration.staggeredList(
                    position: k,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: containers[i][j][k],
                      ),
                    ),
                  );
                },
              ),
            ),
          ));
        }
      }
      int slotAccordingToCurrentTime = currentSlotShouldBe(date, _allSlot);
      display.add(MyTabBar(tabs: nestedTabs[i], display: nestedDisplay[i], initialIndex: slotAccordingToCurrentTime));
    }
    return MyTabBar(tabs: tabs, display: display, initialIndex: index, drawer: MyNavigationDrawer(widget.naviKey), title: widget.appBarText,);
  }
  
  String formatSlot(String txt){
    var split = txt.split("-");
    var first = split[0];
    var second = split[1];
    return "${addingColon(first)}-${addingColon(second)}";
  }

  Container makeContainer(String value, int j){
    if(!context.mounted) return Container();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      margin: const EdgeInsets.all(5),
      // height: 85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: Provider.of<ModelTheme>(context, listen: false).getGradient()
      ),
      child: widget.naviKey == Screen.fullTimeTable 
        ? makeFullWidget(value)
        : makeFreeWidget(value)
    );
  }

  Widget makeFullWidget(String value){
    var spliting = value.split("...");
    var classShow = spliting[0];
    var sectionShow = spliting[1].split("\n");
    return Row(
      children: [
        const SizedBox(width: 15,),
        SizedBox(
          width: 80,
          child: Center(child: makeText(classShow))
        ),
        const SizedBox(width: 10,),
        SizedBox(
          width: MediaQuery.of(context).size.width - 115,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                makeText(sectionShow[0]),
                sectionShow.length == 2 ? makeText(sectionShow[1]) : makeText(""),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget makeFreeWidget(String classShow){
    return Center(
      child: Text(
        classShow,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      )
    );
  }
}

Widget makeText(String text){
  return Text(
    text,
    textAlign: TextAlign.center,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    ),
  );
}