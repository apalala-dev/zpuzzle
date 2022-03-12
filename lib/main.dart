import 'package:flutter/material.dart';
import 'package:flutter_color/flutter_color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zpuzzle/app_colors.dart';
import 'package:zpuzzle/home_screen.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  late ThemeData _themeData;

  @override
  initState() {
    _themeData = ThemeData(
      primarySwatch: createMaterialColor(AppColors.primaryColor),
      // Dark theme is not well handled so we need to use deprecated attributes
      accentColor: Colors.teal[300],
      toggleableActiveColor: Colors.teal[500],
      textSelectionColor: Colors.teal[200],
      primaryColor: AppColors.primaryColor,
      primaryColorDark: AppColors.primaryColor.darker(20),
      primaryColorLight: AppColors.primaryColor.lighter(20),
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.primaryColor,
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
    super.initState();
  }

  changeTheme() {
    setState(() {
      _themeData = ThemeData(
        primarySwatch: createMaterialColor(AppColors.primaryColor),
        accentColor: Colors.teal[300],
        toggleableActiveColor: Colors.teal[500],
        textSelectionColor: Colors.teal[200],
        primaryColor: AppColors.primaryColor,
        primaryColorDark: AppColors.primaryColor.darker(20),
        primaryColorLight: AppColors.primaryColor.lighter(20),
        brightness: _themeData.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        scaffoldBackgroundColor: AppColors.primaryColor,
        dialogTheme: DialogTheme(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZPuzzle',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: _themeData,
      home: HomeScreen(changeTheme: changeTheme),
    );
  }

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
