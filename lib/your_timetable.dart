import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:timetable/choose_courses.dart';
import 'package:timetable/enum_screen.dart';
import 'package:timetable/full_free.dart';
import 'package:timetable/navigation_drawer.dart';
import 'package:timetable/timetable_data.dart';
import 'package:timetable/update_checker.dart';

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
  final List<GlobalKey<AnimatedListState>> _animatedListStateKey = [];
  String _daySelectedYourTimeTable = "";
  List<List<Container>> containers = [];
  late TextStyle textStyle;
  int containerIndex = 0;

  List<String> readmeContent = [], days = [];
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
    }
    CheckUpdate(fromNavigation: false, context: context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your TimeTable"),
      ),
      body: loaded
          ? yourTimeTableData.isEmpty ? const Center(child: Text("Please Select Course(s)"),) : buildYourTimeTableScreen() 
          : const Center(child: Text("Please Upload An Excel File")),
      drawer : const MyNavigationDrawer(Screen.yourTimeTable),
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
          child: value.isEmpty ?
          // const Center(
          //   child: Text(
          //     "Free Day",
          //     style: TextStyle(fontSize: 30),
          //   ),
          const AnimatedSlide(
            duration: Duration(milliseconds: 375),
            offset: Offset(0, 0),
            child: Center(
              child: Text(
                "Free Day",
                style: TextStyle(fontSize: 30),
              ),
            ),
          ) :
          // ) :
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
            color: Colors.black,
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
                value.split("\n").length == 2 ? makeYourText(value.split("\n")[1]) : makeYourText(""),
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