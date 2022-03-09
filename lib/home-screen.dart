import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_color/flutter_color.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:slide_puzzle/asset-path.dart';
import 'package:slide_puzzle/model/tile.dart';
import 'package:slide_puzzle/ui/alt-puzzle-board-widget.dart';
import 'package:slide_puzzle/ui/animated-board-widget.dart';
import 'package:slide_puzzle/ui/background/fog.dart';
import 'package:slide_puzzle/ui/background/space-widget2.dart';
import 'package:slide_puzzle/ui/board-content.dart';
import 'package:slide_puzzle/ui/settings/background-widget-picker.dart';
import 'package:slide_puzzle/ui/settings/size-picker.dart';
import 'package:slide_puzzle/ui/timer_widget.dart';
import 'package:slide_puzzle/win-screen.dart';
import 'package:zwidget/zwidget.dart';

import 'app-colors.dart';
import 'model/position.dart';
import 'model/puzzle-solver.dart';
import 'model/puzzle.dart';
import 'ui/puzzle-board-widget.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback changeTheme;

  const HomeScreen({Key? key, required this.changeTheme}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<TimerWidgetState> _timerKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();

  Offset _gyro = Offset.zero;

  AnimationController? _animationController;
  AnimationController? _settingsController;

  bool _showDoors = false;
  late Animation<double> _doorsFlip;
  late Animation<double> _gameProgressScaleAnimation;
  final Tween<double> _scaleBoardTween = Tween<double>(begin: 0.0, end: 1.0);
  bool _gyroEnabled = false;
  bool _showIndicator = true;

  bool _tilesAppearing = true;
  bool _started = false;
  bool _solving = false;
  Widget? _selectedWidget;
  late Puzzle _puzzle;
  int _puzzleSize = 3;
  StreamSubscription<int>? _nbMovesListener;

  final totalAnim = 8000;
  final tileEnterAnimTile = 700;

  final Tween<double> _rotationXTween = Tween<double>(begin: 2 * pi, end: 0.0);
  final Tween<double> _rotationYTween = Tween<double>(begin: 2 * pi, end: 0.0);

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
      _focusNode.requestFocus();
      // _gyroSub = gyroscopeEvents
      //     .where((event) => event.x != 0 && event.y != 0)
      //     .listen((GyroscopeEvent event) {
      //   if (event.x != 0 && event.y != 0) {
      //     setState(() {
      //       double x = event.x, y = event.y, z = event.z;
      //       _gyro += Offset(degToRadian(y), degToRadian(x));
      //       print('$x, $y, $z - gyro: $_gyro');
      //     });
      //   }
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
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
                        print(
                            "gonna move (${newPosition.x}, ${newPosition.y})");
                        onTileMoved(_puzzle.tiles.firstWhere((element) =>
                            element.currentPosition == newPosition));
                        // setState(() {
                        //   _puzzle.moveTiles(
                        //       _puzzle.tiles.firstWhere((element) =>
                        //           element.currentPosition == newPosition),
                        //       []);
                        // });
                      }
                    }
                  }
                },
                child: Stack(children: [
                  // const Positioned.fill(
                  //     child: SpaceWidget2(
                  //   title: "Flutter Puzzle Hack",
                  // )),
                  if (!kIsWeb)
                    Positioned.fill(
                        child: LayoutBuilder(
                      builder: (ctx, constraints) => RepaintBoundary(
                          child: Fog(
                        contentSize:
                            Size(constraints.maxWidth, constraints.maxHeight),
                      )),
                    )),
                  LayoutBuilder(builder: (context, constraints) {
                    Size size =
                        Size(constraints.maxWidth, constraints.maxHeight);

                    if (_showDoors) {
                      return _gameLayout(size);
                    } else {
                      return Center(
                          child: Padding(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                child: _notStartedControls(size),
                                // _gameSettings(context, size),
                                builder: (context, child) {
                                  return ScaleTransition(
                                    child: FadeTransition(
                                        child: child,
                                        opacity: _settingsController!),
                                    scale: _settingsController!,
                                  );
                                },
                                animation: _settingsController!,
                              ),
                              SizedBox(height: size.height / 50),
                              Flexible(
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                    SizedBox(
                                        width: MediaQuery.of(context)
                                                .size
                                                .shortestSide /
                                            8,
                                        child: IconButton(
                                          icon: Icon(
                                            Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Icons.wb_sunny
                                                : Icons.nightlight_round,
                                            color: Colors.white70,
                                          ),
                                          onPressed: () {
                                            widget.changeTheme();
                                          },
                                        )),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                          primary: Colors.white70),
                                      onPressed: () {
                                        showLicensePage(
                                            context: context,
                                            applicationIcon: SvgPicture.asset(
                                              AssetPath.zPuzzleIcon,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.color,
                                            ),
                                            applicationName: "ZFlutter");
                                      },
                                      child: const Text('Show Licenses'),
                                    ),
                                    Image.asset(
                                      AssetPath.dashonaut,
                                      fit: BoxFit.scaleDown,
                                      width: MediaQuery.of(context)
                                              .size
                                              .shortestSide /
                                          8,
                                      // height:
                                      //     MediaQuery.of(context).size.shortestSide /
                                      //         8,
                                    )
                                  ]))
                            ]),
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                      ));
                    }
                  }),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Material(
                      child: IconButton(
                        iconSize: 36,
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            // _gyro = Offset.zero;
                            _gyroEnabled = !_gyroEnabled;
                          });
                        },
                        icon: Icon(
                          _gyroEnabled
                              ? Icons.screen_rotation
                              : Icons.screen_lock_rotation,
                        ),
                      ),
                      color: Colors.transparent,
                    ),
                  ),
                ]),
              ),
            )
          ]))
        ]),
      ),
    );
  }

  Widget _startedControls(Size size, {double xTilt = 0, double yTilt = 0}) {
    final screenSize = MediaQuery.of(context).size;
    final title = Row(mainAxisSize: MainAxisSize.min, children: [
      Column(children: [
        SvgPicture.asset(
          AssetPath.zPuzzleIcon,
          color: Theme.of(context).textTheme.titleLarge?.color,
          width: screenSize.shortestSide / 15,
          height: screenSize.shortestSide / 15,
        ),
        SizedBox(
          height: screenSize.shortestSide / 80,
        )
      ]),
      const SizedBox(
        width: 4,
      ),
      Text.rich(
          TextSpan(children: [
            TextSpan(
                text: 'P',
                style: TextStyle(fontSize: screenSize.shortestSide / 40)),
            TextSpan(
                text: 'UZZLE',
                style: TextStyle(fontSize: screenSize.shortestSide / 52)),
          ]),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ))
    ]);
    final counter = Text.rich(TextSpan(
        children: [
          TextSpan(
              text: "${_puzzle.history.length}",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const TextSpan(text: " Moves"),
        ],
        style: TextStyle(
            fontSize: screenSize.shortestSide / 34,
            color: Theme.of(context).textTheme.titleLarge?.color)));

    final timer = TimerWidget(
      key: _timerKey,
    );

    final toggle = Row(mainAxisSize: MainAxisSize.min, children: [
      Switch(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        // activeColor: Theme.of(context).primaryColor,
        // activeColor: HexColor('FF985E'),
        value: _showIndicator,
        onChanged: (value) {
          setState(() {
            _showIndicator = !_showIndicator;
          });
        },
      ),
      InkWell(
        child: const Text('Show help'),
        onTap: () => setState(() {
          _showIndicator = !_showIndicator;
        }),
      ),
    ]);

    final separator = Padding(
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.color
                    ?.withOpacity(0.26),
              ),
            ),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
    );
    final giveUpButton = TextButton.icon(
      style: TextButton.styleFrom(primary: Colors.red),
      onPressed: () {
        showGeneralDialog(
          context: context,
          pageBuilder: (BuildContext ctx, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return AlertDialog(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [const Text('Give up?')]),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  child: const Text('No'),
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                ),
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _giveUp();
                  },
                ),
              ],
            );
          },
          transitionBuilder: (ctx, a1, a2, child) {
            return Transform.scale(
                child: child, scale: Curves.easeOutBack.transform(a1.value));
          },
        );
      },
      icon: const Icon(Icons.flag, size: 20),
      label: const Text('GIVE UP'),
    );
    final selectedChildWidget = ClipRRect(
      child: _selectedWidget ?? const SizedBox(),
      borderRadius: BorderRadius.circular(8),
    );
    final RenderObjectWidget selectedWidget;
    if (size.height == size.shortestSide) {
      selectedWidget =
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        const SizedBox(width: 40),
        AspectRatio(
          child: Container(
            child: selectedChildWidget,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 2)
                ]),
          ),
          aspectRatio: 1,
        ),
        FloatingActionButton.small(
          // backgroundColor: Theme.of(context).primaryColor,
          onPressed: _showWidgetPickerDialog,
          child: const Icon(Icons.edit),
        ),
      ]);
    } else {
      selectedWidget = AspectRatio(
        child: Container(
          child: Stack(children: [
            Positioned.fill(child: selectedChildWidget),
            Align(
              child: Padding(
                child: FloatingActionButton.small(
                  onPressed: _showWidgetPickerDialog,
                  child: const Icon(Icons.edit),
                ),
                padding: const EdgeInsets.only(bottom: 4, right: 4),
              ),
              alignment: Alignment.bottomRight,
            )
          ]),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 2)
              ]),
        ),
        aspectRatio: 1,
      );
    }

    final solveButton = AnimatedSwitcher(
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
                  primary: Theme.of(context).brightness == Brightness.light
                      ? Colors.black87
                      : Colors.white,
                  side: BorderSide(
                      width: 2,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black87
                          : Colors.white)),
              onPressed: () {
                setState(() {
                  _solving = false;
                });
              },
              icon: const Icon(Icons.stop),
              label: const Text("CANCEL"),
            )
          : _puzzle.isComplete()
              ? const SizedBox(height: 28)
              : ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32))),
                  onPressed: () {
                    _solve();
                  },
                  icon: const Icon(Icons.extension, size: 20),
                  label: const Text("SOLVE"),
                ),
    );

    if (size.height == size.shortestSide) {
      return Padding(
        padding: EdgeInsets.only(right: size.width / 50),
        child: Container(
          key: const ValueKey(1),
          padding: EdgeInsets.symmetric(
              horizontal: size.shortestSide / 40,
              vertical: size.shortestSide / 100),
          height: min(max(size.shortestSide / 2, 220), 350),
          decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.boardOuterColor(context)
                  : AppColors.boardInnerColor(context),
              borderRadius: BorderRadius.circular(size.shortestSide / 40)),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                title,
                SizedBox(
                  child: selectedWidget,
                  height: size.shortestSide / 8,
                ),
                Column(children: [
                  toggle,
                  solveButton,
                ]),
                Row(children: [
                  Expanded(
                      child: Align(
                    child: counter,
                    alignment: Alignment.centerRight,
                  )),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(child: timer),
                ]),
                separator,
                giveUpButton,
              ]),
        ),
      );
    } else {
      return Container(
        key: const ValueKey(1),
        padding: EdgeInsets.symmetric(
            horizontal: size.shortestSide / 40,
            vertical: size.shortestSide / 100),
        height: max(size.shortestSide / 3.2, 200),
        width: max(size.shortestSide / 1.5, 260),
        decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.boardOuterColor(context)
                : AppColors.boardInnerColor(context),
            borderRadius: BorderRadius.circular(size.shortestSide / 40)),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          SizedBox(
            height: max(size.shortestSide / 6, 130),
            child: Row(children: [
              Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      title,
                      toggle,
                      solveButton,
                    ],
                  ),
                  flex: 6),
              Expanded(child: selectedWidget, flex: 5),
            ]),
          ),
          separator,
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            giveUpButton,
            counter,
            timer,
          ]),
        ]),
      );
    }
  }

  Widget _notStartedControls(Size size) {
    final space = SizedBox(height: size.height / 40);
    return Container(
      key: const ValueKey(2),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size.shortestSide / 10)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        space,
        Row(mainAxisSize: MainAxisSize.min, children: [
          Column(children: [
            SvgPicture.asset(
              AssetPath.zPuzzleIcon,
              color: Theme.of(context).textTheme.titleLarge?.color,
              width: size.shortestSide / 10,
              height: size.shortestSide / 10,
            ),
            SizedBox(
              height: size.shortestSide / 80,
            )
          ]),
          const SizedBox(
            width: 4,
          ),
          Text.rich(
              TextSpan(children: [
                TextSpan(
                    text: 'P',
                    style: TextStyle(fontSize: size.shortestSide / 28)),
                TextSpan(
                    text: 'UZZLE',
                    style: TextStyle(fontSize: size.shortestSide / 36)),
              ]),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ))
        ]),
        space,
        Text(
          'Choose your difficulty',
          style: TextStyle(fontSize: size.shortestSide / 34),
        ),
        SizedBox(height: size.height / 80),
        SizedBox(
          child: SizePicker(onSizePicked: (size) {
            _puzzleSize = size;
          }),
          height: size.height / 12,
        ),
        space,
        Text('Pick a background',
            style: TextStyle(fontSize: size.shortestSide / 34)),
        SizedBox(height: size.height / 80),
        SizedBox(
          child: Padding(
            child: BackgroundWidgetPicker(onBackgroundPicked: (selectedWidget) {
              setState(() {
                _selectedWidget = selectedWidget;
                print("selectedWidget not null");
              });
            }),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          height: size.shortestSide / 8 * 3,
          width: (size.shortestSide / 8) * 5,
        ),
        space,
        ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(64))),
            onPressed: () {
              _initPuzzle(puzzleOnly: true);
              _settingsController!.reverse();
            },
            label: const Text("START")),
        space,
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
        vsync: this, duration: const Duration(milliseconds: 5000));
    _animationController?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _timerKey.currentState?.start();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _settingsController!.forward();
          _showDoors = false;
        });
      }
    });

    _doorsFlip = Tween<double>(begin: 2 * pi, end: 0.0).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOut,
    ));
    _gameProgressScaleAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.fastLinearToSlowEaseIn))
        .animate(_animationController!);

    final totalTimeTiles = tilesAnimPart * totalAnim;
    final spacing =
        (totalTimeTiles - (nbTiles - 1) * tileEnterAnimTile * 1.15) /
            (nbTiles - 2);

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

  _solve() async {
    setState(() {
      _solving = true;
    });
    print('solving');
    PuzzleSolver solver = PuzzleSolver();
    var newPuzzle = solver.solve(_puzzle.clone());
    print('puzzle solved');

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
      await Future.delayed(const Duration(milliseconds: 450));
      onTileMoved(
        _puzzle.tiles.firstWhere((element) => element.currentPosition == h),
        isAi: true,
      );
      // setState(() {
      //   _puzzle = _puzzle.moveTiles(
      //       _puzzle.tiles.firstWhere((element) => element.currentPosition == h),
      //       []);
      // });
    }
    if (_solving) {
      setState(() {
        _solving = false;
      });
    }
  }

  Widget _gameLayout(Size size) {
    final _space = SizedBox(height: size.height / 100);

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
                    _gameProgress(size),
                    // Image.network(
                    //     'https://storage.googleapis.com/cms-storage-bucket/ed2e069ee37807f5975a.jpg',
                    //     width: 100),

                    Flexible(
                      child: Image.asset(
                        'assets/img/dashonaute_3.png',
                      ),
                    ),
                  ])),
        ],
      ));
    } else {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _space,
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_gameProgress(size)]),
          Flexible(
            child: _gameContent(size),
          ),
        ],
      ));
    }
  }

  Widget _gameContent(Size size) {
    return LayoutBuilder(builder: (_, constraints) {
      final contentSize = Size(constraints.maxWidth, constraints.maxHeight);
      final aroundPadding = contentSize.shortestSide / 25;
      final boardContentSize = contentSize.shortestSide - aroundPadding * 2;

      return Padding(
        padding: EdgeInsets.all(aroundPadding),
        child: SizedBox(
          width: boardContentSize,
          height: boardContentSize,
          child: Center(
            child: !_gyroEnabled
                ? AnimatedBoardWidget(
                    puzzle: _puzzle,
                    contentSize: contentSize,
                    boardContentSize: Size(boardContentSize, boardContentSize),
                    onTileMoved: onTileMoved,
                    selectedTileWidget: _selectedWidget ?? Container(),
                    showIndicator: _showIndicator,
                    botChild: Container(
                      width: boardContentSize,
                      height: boardContentSize,
                      // padding: EdgeInsets.all(innerBoardSpacing * 2),
                      decoration: BoxDecoration(
                          color: AppColors.boardOuterColor(context).darker(20),
                          borderRadius: BorderRadius.circular(
                              contentSize.shortestSide / 30)),
                    ),
                    rotationXTween: _rotationXTween,
                    rotationYTween: _rotationYTween,
                    scaleTween: _scaleBoardTween,
                    gyroEvent: _gyro,
                    animationController: _animationController!,
                  )
                : StreamBuilder<GyroscopeEvent>(
                    initialData: GyroscopeEvent(0, 0, 0),
                    stream: gyroscopeEvents
                        .where((event) => event.x != 0 && event.y != 0),
                    builder: (context, snapshot) {
                      _gyro += Offset(degToRadian(snapshot.data?.y ?? 0),
                          degToRadian(snapshot.data?.x ?? 0));
                      return AnimatedBoardWidget(
                          puzzle: _puzzle,
                          contentSize: contentSize,
                          boardContentSize:
                              Size(boardContentSize, boardContentSize),
                          onTileMoved: onTileMoved,
                          selectedTileWidget: _selectedWidget ?? Container(),
                          botChild: Container(
                            width: boardContentSize,
                            height: boardContentSize,
                            // padding: EdgeInsets.all(innerBoardSpacing * 2),
                            decoration: BoxDecoration(
                                color: AppColors.boardOuterColor(context)
                                    .darker(20),
                                borderRadius: BorderRadius.circular(
                                    contentSize.shortestSide / 30)),
                          ),
                          rotationXTween: _rotationXTween,
                          rotationYTween: _rotationYTween,
                          scaleTween: _scaleBoardTween,
                          gyroEvent: _gyro,
                          animationController: _animationController!);
                    }),
          ),
        ),
      );
    });
  }

  Widget _gameProgress(Size size) {
    return AnimatedBuilder(
      builder: (_, child) {
        final xTilt = Tween<double>(begin: -2 * pi, end: 0.0)
            .chain(CurveTween(curve: const ElasticOutCurve(0.4)))
            .evaluate(_animationController!);
        final yTilt = Tween<double>(begin: -2 * pi, end: 0.0)
            .chain(CurveTween(curve: const ElasticOutCurve(0.4)))
            .evaluate(_animationController!);

        return Transform.scale(
          child: ZWidget(
            midChild: RepaintBoundary(
                child: size.shortestSide == size.height
                    ? Padding(
                        padding: EdgeInsets.only(right: size.width / 50),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.shortestSide / 40,
                              vertical: size.shortestSide / 100),
                          height: min(max(size.shortestSide / 2, 220), 350),
                          decoration: BoxDecoration(
                              color: AppColors.perspectiveColor,
                              borderRadius: BorderRadius.circular(
                                  size.shortestSide / 30)),
                        ))
                    : Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.shortestSide / 40,
                            vertical: size.shortestSide / 100),
                        height: max(size.shortestSide / 3.2, 200),
                        width: max(size.shortestSide / 1.5, 260),
                        decoration: BoxDecoration(
                            color: AppColors.perspectiveColor,
                            borderRadius:
                                BorderRadius.circular(size.shortestSide / 30)),
                      )),
            topChild: RepaintBoundary(
                child: _startedControls(size, xTilt: xTilt, yTilt: yTilt)),
            rotationX: xTilt,
            rotationY: yTilt,
            //_doorsFlip.value,
            depth: 10,
            direction: ZDirection.forwards,
            layers: 5,
            alignment: Alignment.center,
          ),
          scale: _gameProgressScaleAnimation.value,
        );
      },
      animation: _animationController!,
    );
  }

  onTileMoved(Tile tile, {bool isAi = false}) {
    if (isAi || !_solving) {
      _puzzle = _puzzle.moveTiles(tile);
      setState(() {});
    }
    if (_puzzle.isComplete()) {
      _timerKey.currentState?.stop();
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => WinScreen(
              puzzle: _puzzle,
              duration: _timerKey.currentState!.totalDuration,
              background: _selectedWidget!,
              changeTheme: widget.changeTheme,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final scaleTween = Tween(begin: 0.0, end: 1.0)
                  .chain(CurveTween(curve: Curves.elasticOut));
              final fadeTween = Tween(begin: 0.0, end: 1.0)
                  .chain(CurveTween(curve: Curves.easeInOut));
              return ScaleTransition(
                scale: animation.drive(scaleTween),
                child: FadeTransition(
                  child: child,
                  opacity: animation.drive(fadeTween),
                ),
              );
            },
          ),
        );
      });
    }
  }

  _giveUp() {
    setState(() {
      _settingsController!.reset();
      _animationController?.reverse();
      _solving = false;
    });
  }

  void _showWidgetPickerDialog() {
    showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext ctx, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return AlertDialog(
          title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Pick a new background'),
          ]),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width / 2,
              child: BackgroundWidgetPicker(
                  currentlySelectedWidget: _selectedWidget,
                  onBackgroundPicked: (selectedWidget) {
                    // setState(() {
                    //   _selectedWidget = selectedWidget;
                    // });
                    Navigator.pop(context, selectedWidget);
                  }),
            ),
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ]),
        );
      },
      transitionBuilder: (ctx, a1, a2, child) {
        return Transform.scale(
            child: child, scale: Curves.easeOutBack.transform(a1.value));
      },
    ).then((newWidget) {
      if (newWidget != null && newWidget is Widget) {
        setState(() {
          _selectedWidget = newWidget;
        });
      }
    });
  }
}
