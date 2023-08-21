import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetable/choose_courses.dart';
import 'package:timetable/enum_screen.dart';
import 'package:timetable/navigation_drawer.dart';
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
  var _daySelected = "", _tileSelected = "";
  List<String> _allSlot = [], days = [];
  bool iCalled = true, callBackDone = false;
  final List<GlobalKey<AnimatedListState>> _animatedListStateKey = [];
  List<List<Container>> containers = [];
  
  int containerIndex = 0;

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
    return WillPopScope(
      onWillPop: pushReplacementToYourTimeTable,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.appBarText),
        ),
        body: loaded && fullTimeTableData.isNotEmpty
            ? buildFullTimeTableScreen()
            : const Center(child: Text("Please Upload An Excel File")),
        drawer: MyNavigationDrawer(widget.naviKey, context),
      ),
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
    days.addAll(fullTimeTableData.keys);
    _animatedListStateKey.add(GlobalKey<AnimatedListState>());
    containers.add([]);

    var date = DateTime.now();
    // print(date); -> 2023-08-14 17:32:00.104376
    if(_daySelected.compareTo("") == 0){
      int index = (date.weekday - 1) >= days.length ? 0 : date.weekday - 1;
      _daySelected = days[index];
    }
    if(fullTimeTableData[_daySelected] == null) {
      return Container();
    }

    _allSlot = fullTimeTableData[_daySelected]!.slots;
    if(_tileSelected.compareTo("") == 0){
      int slotAccordingToCurrentTime = currentSlotShouldBe(date, _allSlot);
      _tileSelected = _allSlot[slotAccordingToCurrentTime];
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(!iCalled) return;
      iCalled = false;
      int index = _allSlot.indexOf(_tileSelected);
      if(index == -1) return;

      Future ft = Future(() {});

      int innerIndex = containerIndex;
      for (var i = 0; i < showDayData[_tileSelected]!.length; i++) {
        ft = ft.then((_) {
          return Future.delayed(const Duration(milliseconds: 50), (){
            if(innerIndex != containerIndex) return;
            
            var cont = makeContainer(i);

            if(innerIndex != containerIndex) return;
            containers[innerIndex].add(cont);
            
            if(innerIndex != containerIndex) return;
            _animatedListStateKey[innerIndex].currentState!.insertItem(containers[innerIndex].length - 1);
          });
        });
      }
      callBackDone = true;
    },);

    for(var key in fullTimeTableData[_daySelected]!.courses.keys){
      var value = fullTimeTableData[_daySelected]!.courses[key]!;
      if(value == "free" && widget.naviKey == Screen.fullTimeTable) {
        continue;
      } else if(value != "free" && widget.naviKey == Screen.freeTimeTable) {
        continue;
      }
      var inside = key.split("...");
      var keyClasses = inside[0];
      keyClasses = keyClasses.substring(0, keyClasses.contains("(") ? keyClasses.indexOf("(") : keyClasses.length);
      var keySlot = inside[1];
      if(_tileSelected.compareTo(keySlot) != 0) continue;
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
    return pageViewBuilder();
  }
  
  String formatSlot(String txt){
    var split = txt.split("-");
    var first = split[0];
    var second = split[1];
    return "${addingColon(first)}-${addingColon(second)}";
  }

  Widget pageViewBuilder() {
    int indexOfCurrentDaySelected = days.indexOf(_daySelected);
    int indexOfCurrentSlotSelected = _allSlot.indexOf(_tileSelected);

    Tween<Offset> tweenSlide = Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0));
    Tween<double> tweenFade = Tween<double>(begin: 0, end: 1);
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 127),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: AnimatedList(
            key: _animatedListStateKey[containerIndex],
            physics: const BouncingScrollPhysics(),
            initialItemCount: containers[containerIndex].length,
            itemBuilder: (context, index, animation) {
              return SlideTransition(
                position: animation.drive(tweenSlide),
                child: FadeTransition(
                  opacity: animation.drive(tweenFade),
                  child: containers[containerIndex][index],
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 127,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 2,
            color: Colors.black,
          ),
        ),
        if(indexOfCurrentSlotSelected != 0) makePositioned(
          bottom: 16, left: 10, onTapChange: _allSlot[indexOfCurrentSlotSelected - 1], data: Icons.arrow_back, isDay: false,
        ),
        if(indexOfCurrentSlotSelected + 1 != _allSlot.length) makePositioned(
          bottom: 16, right: 10, onTapChange: _allSlot[indexOfCurrentSlotSelected + 1], data: Icons.arrow_forward, isDay: false,
        ),
        if(indexOfCurrentDaySelected != 0) makePositioned(
          bottom: 75, left: 10, onTapChange: days[indexOfCurrentDaySelected - 1], data: Icons.arrow_back, isDay: true,
        ),
        if(indexOfCurrentDaySelected + 1 != days.length) makePositioned(
          bottom: 75, right: 10, onTapChange: days[indexOfCurrentDaySelected + 1], data: Icons.arrow_forward, isDay: true,
        ),
        makeDropdownButtonPositioned(bottom: 70, isDay: true),
        makeDropdownButtonPositioned(bottom: 12, isDay: false),
      ],
    );
  }

  Positioned makeDropdownButtonPositioned({
    required double bottom, required bool isDay
  }) {
    var displayList = days;
    var valueList = days;

    if(!isDay){
      valueList = _allSlot;
      displayList = [];
      for (var i = 0; i < _allSlot.length; i++) {
        displayList.add(formatSlot(_allSlot[i]));
      }
    }
    return Positioned(
      bottom: bottom,
      child: Container(
        padding: const EdgeInsets.only(left: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Center(
          child: DropdownButton(
            value: isDay ? _daySelected : _tileSelected,
            underline: const SizedBox(),
            iconSize: 20,
            items: <DropdownMenuItem>[
              for(int i = 0; i < valueList.length; i++)...[
                DropdownMenuItem(
                  value: valueList[i],
                  child: Text(displayList[i], style: const TextStyle(fontSize: 15),),
                )
              ]
            ], 
            onChanged: (value) {
              if(_tileSelected.compareTo(value) == 0) return;
              setState(() {
                iCalled = true;
                _tileSelected = value;
                containerIndex++;
              });
            },
          ),
        ),
      ),
    );
  }

  Positioned makePositioned({required double bottom, double? right, double? left, 
                                required String onTapChange, required IconData data, required bool isDay}){
    String display = onTapChange;
    if(!isDay) display = formatSlot(display);
    return Positioned(
      bottom: bottom,
      right: right,
      left: left,
      child: GestureDetector(
        onTap: () {
          if(!callBackDone) return;
          setState(() {
            iCalled = true;
            callBackDone = false;
            if(isDay){
              _daySelected = onTapChange;
              _tileSelected = "";
            } else {
              _tileSelected = onTapChange;
            }
            containerIndex++;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 7),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              if(data == Icons.arrow_back)...[
                Icon(data, size: 15,),
                Text(display, style: const TextStyle(fontSize: 15),),
              ],
              if(data == Icons.arrow_forward)...[
                Text(display, style: const TextStyle(fontSize: 15),),
                Icon(data, size: 15,),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Container makeContainer(int j){
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      margin: const EdgeInsets.all(5),
      // height: 85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: Provider.of<ModelTheme>(context, listen: false).getGradient()
      ),
      child: widget.naviKey == Screen.fullTimeTable 
        ? makeFullWidget(showDayData[_tileSelected]![j])
        : makeFreeWidget(showDayData[_tileSelected]![j])
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
          // height: 40,
          child: Center(child: makeText(classShow))
        ),
        const SizedBox(width: 10,),
        SizedBox(
          width: MediaQuery.of(context).size.width - 115,
          // height: 40,
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
    return Center(child: makeText(classShow));
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