import 'package:flutter/material.dart';
import 'package:timetable/choose_courses.dart';
import 'package:timetable/full_timetable.dart';
import 'package:timetable/settings.dart';
import 'package:timetable/upload_timetable.dart';

import 'free_classes.dart';
import 'your_timetable.dart';

class MyNavigationDrawer extends StatelessWidget {
  final int _screenSelected;
  const MyNavigationDrawer(this._screenSelected ,{super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            buildHeader(),
            const SizedBox(height: 8,),
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
      child: const Image(image: AssetImage("assets/splash_screen.png"), height: 200, width: 500,),
    );
  }

  Widget buildMenuItems(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2,),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: _screenSelected == 0 ? BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color.fromARGB(85, 68, 137, 255),
          ) : null,
          child: ListTile(
            title: const Text("Your TimeTable"),
            leading: const Icon(Icons.timeline),
            selected: _screenSelected == 0,
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const YourTimeTable(),
              ));
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2,),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: _screenSelected == 1 ? BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color.fromARGB(85, 68, 137, 255),
          ) : null,
          child: ListTile(
            title: const Text("Full TimeTable"),
            leading: const Icon(Icons.view_timeline),
            selected: _screenSelected == 1,
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const FullTimeTable(),
              ));
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2,),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: _screenSelected == 5 ? BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color.fromARGB(85, 68, 137, 255),
          ) : null,
          child: ListTile(
            title: const Text("Free Classes"),
            leading: const Icon(Icons.free_cancellation),
            selected: _screenSelected == 5,
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const FreeClassesScreen(),
              ));
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2,),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: _screenSelected == 2 ? BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color.fromARGB(85, 68, 137, 255),
          ) : null,
          child: ListTile(
            title: const Text("Choose Course"),
            leading: const Icon(Icons.check_box),
            selected: _screenSelected == 2,
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const ChooseCourseScreen(),
              ));
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2,),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: _screenSelected == 3 ? BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color.fromARGB(85, 68, 137, 255),
          ) : null,
          child: ListTile(
            title: const Text("Upload TimeTable"),
            leading: const Icon(Icons.file_upload),
            selected: _screenSelected == 3,
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const UploadTimeTableScreen(),
              ));
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2,),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: _screenSelected == 4 ? BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color.fromARGB(85, 68, 137, 255),
          ) : null,
          child: ListTile(
            title: const Text("Settings"),
            leading: const Icon(Icons.settings),
            selected: _screenSelected == 4,
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const SettingScreen(),
              ));
            },
          ),
        ),
      ],
    );
  }
}
