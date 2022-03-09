import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slide_puzzle/model/tile.dart';
import 'package:slide_puzzle/ui/board-content.dart';
import 'package:slide_puzzle/ui/settings/background-picker.dart';
import 'package:slide_puzzle/ui/settings/background-widget-picker.dart';
import 'package:zwidget/zwidget.dart';

import 'model/position.dart';
import 'model/puzzle-solver.dart';
import 'model/puzzle.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<TestScreen> with TickerProviderStateMixin {
  bool _solving = false;
  late Puzzle _puzzle;
  int _puzzleSize = 2;
  StreamSubscription<int>? _nbMovesListener;

  Widget? _selectedWidget;

  final totalAnim = 8000;
  final tileEnterAnimTile = 700;

  _initPuzzle({bool puzzleOnly = false}) {
    print('make puzzle $_puzzleSize * $_puzzleSize');
    _puzzle = Puzzle.generate(_puzzleSize, shuffle: true);
    _nbMovesListener?.cancel();
    _nbMovesListener = _puzzle.nbMovesStream.listen((e) {
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _initPuzzle();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _focusNode.requestFocus();
    });
  }

  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 200,
        child: BackgroundWidgetPicker(
            onBackgroundPicked: (child) => setState(() {
                  _selectedWidget = child;
                })),
      ),
      Expanded(
          child: Row(children: [
        Expanded(
          child: KeyboardListener(
            focusNode: _focusNode,
            onKeyEvent: (event) {
              if (event is KeyDownEvent && !_solving) {
                final keyboardKey = event.logicalKey;
                final white = _puzzle.getWhitespaceTile();
                Position? newPosition;
                if (keyboardKey == LogicalKeyboardKey.arrowLeft) {
                  newPosition =
                      white.currentPosition + const Position(x: 1, y: 0);
                } else if (keyboardKey == LogicalKeyboardKey.arrowRight) {
                  newPosition =
                      white.currentPosition + const Position(x: -1, y: 0);
                } else if (keyboardKey == LogicalKeyboardKey.arrowUp) {
                  newPosition =
                      white.currentPosition + const Position(x: 0, y: 1);
                } else if (keyboardKey == LogicalKeyboardKey.arrowDown) {
                  newPosition =
                      white.currentPosition + const Position(x: 0, y: -1);
                }
                if (newPosition != null) {
                  if (newPosition.x > 0 &&
                      newPosition.y > 0 &&
                      newPosition.x <= _puzzle.getDimension() &&
                      newPosition.y <= _puzzle.getDimension()) {
                    onTileMoved(_puzzle.tiles.firstWhere(
                        (element) => element.currentPosition == newPosition));
                  }
                }
              }
            },
            child: Stack(children: [
              // const Positioned.fill(
              //     child: SpaceWidget2(
              //   title: "Flutter Puzzle Hack",
              // )),
              LayoutBuilder(builder: (context, constraints) {
                Size size = Size(constraints.maxWidth, constraints.maxHeight);
                return _gameLayout(size);
              })
            ]),
          ),
        )
      ]))
    ]);
  }

  Widget _startedControls(Size size, {double xTilt = 0, double yTilt = 0}) {
    bool showDepth = xTilt != 0 || yTilt != 0;
    Color shadowColor = showDepth ? Colors.grey : Colors.black;
    final _space = SizedBox(height: size.height / 100);

    return Container(
      key: const ValueKey(1),
      padding: EdgeInsets.symmetric(
          horizontal: size.shortestSide / 24,
          vertical: size.shortestSide / 100),
      height: size.shortestSide / 3.3,
      width: max(size.shortestSide / 3, 200),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size.shortestSide / 40)),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        ZWidget(
          midChild: Text('ZPuzzle',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.shortestSide / 26,
                  fontWeight: FontWeight.bold,
                  color: shadowColor)),
          topChild: Text('ZPuzzle',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.shortestSide / 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              )),
          depth: 20,
          direction: ZDirection.forwards,
          layers: showDepth ? 5 : 0,
          rotationY: yTilt,
          rotationX: xTilt,
        ),
        _space,
        ZWidget(
          midChild: Text.rich(TextSpan(
              children: [
                TextSpan(
                    text: "${_puzzle.history.length}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(text: " Moves | "),
                const TextSpan(
                    text: "00:01:17",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.shortestSide / 34,
                  color: shadowColor))),
          topChild: Text.rich(TextSpan(
              children: [
                TextSpan(
                    text: "${_puzzle.history.length}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(text: " Moves | "),
                const TextSpan(
                    text: "00:01:17",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                // TextSpan(
                //     text: "${_puzzle.tiles.length - 1}",
                //     style: const TextStyle(fontWeight: FontWeight.bold)),
                // TextSpan(text: " Tiles"),
              ],
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.shortestSide / 40,
                  color: Colors.black))),
          direction: ZDirection.forwards,
          layers: showDepth ? 5 : 0,
          depth: 20,
          rotationX: xTilt,
          rotationY: yTilt,
        ),
        _space,
        Row(mainAxisSize: MainAxisSize.min, children: [
          ZWidget(
            layers: showDepth ? 5 : 0,
            depth: 20,
            rotationX: xTilt,
            rotationY: yTilt,
            midChild: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, anim) {
                return ScaleTransition(
                  child: child,
                  scale: anim,
                );
              },
              child: _solving
                  ? OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32)),
                          primary: Colors.blue,
                          side: const BorderSide(width: 2, color: Colors.blue)),
                      onPressed: () {
                        setState(() {
                          _solving = false;
                        });
                      },
                      icon: const Icon(Icons.stop),
                      label: const Text("CANCEL"),
                    )
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32))),
                      onPressed: () {
                        _solve();
                      },
                      icon: const Icon(Icons.extension),
                      label: const Text("SOLVE"),
                    ),
            ),
          )
        ]),
      ]),
    );
  }

  _solve() async {
    setState(() {
      _solving = true;
    });
    PuzzleSolver solver = PuzzleSolver();
    var newPuzzle = solver.solve(_puzzle.clone());
    for (int i = max(_puzzle.history.length - 1, 0);
        i < newPuzzle.history.length;
        i++) {
      if (!_solving) {
        break;
      }
      var h = newPuzzle.history[i];
      await Future.delayed(const Duration(milliseconds: 450));
      onTileMoved(
        _puzzle.tiles.firstWhere((element) => element.currentPosition == h),
        isAi: true,
      );
    }
    setState(() {
      _solving = false;
    });
  }

  Widget _gameLayout(Size size) {
    if (size.height == size.shortestSide) {
      return Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 2,
            child: Center(child: _gameContent(size)),
          ),
          Expanded(
              flex: 1,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          _puzzleSize++;
                          _initPuzzle(puzzleOnly: true);
                        },
                        child: const Text('START TEST')),
                    _gameProgress(size),
                    // Image.network(
                    //     'https://storage.googleapis.com/cms-storage-bucket/ed2e069ee37807f5975a.jpg',
                    //     width: 100),

                    Flexible(
                      child: Image.asset(
                        'assets/img/dashonaute_1.png',
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(primary: Colors.white70),
                      onPressed: () {
                        showLicensePage(
                            context: context,
                            // applicationIcon: Image.asset(name)
                            applicationName: "ZFlutter");
                      },
                      child: const Text('Show Licenses'),
                    ),
                  ])),
        ],
      ));
    } else {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
              onPressed: () {
                _puzzleSize++;
                _initPuzzle(puzzleOnly: true);
              },
              child: const Text('START TEST')),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_gameProgress(size)]),
          Flexible(
            child: _gameContent(size),
          ),
          TextButton(
            style: TextButton.styleFrom(primary: Colors.white70),
            onPressed: () {
              showLicensePage(
                  context: context,
                  // applicationIcon: Image.asset(name)
                  applicationName: "ZFlutter");
            },
            child: const Text('Show Licenses'),
          ),
        ],
      ));
    }
  }

  Widget _gameContent(Size size) {
    // return   Container();
    return LayoutBuilder(builder: (_, constraints) {
      final contentSize = Size(constraints.maxWidth, constraints.maxHeight);
      final aroundPadding = contentSize.shortestSide / 25;
      final boardContentSize = contentSize.shortestSide - aroundPadding * 2;
      return BoardContent(
        puzzle: _puzzle,
        contentSize: Size(boardContentSize, boardContentSize),
        backgroundWidget: _selectedWidget ??
            ZWidget(
              midChild: Image.asset("assets/img/dashonaute_1.png"),
              layers: 5,
              rotationX: pi / 4,
              rotationY: pi / 3,
              depth: 40,
              direction: ZDirection.forwards,
            ),
        onTileMoved: onTileMoved,
        xTilt: 0,
        yTilt: 0,
      );
    });
  }

  Widget _gameProgress(Size size) {
    return _startedControls(size, xTilt: 0, yTilt: 0);
  }

  onTileMoved(Tile tile, {bool isAi = false}) {
    if (isAi || !_solving) {
      _puzzle = _puzzle.moveTiles(tile);
      setState(() {});
    }
  }
}
