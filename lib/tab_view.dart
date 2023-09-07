import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetable/model_theme.dart';
import 'package:timetable/navigation_drawer.dart';

class MyTabBar extends StatelessWidget {
  final List<Tab> tabs;
  final List<Widget> display;
  final String? title;
  final int initialIndex;
  final MyNavigationDrawer? drawer;
  const MyTabBar({super.key, required this.tabs, required this.display, this.title, required this.initialIndex, this.drawer});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      initialIndex: initialIndex,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: title == null 
          ? TabBar(
              tabs: tabs,
              isScrollable: true,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: Provider.of<ModelTheme>(context, listen: false).getGradient()
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              labelStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ) 
          : Text(title!),
          bottom: title == null 
          ? null 
          : TabBar(
              tabs: tabs,
              isScrollable: true,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: Provider.of<ModelTheme>(context, listen: false).getGradient()
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              labelStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
        ),
        body: TabBarView(children: display),
        drawer: drawer,
      )
    );
  }
}