import 'dart:math';

import 'package:flutter/material.dart';
import 'package:slide_puzzle/space-widget2.dart';
import 'package:slide_puzzle/ui/size-picker.dart';
import 'package:slide_puzzle/z-widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final AnimationController _doorsController;
  bool _showDoors = false;
  late Animation<Offset> _doorTopEnter;
  late Animation<Offset> _doorBottomEnter;
  late Animation<double> _doorsFlip;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _animationController.addStatusListener((status) {
      print('status: ${status} - ${_animationController.value}');
      if (status == AnimationStatus.dismissed) {
        // Launch the door animation
        setState(() {
          _showDoors = true;
        });
        _doorsController.forward();
      }
    });

    _doorsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    _doorTopEnter =
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(0, 0))
            .animate(
      CurvedAnimation(parent: _doorsController, curve: const Interval(0, 0.2)),
    );
    _doorBottomEnter =
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(0, 0))
            .animate(
      CurvedAnimation(parent: _doorsController, curve: const Interval(0, 0.2)),
    );
    _doorsFlip = Tween<double>(begin: pi / 2, end: 0.0).animate(
      CurvedAnimation(
          parent: _doorsController, curve: const Interval(0.2, 1.0)),
    );

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ZWidget(
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
            gradient: RadialGradient(colors: [Colors.white, Colors.red])),
      ),
      layers: 10,
      depth: 10,
      direction: ZDirection.both,
      belowChild: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(color: Colors.green),
      ),
      aboveChild: Container(
        width: 60,
        height: 60,
        decoration:  BoxDecoration(color: Colors.blue.withOpacity(0.2)),
      ),
      perspective: 5,
      rotationX: pi/4,
      rotationY: pi/4,
      debug: true,
      alignment: Alignment.center,
    );

    return Container(
      child: Transform(
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
                gradient: RadialGradient(colors: [Colors.white, Colors.red])),
          ),
          alignment: Alignment.center,
          // origin: FractionalOffset.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.005)
            ..rotateX(0)
            ..rotateY(pi / 3)
            ..translate(0.0, 0.0, 0)),
      decoration:
          BoxDecoration(border: Border.all(width: 2, color: Colors.black)),
    );

    return Stack(children: [
      const Positioned.fill(
          child: SpaceWidget2(
        title: "Flutter Puzzle Hack",
      )),
      LayoutBuilder(builder: (context, constraints) {
        Size size = Size(constraints.maxWidth, constraints.maxHeight);

        if (_showDoors) {
          return AnimatedBuilder(
            builder: (context, child) {
              return Column(
                children: [
                  Transform.translate(
                    offset: _doorTopEnter.value,
                    child: ZWidget(
                      child: Container(
                        color: Colors.red,
                        height: size.height / 2.0,
                        width: 200,
                      ),
                      belowChild: Container(
                        color: Colors.green.withOpacity(0.3),
                        height: size.height / 2.0,
                        width: 200,
                      ),
                      rotationX: _doorsFlip.value,
                      rotationY: _doorsFlip.value,
                      depth: 10,
                      direction: ZDirection.backwards,
                      layers: 10,
                    ),
                  ),
                  if (false)
                    Transform.translate(
                      child: ZWidget(
                        child: Container(
                          color: Colors.red,
                          height: size.height / 2.0,
                          width: size.width,
                        ),
                        rotationX: _doorsFlip.value,
                        rotationY: 0,
                        depth: 0.05 * size.shortestSide,
                        direction: ZDirection.backwards,
                        layers: 10,
                      ),
                      offset: _doorTopEnter.value,
                    ),
                  Transform.translate(
                    offset: _doorBottomEnter.value,
                    child: ZWidget(
                      child: Container(
                        color: Colors.blue,
                        height: size.height / 2.0,
                        width: 200,
                      ),
                      belowChild: Container(
                        color: Colors.pink.withOpacity(0.3),
                        height: size.height / 2.0,
                        width: 200,
                      ),
                      rotationX: -_doorsFlip.value,
                      rotationY: -_doorsFlip.value,
                      depth: 10,
                      direction: ZDirection.backwards,
                      layers: 10,
                    ),
                  ),
                  // ZWidget(
                  //   origin: Offset(size.width / 2, size.height),
                  //   child: Container(
                  //     color: Colors.blue,
                  //     height: 50,
                  //     width: 100,
                  //   ),
                  //   belowChild: Container(
                  //     color: Colors.pink.withOpacity(0.3),
                  //     height: 50,
                  //     width: 100,
                  //   ),
                  //   aboveChild: Container(
                  //     color: Colors.green.withOpacity(0.3),
                  //     height: size.height / 2.0,
                  //     width: size.width,
                  //   ),
                  //   rotationX: pi / 2,
                  //   rotationY: 0,
                  //   depth: 0.05 * size.shortestSide,
                  //   perspective: 100,
                  //   direction: ZDirection.backwards,
                  //   layers: 10,
                  // ),
                ],
              );
            },
            animation: _doorsController,
          );
        } else {
          return AnimatedBuilder(
            child: _gameSettings(context, size),
            builder: (context, child) {
              return Transform.scale(
                child: child,
                scale: _animationController.value,
              );
            },
            animation: _animationController,
          );
        }
      }),
      ElevatedButton(
          onPressed: () {
            setState(() {
              _showDoors = false;
            });
            _animationController.reset();
            _doorsController.reset();
            _animationController.forward();
          },
          child: Text("Switch anim")),
    ]);
  }

  Widget _gameSettings(BuildContext context, Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(
              size: size.width / 8,
            ),
            Padding(
              child: Text(
                'Flutter Puzzle Hack',
                style: Theme.of(context).textTheme.headline4,
              ),
              padding: EdgeInsets.symmetric(horizontal: size.width / 50),
            ),
            SizedBox(
              width: size.width / 8,
            ),
          ],
        ),
        SizedBox(
          child: SizePicker(onSizePicked: (size) {}),
          height: size.height / 8,
        ),
        Container(),
        ElevatedButton(
            onPressed: () {
              _animationController.reverse();
            },
            child: Text(
              'START',
              style: Theme.of(context)
                  .textTheme
                  .headline5
                  ?.copyWith(color: Colors.white),
            ))
      ],
    );
  }
}
