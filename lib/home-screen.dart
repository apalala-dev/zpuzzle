import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:slide_puzzle/ui/alt-puzzle-board-widget.dart';
import 'package:slide_puzzle/ui/animated-board-widget.dart';
import 'package:slide_puzzle/ui/background/space-widget2.dart';
import 'package:slide_puzzle/ui/board-content.dart';
import 'package:slide_puzzle/ui/settings/background-widget-picker.dart';
import 'package:slide_puzzle/ui/settings/size-picker.dart';
import 'package:zwidget/zwidget.dart';

import 'model/puzzle-solver.dart';
import 'model/puzzle.dart';
import 'ui/puzzle-board-widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  AnimationController? _animationController;
  AnimationController? _settingsController;

  bool _showDoors = false;
  late Animation<Offset> _doorTopEnter;
  late Animation<Offset> _doorBottomEnter;
  late Animation<double> _doorsFlip;

  late List<Animation<double>> _tileEnterAnimation;
  late List<Animation<double>> _letterDepthAnimation;
  late List<Animation<double>> _letterFadeAnimation;
  late Animation<double> _flipAnimation;

  bool _tilesAppearing = true;
  bool _started = false;
  bool _solving = false;
  Widget? _selectedWidget;
  late Puzzle _puzzle;
  int _puzzleSize = 3;
  StreamSubscription<int>? _nbMovesListener;
  final totalAnim = 8000;
  final tileEnterAnimTile = 700;

  final Tween<double> _rotationXTween = Tween<double>(begin: pi / 2, end: 0.0);
  final Tween<double> _rotationYTween = Tween<double>(begin: pi / 2, end: 0.0);

  _initPuzzle({bool puzzleOnly = false}) {
    _puzzle = Puzzle.generate(_puzzleSize, shuffle: true);
    _nbMovesListener?.cancel();
    _nbMovesListener = _puzzle.nbMovesStream.listen((e) {
      setState(() {});
    });
    if (!puzzleOnly) {
      _initEnterAnim();
    }
  }

  @override
  void initState() {
    super.initState();
    _initPuzzle();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _settingsController!.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      const Positioned.fill(
          child: SpaceWidget2(
        title: "Flutter Puzzle Hack",
      )),
      LayoutBuilder(builder: (context, constraints) {
        Size size = Size(constraints.maxWidth, constraints.maxHeight);

        if (_showDoors) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AnimatedBuilder(
                animation: _animationController!,
                builder: (_, child) {
                  return Transform.translate(
                      offset: _doorTopEnter.value,
                      child: ZWidget(
                        child: _startedControls(),
                        rotationX: _doorsFlip.value,
                        rotationY: 0,
                        //_doorsFlip.value,
                        depth: 10,
                        direction: ZDirection.backwards,
                        layers: 1,
                        alignment: Alignment.topCenter,
                      ));
                },
              ),
              Flexible(
                child: LayoutBuilder(builder: (_, constraints) {
                  final contentSize =
                      Size(constraints.maxWidth, constraints.maxHeight);

                  return SizedBox(
                    width: contentSize.shortestSide,
                    height: contentSize.shortestSide,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _animationController!,
                        child: true
                            ? AnimatedBoardWidget(
                                puzzle: _puzzle,
                                contentSize: contentSize,
                                child: BoardContent(
                                  puzzle: _puzzle,
                                  contentSize: contentSize,
                                  backgroundWidget: _selectedWidget ??
                                      Image.asset("assets/img/moon.png"),
                                ),
                                rotationXTween: _rotationXTween,
                                rotationYTween: _rotationYTween,
                                animationController: _animationController!)
                            : AltPuzzleBoardWidget(
                                puzzle: _puzzle,
                                backgroundWidget:
                                    Image.asset("assets/img/moon.png"),
                              ),
                        builder: (context, child) => Transform(
                            child: child, transform: Matrix4.identity()),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        } else {
          return Padding(
            child: AnimatedBuilder(
              child: _notStartedControls(), // _gameSettings(context, size),
              builder: (context, child) {
                return ScaleTransition(
                  child: FadeTransition(
                      child: child, opacity: _settingsController!),
                  scale: _settingsController!,
                );
              },
              animation: _settingsController!,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 40),
          );
        }
      }),
      ElevatedButton(
          onPressed: () {
            setState(() {
              // _initEnterAnim();
              _settingsController!.reset();
              _animationController?.reset();
              _settingsController!.forward();
              _showDoors = false;
            });
          },
          child: Text("Switch anim")),
    ]);
  }

  Widget _startedControls() {
    final size = MediaQuery.of(context).size;
    return Container(
      key: const ValueKey(1),
      height: size.height / 4,
      decoration: BoxDecoration(
          color: Colors.white54,
          borderRadius: BorderRadius.circular(size.shortestSide / 30)),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Text('00:01:23',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.shortestSide / 12,
              fontWeight: FontWeight.bold,
            )),
        Padding(
          child: Text.rich(TextSpan(
              children: [
                TextSpan(
                    text: "${_puzzle.history.length}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: " Moves | "),
                TextSpan(
                    text: "${_puzzle.tiles.length - 1}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: " Tiles"),
              ],
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.shortestSide / 18,
              ))),
          padding: const EdgeInsets.symmetric(horizontal: 40),
        ),
        Row(mainAxisSize: MainAxisSize.min, children: [
          AnimatedSwitcher(
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
                        primary: Colors.white,
                        side: const BorderSide(width: 2, color: Colors.white)),
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
        ]),
      ]),
    );
  }

  Widget _notStartedControls() {
    final size = MediaQuery.of(context).size;
    return Container(
      key: const ValueKey(2),
      height: size.height / 3,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size.shortestSide / 10)),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Text(
          'Slide Puzzle',
          style: TextStyle(fontSize: size.shortestSide / 15),
        ),
        SizedBox(
          child: SizePicker(onSizePicked: (size) {
            _puzzleSize = size;
          }),
          height: size.height / 16,
        ),
        SizedBox(
          child: BackgroundWidgetPicker(onBackgroundPicked: (selectedWidget) {
            setState(() {
              _selectedWidget = selectedWidget;
              print("selectedWidget not null");
            });
          }),
          height: size.height / 16,
        ),
        ElevatedButton(
            onPressed: () {
              _initPuzzle(puzzleOnly: true);
              _settingsController!.reverse();
            },
            child: Text("START 1")),
      ]),
    );
  }

  _initEnterAnim() {
    final nbTiles = _puzzle.getDimension() * _puzzle.getDimension();

    const boardMoveTime = 500;
    final tileEnterAnimTime = nbTiles * tileEnterAnimTile * 0.3;
    const boardFlipTime = 500;

    final tileTextDepthTime = nbTiles * tileEnterAnimTile * 0.1;
    final tileTextOpacityTime = nbTiles * tileEnterAnimTile * 0.05;
    var totalTime = (boardMoveTime +
            tileEnterAnimTime +
            boardFlipTime +
            tileTextDepthTime +
            tileTextOpacityTime)
        .round();

    final boardMovePart = boardMoveTime / totalTime;
    final flipPart = boardFlipTime / totalTime;
    final tilesAnimPart = tileEnterAnimTime / totalTime;
    final textAnimPart = tileTextDepthTime / totalTime;
    final textAnimFadePart = tileTextOpacityTime / totalTime;

    _animationController?.dispose();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: totalTime));

    _doorBottomEnter =
        Tween<Offset>(begin: const Offset(0, 200), end: const Offset(0, 0))
            .animate(
      CurvedAnimation(
          parent: _animationController!,
          curve: Interval(0, boardMovePart, curve: Curves.easeOut)),
    );
    _doorTopEnter =
        Tween<Offset>(begin: const Offset(0, -200), end: const Offset(0, 0))
            .animate(
      CurvedAnimation(
          parent: _animationController!,
          curve: Interval(0, boardMovePart, curve: Curves.easeOut)),
    );

    _flipAnimation = Tween<double>(begin: -pi / 4, end: -pi / 12).animate(
        CurvedAnimation(
            parent: _animationController!,
            curve: Interval(boardMovePart + tilesAnimPart,
                boardMovePart + tilesAnimPart + boardFlipTime / totalTime,
                curve: Curves.bounceOut)));

    _doorsFlip = Tween<double>(begin: pi / 3, end: 0.0).animate(
      CurvedAnimation(
          parent: _animationController!,
          curve: Interval(boardMovePart + tilesAnimPart,
              boardMovePart + tilesAnimPart + boardFlipTime / totalTime,
              curve: Curves.bounceOut)),
    );

    final totalTimeTiles = tilesAnimPart * totalAnim;
    final spacing =
        (totalTimeTiles - (nbTiles - 1) * tileEnterAnimTile * 1.15) /
            (nbTiles - 2);

    _tileEnterAnimation = [
      for (int i = 0; i < nbTiles; i++)
        i == nbTiles - 1
            ? const AlwaysStoppedAnimation<double>(0.0)
            : Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                parent: _animationController!,
                curve: Interval(
                  boardMovePart +
                      tilesAnimPart *
                          (i * tileEnterAnimTile + i * spacing) /
                          totalTimeTiles,
                  boardMovePart +
                      tilesAnimPart *
                          ((i + 1) * tileEnterAnimTile + i * spacing) /
                          totalTimeTiles,
                  curve: Curves.easeInBack,
                ),
              ))
    ];

    // _flipAnimation =
    //     Tween<double>(begin: -pi / 2, end: 0.0).animate(CurvedAnimation(
    //   parent: _animationController!,
    //   curve: Interval(
    //     tilesAnimPart,
    //     1.0 - textAnimPart - textAnimFadePart,
    //     // curve: Curves.fastOutSlowIn,
    //     curve: Curves.easeOut,
    //   ),
    // ));

    _letterDepthAnimation = [
      for (int i = 0; i < nbTiles; i++)
        i == nbTiles - 1
            ? const AlwaysStoppedAnimation<double>(1)
            : Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
                parent: _animationController!,
                curve: Interval(
                  1.0 -
                      textAnimPart -
                      textAnimFadePart +
                      textAnimPart *
                          (i * tileEnterAnimTile + i * spacing) /
                          totalTimeTiles,
                  1.0 -
                      textAnimPart -
                      textAnimFadePart +
                      textAnimPart *
                          ((i + 1) * tileEnterAnimTile + i * spacing) /
                          totalTimeTiles,
                  curve: Curves.easeOut,
                ),
              ))
    ];

    _letterFadeAnimation = [
      for (int i = 0; i < nbTiles; i++)
        i == nbTiles - 1
            ? const AlwaysStoppedAnimation<double>(1)
            : Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
                parent: _animationController!,
                curve: Interval(
                  1.0 -
                      textAnimFadePart +
                      textAnimFadePart *
                          (i * tileEnterAnimTile + i * spacing) /
                          totalTimeTiles,
                  1.0 -
                      textAnimFadePart +
                      textAnimFadePart *
                          ((i + 1) * tileEnterAnimTile + i * spacing) /
                          totalTimeTiles,
                  curve: Curves.easeOut,
                ),
              ))
    ];

    _settingsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _settingsController!.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {
          if (_animationController!.isCompleted) {
            _animationController!.reset();
          } else {
            setState(() {
              _tilesAppearing = true;
              _showDoors = true;
            });
            _animationController!.forward();
            _animationController!.addStatusListener((status) {
              if (status == AnimationStatus.completed) {
                setState(() {
                  _started = true;
                });
              }
            });
          }
        });
      }
    });
  }

  /// 1. Reverse flip
  /// 2. Stay in that position, remove tiles
  /// 3. Flip back to original position
  initExitAnim() {
    final nbTiles = _puzzle.getDimension() * _puzzle.getDimension();
    final tileEnterAnimTime = nbTiles * tileEnterAnimTile * 0.3;
    const baseFlipTime = 1200;
    final flipTime = baseFlipTime * 2 + tileEnterAnimTime;
    var totalTime = (tileEnterAnimTime + flipTime).round();
    final tilesAnimPart = tileEnterAnimTime / totalTime;

    _animationController?.dispose();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: flipTime.round()));
    _flipAnimation = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.0, end: 4.0)
              .chain(CurveTween(curve: Curves.ease)),
          weight: baseFlipTime / totalTime,
        ),
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(4.0),
          weight: tileEnterAnimTime / totalTime,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 4.0, end: 0.0)
              .chain(CurveTween(curve: Curves.ease)),
          weight: baseFlipTime / totalTime,
        ),
      ],
    ).animate(_animationController!);

    final totalTimeTiles = tilesAnimPart * totalAnim;
    final spacing =
        (totalTimeTiles - (nbTiles - 1) * tileEnterAnimTile * 1.15) /
            (nbTiles - 2);

    _tileEnterAnimation = [
      for (int i = 0; i < nbTiles; i++)
        i == nbTiles - 1
            ? const AlwaysStoppedAnimation<double>(0.0)
            : Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                parent: _animationController!,
                curve: Interval(
                  (baseFlipTime * 0.3 +
                          (tilesAnimPart) *
                              (i * tileEnterAnimTile + i * spacing)) /
                      totalTimeTiles,
                  (baseFlipTime * 0.3 +
                          (tilesAnimPart) *
                              ((i + 1) * tileEnterAnimTile + i * spacing)) /
                      totalTimeTiles,
                  curve: Curves.easeIn,
                ),
              ))
    ];
    _letterFadeAnimation = [
      for (int i = 0; i < nbTiles; i++)
        const AlwaysStoppedAnimation<double>(0.0)
    ];
    _letterDepthAnimation = [
      for (int i = 0; i < nbTiles; i++)
        const AlwaysStoppedAnimation<double>(0.0)
    ];
    setState(() {});
  }

  _solve() async {
    setState(() {
      _solving = true;
    });
    PuzzleSolver solver = PuzzleSolver();
    var newPuzzle = solver.solve(_puzzle.clone());
    print(
        "Puzzle solved history : ${newPuzzle.history.length} - vs not solved puzzle history: ${_puzzle.history.length}");
    print("new puzzle solved:\n${newPuzzle.toVisualString()}");
    for (int i = max(_puzzle.history.length - 1, 0);
        i < newPuzzle.history.length;
        i++) {
      if (!_solving) {
        break;
      }
      var h = newPuzzle.history[i];
      print(
          "Move $i tile ${_puzzle.tiles.firstWhere((element) => element.currentPosition == h).value}");
      await Future.delayed(Duration(milliseconds: 450));
      setState(() {
        _puzzle = _puzzle.moveTiles(
            _puzzle.tiles.firstWhere((element) => element.currentPosition == h),
            []);
      });
    }
    setState(() {
      _solving = false;
    });
  }
}
