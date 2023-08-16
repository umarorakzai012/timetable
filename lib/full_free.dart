import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetable/choose_courses.dart';
import 'package:timetable/enum_screen.dart';
import 'package:timetable/navigation_drawer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
  // ItemScrollController ctr = ItemScrollController(), daysCtr = ItemScrollController();
  ScrollController ctr = ScrollController(), daysCtr = ScrollController();
  var _daySelected = "", _tileSelected = "";
  List<String> _allSlot = [], days = [];
  final PageController _pageController = PageController(keepPage: false);
  bool _dayChanged = true, firstTime = true, fromOnTap = false;

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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _myScrollToIndex(_daySelected, days, daysCtr, 56, firstTime, false);
      _myScrollToIndex(_tileSelected, _allSlot, ctr, 41, firstTime, true);
      // print(_tileSelected); -----------> Wrong here
      // _scrollToIndex(_daySelected, days.indexOf(_daySelected), daysCtr, 56, firstTime);
      // _scrollToIndex(show, _allSlot.indexOf(_tileSelected), ctr, 41, _dayChanged);
      // print("$_tileSelected");
      if(_allSlot.indexOf(_tileSelected) == _pageController.page) _dayChanged = false;
      if(_dayChanged) _pageController.jumpToPage(_allSlot.indexOf(_tileSelected));
      firstTime = false;
    },);
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
    var date = DateTime.now();
    // print(date); -> 2023-08-14 17:32:00.104376
    if(_daySelected.compareTo("") == 0){
      int index = (date.weekday - 1) >= days.length ? 0 : date.weekday - 1;
      _daySelected = days[index];
    }
    if(fullTimeTableData[_daySelected] == null) {
      return const Text("");
    }
    _allSlot = fullTimeTableData[_daySelected]!.slots;
    if(_tileSelected.compareTo("") == 0){
      // _pageController.dispose();
      int slotAccordingToCurrentTime = currentSlotShouldBe(date, _allSlot);
      // _pageController = PageController(initialPage: slotAccordingToCurrentTime, keepPage: false);
      _tileSelected = _allSlot[slotAccordingToCurrentTime];
    } 
    // else {
      // _pageController.dispose();
      // _pageController = PageController(initialPage: _allSlot.indexOf(_tileSelected), keepPage: false);
    // }

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
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: daysBuilder(),
        ),
        pageViewBuilder(),
      ],
    );
  }

  Widget pageViewBuilder() {
    return Stack(
      children: <Widget>[
        SizedBox(
          height: 40,
          // child: ScrollablePositionedList.builder(
          child: ListView.builder(
            controller: ctr,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: fullTimeTableData[_daySelected] == null
                ? 0
                : fullTimeTableData[_daySelected]!.slots.length,
            itemBuilder: (context, index) {
              var comp = _tileSelected.compareTo(_allSlot[index]) == 0;
              var show = formattingSlots(_allSlot[index]);
              final Size txtSize = _textSize(show, const TextStyle(fontWeight: FontWeight.bold, fontSize: 15,));
              return AnimatedContainer(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                curve: Curves.linear,
                duration: const Duration(milliseconds: 375),
                width: txtSize.width + 35,
                decoration: BoxDecoration(
                  gradient: comp ? Provider.of<ModelTheme>(context).getGradient() : null,
                  borderRadius: comp ? BorderRadius.circular(15) : null,
                ),
                child: ListTile(
                  title: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Center(child: makeText(show))
                  ),
                  onTap: () {
                    if(_tileSelected.compareTo(_allSlot[index]) == 0) return;
                    setState(() {
                      _tileSelected = _allSlot[index];
                      // print(_tileSelected); ----------> Correct Here
                      // shouldJumpTo = true;
                      fromOnTap = true;
                      _pageController.jumpToPage(index);
                    });
                  },
                ),
              );
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 45),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: PageView.builder(
              controller: _pageController,
              itemCount: fullTimeTableData[_daySelected] == null
                  ? 0
                  : fullTimeTableData[_daySelected]!.slots.length,
              itemBuilder: (context, i) {
                if(!showDayData.containsKey(_allSlot[i])){
                  return Center(
                    child: Text(
                      widget.emptySlot,
                      style: const TextStyle(fontSize: 30),
                    ),
                  );
                }
                return SizedBox(
                  width: 150,
                  child: AnimationLimiter(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: showDayData[_allSlot[i]]!.length,
                      itemBuilder: (context, j) {
                        return AnimationConfiguration.staggeredList(
                          position: j,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Container(
                                padding: const EdgeInsets.all(30),
                                margin: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: Provider.of<ModelTheme>(context).getGradient()
                                ),
                                child: widget.naviKey == Screen.fullTimeTable 
                                  ? makeFullWidget(showDayData[_allSlot[i]]![j])
                                  : makeFreeWidget(showDayData[_allSlot[i]]![j])
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              onPageChanged: (value) {
                // if(shouldJumpTo || jumpToAtEndOfFrame){
                //   jumpToAtEndOfFrame = false;
                //   shouldJumpTo = false;
                //   return;
                // }
                if(_dayChanged || fromOnTap){
                  _dayChanged = false;
                  fromOnTap = false;
                  return;
                }
                // print("before if $_tileSelected"); ---> Correct
                if(_tileSelected.compareTo(_allSlot[value]) == 0) return;
                // print("after if $_tileSelected"); ---> Correct
                setState(() {
                  _tileSelected = _allSlot[value];
                });
                // print("after setState $_tileSelected"); ---> Wrong
              },
            ),
          ),
        ),
      ],
    );
  }

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  // void _scrollToIndex(String txt, int index, ItemScrollController ctr, int additional, bool jump) {
  //   var style = const TextStyle(fontWeight: FontWeight.bold, fontSize: 15,);
  //   final Size txtSize = _textSize(txt, style);
  //   var offset = (txtSize.width + additional) / MediaQuery.of(context).size.width;
  //   if(jump) {
  //     ctr.jumpTo(index: index, alignment: 0.5 - offset / 2);
  //   } else {
  //     ctr.scrollTo(index: index, duration: const Duration(milliseconds: 375), alignment: 0.5 - offset / 2);
  //   }
  // }
  void _myScrollToIndex(String txt, List<String> txts, ScrollController scr, int additional, bool jump, bool doFormatting) {
    int index = txts.indexOf(txt);
    double sum = 0;
    for (var i = 0; i < index; i++) {
      if(doFormatting) {
        sum += calculatePixels(formattingSlots(txts[i]), additional);
      } else {
        sum += calculatePixels(txts[i], additional);
      }
    }
    double offset = doFormatting ? calculatePixels(formattingSlots(txt), additional) : calculatePixels(txt, additional);
    sum -= MediaQuery.of(context).size.width / 2 - (offset / 2);
    if(sum < 0) sum = 0;
    if(jump) {
      scr.jumpTo(sum);
    } else {
      scr.animateTo(sum, duration: const Duration(milliseconds: 375), curve: Curves.linear);
    }
  }

  double calculatePixels(String txt, int additional) {
    var style = const TextStyle(fontWeight: FontWeight.bold, fontSize: 15,);
    final Size txtSize = _textSize(txt, style);
    var offset = (txtSize.width + additional);
    return offset;
  }

  Widget daysBuilder() {
    // return ScrollablePositionedList.builder(
    return ListView.builder(
      controller: daysCtr,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: days.length,
      itemBuilder: (context, index) {
        bool comp = _daySelected.compareTo(days[index]) == 0;
        final Size txtSize = _textSize(days[index], const TextStyle(fontWeight: FontWeight.bold, fontSize: 15,));
        return AnimatedContainer(
          curve: Curves.linear,
          duration: const Duration(milliseconds: 375),
          width: txtSize.width + 40,
          margin: const EdgeInsets.only(bottom: 6, left: 8, right: 8, top: 3),
          decoration: BoxDecoration(
            borderRadius: comp ? BorderRadius.circular(25) : null,
            gradient: comp ? Provider.of<ModelTheme>(context).getGradient() : null
          ),
          child: ListTile(
            title: Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Center(child: makeText(days[index]))
            ),
            onTap: () {
              if(_daySelected.compareTo(days[index]) == 0) return;
              setState(() {
                _daySelected = days[index];
                _allSlot = fullTimeTableData[_daySelected]!.slots;
                _tileSelected = "";
                _dayChanged = true;
                // jumpToAtEndOfFrame = true;
              });
            },
          ),
        );
      },
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

Widget makeFullWidget(String value){
  var spliting = value.split("...");
  var classShow = spliting[0];
  var sectionShow = spliting[1].replaceAll("\n", " ");
  return Row(
    children: [
      SizedBox(
        width: 80,
        child: Center(child: makeText(classShow))
      ),
      const SizedBox(width: 25,),
      Expanded(child: makeText(sectionShow)),
    ],
  );
}

Widget makeFreeWidget(String classShow){
  return Center(child: makeText(classShow));
}