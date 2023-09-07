import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetable/enum_screen.dart';
import 'package:timetable/main.dart';
import 'package:timetable/navigation_drawer.dart';
import 'package:timetable/update_checker.dart';
import 'package:timetable/your_timetable.dart';

import 'model_theme.dart';

class SettingScreen extends StatefulWidget{
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  
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
          title: const Text("Settings"),
        ),
        body: ListView(
          children: <Widget>[
            SwitchListTile(
              title: const Text("Theme"),
              secondary: Icon(Provider.of<ModelTheme>(context).isDark ? Icons.dark_mode : Icons.light_mode),
              subtitle: const Text("Sets the theme of the app."),
              value: Provider.of<ModelTheme>(context).isDark,
              onChanged: (value) {
                Provider.of<ModelTheme>(context, listen: false).setDark(value);
              },
            ),
            const SizedBox(height: 20,),
            SwitchListTile(
              title: const Text("Keep Selection"),
              secondary: const Icon(Icons.autorenew),
              subtitle: const Text("Keeps the course list selection across different uploads."),
              isThreeLine: true,
              value: selectionPreferences.isSelection,
              onChanged: (value) {
                setState(() {
                  selectionPreferences.setSelection(value);
                });
              },
            ),
            const Divider(thickness: 2,),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 1,),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: ListTile(
                title: const Text("Privacy Policy"),
                leading: const Icon(Icons.privacy_tip),
                onTap: () {
                  showDialog(
                    context: context,
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
            Container(
              padding: const EdgeInsets.symmetric(vertical: 1,),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: ListTile(
                title: const Text("Check For Update"),
                leading: const Icon(Icons.system_update),
                onTap: () {
                  CheckUpdate(fromNavigation: true, context: context); 
                },
              ),
            ),
          ],
        ),
        drawer: const MyNavigationDrawer(Screen.settings),
      ),
    );
  }
}