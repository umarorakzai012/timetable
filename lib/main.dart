import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:timetable/my_preference.dart';
import 'package:timetable/timetable_data.dart';
import 'package:timetable/your_timetable.dart';

import 'model_theme.dart';

late MySelectionPreferences selectionPreferences;
ChooseCourse chooseCourse = ChooseCourse();

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    selectionPreferences = MySelectionPreferences();
    return ChangeNotifierProvider(
      create: (_) => ModelTheme(),
      child: Consumer<ModelTheme>(
        builder: (context, ModelTheme themeNotifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "TimeTable",
            home: const YourTimeTable(),
            theme: themeChanger(themeNotifier),
          );
        },
      ),
    );
  }

  ThemeData themeChanger(ModelTheme themeNotifier) {
    return themeNotifier.isDark
        ? ThemeData(
            useMaterial3: false,
            brightness: Brightness.dark,
          )
        : ThemeData(
            useMaterial3: false,
            brightness: Brightness.light,
            primaryColor: Colors.white,
          );
  }
}
