import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetable/enum_screen.dart';
import 'package:timetable/main.dart';
import 'package:timetable/navigation_drawer.dart';

import 'model_theme.dart';

class SettingScreen extends StatefulWidget{
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Setting"),
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
          )
        ],
      ),
      drawer: MyNavigationDrawer(Screen.settings, context),
    );
  }
}