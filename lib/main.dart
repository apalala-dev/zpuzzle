import 'package:flutter/material.dart';
import 'package:slide_puzzle/moving-star.dart';
import 'package:slide_puzzle/space-widget.dart';

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
            child: SpaceWidget(
          key: _spaceKey,
          title: 'Space Craft',
        )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("toto");
          setState(() {
            _spaceKey = UniqueKey();
            // var base = MovingStar(Offset(-10, 0), 10, Colors.white, -1, -1, 1);
            // base.changeDirectionToIntersect(
            //     Offset.zero & MediaQuery.of(context).size, 0);
            // print("newMovingStar: $base");
          });
        },
        tooltip: 'Nothing yet',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
