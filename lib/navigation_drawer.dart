import 'package:flutter/material.dart';
import 'package:timetable/choose_courses.dart';
import 'package:timetable/full_free.dart';
import 'package:timetable/settings.dart';
import 'package:timetable/upload_timetable.dart';

import 'enum_screen.dart';
import 'your_timetable.dart';

class MyNavigationDrawer extends StatelessWidget {
  final Screen _currentScreen;
  const MyNavigationDrawer(this._currentScreen, {super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            buildHeader(),
            const SizedBox(
              height: 8,
            ),
            buildMenuItems(context),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      color: Colors.indigo,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: const Image(
        image: AssetImage("assets/splash_screen.png"),
        height: 200,
        width: 500,
      ),
    );
  }

  Widget buildMenuItems(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 2,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: _currentScreen == Screen.yourTimeTable
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color.fromARGB(85, 68, 137, 255),
                )
              : null,
          child: ListTile(
            title: const Text("Your TimeTable"),
            leading: const Icon(Icons.timeline),
            selected: _currentScreen == Screen.yourTimeTable,
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const YourTimeTable(),
                maintainState: false,
              ));
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 2,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: _currentScreen == Screen.fullTimeTable
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color.fromARGB(85, 68, 137, 255),
                )
              : null,
          child: ListTile(
            title: const Text("Full TimeTable"),
            leading: const Icon(Icons.view_timeline),
            selected: _currentScreen == Screen.fullTimeTable,
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const FullFree(
                    Screen.fullTimeTable, "Full TimeTable", "Free Slot"),
                maintainState: false,
              ));
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 2,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: _currentScreen == Screen.freeTimeTable
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color.fromARGB(85, 68, 137, 255),
                )
              : null,
          child: ListTile(
            title: const Text("Free Classes"),
            leading: const Icon(Icons.free_cancellation),
            selected: _currentScreen == Screen.freeTimeTable,
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const FullFree(
                    Screen.freeTimeTable, "Free Classes", "No Free Classes"),
                maintainState: false,
              ));
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 2,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: _currentScreen == Screen.courseList
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color.fromARGB(85, 68, 137, 255),
                )
              : null,
          child: ListTile(
            title: const Text("Choose Course"),
            leading: const Icon(Icons.check_box),
            selected: _currentScreen == Screen.courseList,
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const ChooseCourseScreen(),
                maintainState: false,
              ));
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 2,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: _currentScreen == Screen.uploadExcel
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color.fromARGB(85, 68, 137, 255),
                )
              : null,
          child: ListTile(
            title: const Text("Upload TimeTable"),
            leading: const Icon(Icons.file_upload),
            selected: _currentScreen == Screen.uploadExcel,
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const UploadTimeTableScreen(),
                maintainState: false,
              ));
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 2,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: _currentScreen == Screen.settings
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color.fromARGB(85, 68, 137, 255),
                )
              : null,
          child: ListTile(
            title: const Text("Settings"),
            leading: const Icon(Icons.settings),
            selected: _currentScreen == Screen.settings,
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const SettingScreen(),
                maintainState: false,
              ));
            },
          ),
        ),
      ],
    );
  }
}
