import 'package:flutter/material.dart';
import 'package:slide_puzzle/z-widget.dart';

class TestScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TestScreenState();
  }
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ZWidget(
        rotationY: 0,
        rotationX: -0.5,
        depth: 0.05 * 400,
        direction: ZDirection.backwards,
        layers: 10,
        child: Stack(children: [
          Container(
            color: Colors.pink,
            width: 50,
            height: 50,
          ),
          Transform(
              child: Container(
                color: Colors.green,
                width: 50,
                height: 50,
              ),
              transform: Matrix4.identity()..translate(0.0, 0.0, -40)),
        ]),
      ),
    );
  }
}
