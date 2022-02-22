import 'package:flutter/material.dart';
import 'package:slide_puzzle/game-screen.dart';
import 'package:slide_puzzle/home-screen.dart';
import 'package:slide_puzzle/moving-star.dart';
import 'package:slide_puzzle/new-game-screen.dart';
import 'package:slide_puzzle/space-widget.dart';
import 'package:slide_puzzle/test-screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Key _spaceKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: true
                ? HomeScreen()
                : NewGameScreen(
                    key: _spaceKey,
                  )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("toto");
          setState(() {
            _spaceKey = UniqueKey();
          });
        },
        tooltip: 'Nothing yet',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
