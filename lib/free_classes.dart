import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:timetable/navigation_drawer.dart';

import 'choose_courses.dart';
import 'full_timetable.dart';
import 'model_theme.dart';

class FreeClassesScreen extends StatefulWidget{
  const FreeClassesScreen({super.key});

  @override
  State<FreeClassesScreen> createState() => _FreeClassesScreenState();
}

var _daySelected = "";
List<String> _allSlot = [];
String _tileSelected = "";
PageController _pageController = PageController();
bool dayChanged = false;

class _FreeClassesScreenState extends State<FreeClassesScreen> {
  var days = [];
  Map<String, List<String>> showDayData = {};
  ItemScrollController ctr = ItemScrollController();
  ItemScrollController daysCtr = ItemScrollController();

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(fullTimeTableData.isNotEmpty){
        var style = const TextStyle(fontWeight: FontWeight.bold, fontSize: 15,);
        final Size txtSize = _textSize(_daySelected, style);
        var offset = (txtSize.width + 56) / MediaQuery.of(context).size.width;
        daysCtr.jumpTo(index: days.indexOf(_daySelected), alignment: 0.5 - offset / 2);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Free Classes"),
      ),
      body: loaded && fullTimeTableData.isNotEmpty
          ? buildFreeClassesScreen()
          : const Center(child: Text("Please Upload An Excel File First")),
      drawer: const MyNavigationDrawer(5),
    );
  }
  
  Widget buildFreeClassesScreen() {
    days.clear();
    showDayData.clear();
    for (var day in fullTimeTableData.keys) {
      days.add(day);
    }
    if(_daySelected.compareTo("") == 0 || !dayChanged){
      int index = (DateTime.now().weekday - 1) >= days.length ? 0 : DateTime.now().weekday - 1;
      _daySelected = days[index];
    }
    dayChanged = false;
    if(fullTimeTableData[_daySelected] == null) {
      return const Text("");
    }
    _allSlot = fullTimeTableData[_daySelected]!.slots;
    if(_tileSelected.compareTo("") == 0){
      _pageController = PageController(initialPage: 0);
      _tileSelected = _allSlot[0];
    } else {
      _pageController = PageController(initialPage: _allSlot.indexOf(_tileSelected));
    }

    for(var key in fullTimeTableData[_daySelected]!.courses.keys){
      var value = fullTimeTableData[_daySelected]!.courses[key]!;
      if(value.compareTo("free") != 0) continue;
      var inside = key.split("...");
      var keyClasses = inside[0];
      keyClasses = keyClasses.substring(0, keyClasses.contains("(") ? keyClasses.indexOf("(") : keyClasses.length);
      var keySlot = inside[1];
      if(showDayData.containsKey(keySlot)){
        showDayData[keySlot]!.add(keyClasses);
      } else {
        showDayData[keySlot] = [keyClasses];
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
          child: ScrollablePositionedList.builder(
            itemScrollController: ctr,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: fullTimeTableData[_daySelected] == null
                ? 0
                : fullTimeTableData[_daySelected]!.slots.length,
            itemBuilder: (context, index) {
              var comp = _tileSelected.compareTo(_allSlot[index]) == 0;
              var splited = _allSlot[index].split("-");
              var first = splited[0];
              var end = splited[1];
              if(!first.contains(":")){
                first = "$first:00";
              }
              if(!end.contains(":")){
                end = "$end:00";
              }
              var show = "$first-$end";
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
                    setState(() {
                      dayChanged = true;
                      _tileSelected = _allSlot[index];
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
            height: MediaQuery.of(context).size.height - 180,
            child: PageView.builder(
              controller: _pageController,
              itemCount: fullTimeTableData[_daySelected] == null
                  ? 0
                  : fullTimeTableData[_daySelected]!.slots.length,
              itemBuilder: (context, i) {
                return SizedBox(
                  width: 150,
                  child: AnimationLimiter(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: showDayData[_allSlot[i]]!.length,
                      itemBuilder: (context, j) {
                        var classShow = showDayData[_allSlot[i]]![j];
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
                                child: Center(child: makeText(classShow)),
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
                dayChanged = true;
                var splited = _allSlot[value].split("-");
                var first = splited[0];
                var end = splited[1];
                if(!first.contains(":")){
                  first = "$first:00";
                }
                if(!end.contains(":")){
                  end = "$end:00";
                }
                var show = "$first-$end";
                setState(() {
                  _tileSelected = _allSlot[value];
                  _scrollToIndex(show, value, ctr, 41);
                });
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

  void _scrollToIndex(String txt, index, ItemScrollController ctr, int additional) {
    var style = const TextStyle(fontWeight: FontWeight.bold, fontSize: 15,);
    final Size txtSize = _textSize(txt, style);
    var offset = (txtSize.width + additional) / MediaQuery.of(context).size.width;
    ctr.scrollTo(index: index, duration: const Duration(milliseconds: 375), alignment: 0.5 - offset / 2);
  }

  Widget daysBuilder() {
    return ScrollablePositionedList.builder(
      itemScrollController: daysCtr,
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
              setState(() {
                dayChanged = true;
                _scrollToIndex(days[index], index, daysCtr, 56);
                _daySelected = days[index];
                _tileSelected = fullTimeTableData[_daySelected]!.slots[0];
                _pageController.jumpToPage(0);
              });
            },
          ),
        );
      },
    );
  }

  Widget makeText(String text){
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    );
  }
}