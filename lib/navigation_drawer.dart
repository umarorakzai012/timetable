import 'package:flutter/material.dart';
import 'package:timetable/choose_courses.dart';
import 'package:timetable/full_free.dart';
import 'package:timetable/settings.dart';
import 'package:timetable/upload_timetable.dart';

import 'enum_screen.dart';
import 'your_timetable.dart';

class MyNavigationDrawer extends StatelessWidget {
  final Screen _currentScreen;
  final BuildContext _naviContext;
  const MyNavigationDrawer(this._currentScreen, this._naviContext, {super.key});

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
          decoration: _currentScreen == Screen.yourTimeTable ? BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color.fromARGB(85, 68, 137, 255),
          ) : null,
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
          padding: const EdgeInsets.symmetric(vertical: 2,),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: _currentScreen == Screen.fullTimeTable ? BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color.fromARGB(85, 68, 137, 255),
          ) : null,
          child: ListTile(
            title: const Text("Full TimeTable"),
            leading: const Icon(Icons.view_timeline),
            selected: _currentScreen == Screen.fullTimeTable,
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const FullFree(Screen.fullTimeTable, "Full TimeTable", "Free Slot"),
                maintainState: false,
              ));
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2,),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: _currentScreen == Screen.freeTimeTable ? BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color.fromARGB(85, 68, 137, 255),
          ) : null,
          child: ListTile(
            title: const Text("Free Classes"),
            leading: const Icon(Icons.free_cancellation),
            selected: _currentScreen == Screen.freeTimeTable,
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const FullFree(Screen.freeTimeTable, "Full TimeTable", "Free Slot"),
                maintainState: false,
              ));
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2,),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: _currentScreen == Screen.courseList ? BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color.fromARGB(85, 68, 137, 255),
          ) : null,
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
          padding: const EdgeInsets.symmetric(vertical: 2,),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: _currentScreen == Screen.uploadExcel ? BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color.fromARGB(85, 68, 137, 255),
          ) : null,
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
          padding: const EdgeInsets.symmetric(vertical: 2,),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: _currentScreen == Screen.settings ? BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color.fromARGB(85, 68, 137, 255),
          ) : null,
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
        const Divider(thickness: 2,),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2,),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          child: ListTile(
            title: const Text("Privacy Policy"),
            leading: const Icon(Icons.privacy_tip),
            onTap: () {
              showDialog(
                context: _naviContext,
                builder: (context) {
                  return AlertDialog(
                    title: const Center(child: Text("Privacy Policy")),
                    content: const SingleChildScrollView(child: Text("Thank you for using TimeTable. This Privacy Policy is intended to inform you about the data practices of our App.\n\nData Collection and Usage\n\nOur App is designed to enhance your experience by providing features to extract data from Excel files and presenting it in a user-friendly way. To provide this functionality, the App may require access to the following permissions:\n\n- Internet Access: The App requires access to the internet to download APK updates.\n\n- Storage Access: The App requires access to your device's storage to save downloaded APK updates and temporary Excel files for processing. The App also allows you to upload Excel files from your local storage for processing within the App.\n\nNo Personal Data Collection\n\nWe want to assure you that we do not collect, store, or transmit any personal data or personally identifiable information while you use our App. This includes information such as your name, email address, phone number, or any other personal details.\n\nExcel File Processing\n\nThe App's primary purpose is to process Excel files provided by you. The App reads the content of these files solely for the purpose of extracting and presenting data in a better way. The content of the Excel files is not transmitted to any external servers.\n\nAPK Updates\n\nOur App provides the convenience of downloading and installing updates from the internet. The App will download the latest APK update from a trusted source and install it. The update process may involve accessing the internet, but no personal data is collected during this process.\n\nChanges to This Privacy Policy\n\nWe reserve the right to update or modify this Privacy Policy at any time. Any changes will be updated here and the 'Last updated' date will be adjusted accordingly. Your continued use of the App after any changes to this Privacy Policy constitutes your acceptance of such changes.\n\nLast updated: 10th August, 2023")),
                    actions: <Widget>[
                      ElevatedButton(
                        child: const Text("Close"),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ); 
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
