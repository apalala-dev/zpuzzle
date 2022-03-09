import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_color/flutter_color.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:slide_puzzle/app-colors.dart';
import 'package:slide_puzzle/home-screen.dart';
import 'package:slide_puzzle/ui/background/fog.dart';
import 'package:slide_puzzle/ui/background/moving-star.dart';
import 'package:slide_puzzle/new-game-screen.dart';
import 'package:slide_puzzle/ui/background/space-widget.dart';
import 'package:slide_puzzle/test-screen.dart';

Future<void> main() async {
  // debugRepaintRainbowEnabled = true;

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
      // colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor, brightness: Brightness.dark),
      accentColor: Colors.teal[300],
      toggleableActiveColor: Colors.teal[500],
      textSelectionColor: Colors.teal[200],
      // primarySwatch: MaterialColor(AppColors.primaryColor.value, <int, Color>{
      //   50: AppColors.primaryColor.withOpacity(0.1), //10%
      //   100: AppColors.primaryColor.withOpacity(0.2), //20%
      //   200: AppColors.primaryColor.withOpacity(0.3), //30%
      //   300: AppColors.primaryColor.withOpacity(0.4), //40%
      //   400: AppColors.primaryColor.withOpacity(0.5), //50%
      //   500: AppColors.primaryColor.withOpacity(0.6), //60%
      //   600: AppColors.primaryColor.withOpacity(0.7), //70%
      //   700: AppColors.primaryColor.withOpacity(0.8), //80%
      //   800: AppColors.primaryColor.withOpacity(0.9), //90%
      //   900: AppColors.primaryColor, //100%
      // }),
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
      print('boo');
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
      // _themeData.copyWith(
      //     brightness: _themeData.brightness == Brightness.dark
      //         ? Brightness.light
      //         : Brightness.dark);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner: true,
      // checkerboardOffscreenLayers: true,
      // checkerboardRasterCacheImages: true,
      title: 'ZPuzzle',
      theme: _themeData,
      home: HomeScreen(changeTheme: changeTheme),
      builder: (context, child) => Container(
          child: ResponsiveWrapper.builder(
            child,
            maxWidth: 800,
            minWidth: 480,
            defaultScale: true,
            breakpoints: [
              ResponsiveBreakpoint.resize(480, name: MOBILE),
              ResponsiveBreakpoint.autoScale(800, name: TABLET),
              ResponsiveBreakpoint.resize(1000, name: DESKTOP),
              ResponsiveBreakpoint.autoScale(2460, name: '4K'),
            ],
            background: Container(color: Colors.blue),
          ),
          color: Colors.blue),
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
