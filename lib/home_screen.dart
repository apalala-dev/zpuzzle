import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_color/flutter_color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:slide_puzzle/asset_path.dart';
import 'package:slide_puzzle/model/tile.dart';
import 'package:slide_puzzle/ui/animated_board_widget.dart';
import 'package:slide_puzzle/ui/background/fog.dart';
import 'package:slide_puzzle/ui/fit_or_scale_widget.dart';
import 'package:slide_puzzle/ui/home/game_progress.dart';
import 'package:slide_puzzle/ui/home/not_started_controls.dart';
import 'package:slide_puzzle/ui/timer_widget.dart';
import 'package:slide_puzzle/win_screen.dart';

import 'app_colors.dart';
import 'model/position.dart';
import 'model/puzzle_solver.dart';
import 'model/puzzle.dart';
import 'ui/home/started_controls_buttons.dart';

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
  final Tween<double> _scaleBoardTween = Tween<double>(begin: 0.0, end: 1.0);
  bool _gyroEnabled = false;
  bool _showIndicator = true;

  bool _solving = false;
  Widget _selectedWidget = const Image(
    image: AssetImage('assets/img/moon.png'),
    fit: BoxFit.cover,
  );
  late Puzzle _puzzle;
  int _puzzleSize = 3;

  final totalAnim = 8000;
  final tileEnterAnimTile = 700;

  final Tween<double> _rotationXTween = Tween<double>(begin: 2 * pi, end: 0.0);
  final Tween<double> _rotationYTween = Tween<double>(begin: 2 * pi, end: 0.0);

  _initPuzzle({bool puzzleOnly = false}) {
    _puzzle = Puzzle.generate(_puzzleSize, shuffle: true);
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
                        onTileMoved(_puzzle.tiles.firstWhere((element) =>
                            element.currentPosition == newPosition));
                      }
                    }
                  }
                },
                child: Stack(children: [
                  // if (!kIsWeb)
                  Positioned.fill(
                      child: LayoutBuilder(
                    builder: (ctx, constraints) => RepaintBoundary(
                        child: Fog(
                      contentSize:
                          Size(constraints.maxWidth, constraints.maxHeight),
                    )),
                  )),
                  FitOrScaleWidget(
                    minWidth: 360,
                    minHeight: 360,
                    child: LayoutBuilder(builder: (context, constraints) {
                      Size size =
                          Size(constraints.maxWidth, constraints.maxHeight);
                      if (_showDoors) {
                        return Center(
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  maxWidth: 1000, maxHeight: 1000),
                              child: _gameLayout(size)),
                        );
                      } else {
                        return Center(
                            child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: size.height / 50),
                                Expanded(
                                    child: AnimatedBuilder(
                                  child: NotStartedControls(
                                    size: size,
                                    puzzleSize: _puzzleSize,
                                    selectedWidget: _selectedWidget,
                                    onWidgetPicked: (newWidget) {
                                      setState(() {
                                        _selectedWidget = newWidget;
                                      });
                                    },
                                    onPuzzleSizePicked: (size) {
                                      setState(() {
                                        _puzzleSize = size;
                                      });
                                    },
                                    onStart: () {
                                      _initPuzzle(puzzleOnly: true);
                                      _settingsController!.reverse();
                                    },
                                  ),
                                  builder: (context, child) {
                                    return ScaleTransition(
                                      child: FadeTransition(
                                          child: child,
                                          opacity: _settingsController!),
                                      scale: _settingsController!,
                                    );
                                  },
                                  animation: _settingsController!,
                                )),
                                SizedBox(height: size.height / 50),
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .shortestSide /
                                              8,
                                          child: Center(
                                              child: ClipOval(
                                            child: Material(
                                              child: InkWell(
                                                child: Padding(
                                                    child: Icon(
                                                      Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.dark
                                                          ? Icons.wb_sunny
                                                          : Icons
                                                              .nightlight_round,
                                                      color: Colors.white70,
                                                      size: size.shortestSide /
                                                          16,
                                                    ),
                                                    padding: EdgeInsets.all(
                                                        size.shortestSide /
                                                            50)),
                                                onTap: () {
                                                  widget.changeTheme();
                                                },
                                              ),
                                              color: Colors.transparent,
                                            ),
                                          ))),
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
                                              applicationName:
                                                  AppLocalizations.of(context)!
                                                      .appName);
                                        },
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .showLicenses),
                                      ),
                                      Image.asset(
                                        AssetPath.dashonaut,
                                        fit: BoxFit.scaleDown,
                                        width: size.shortestSide / 8,
                                      )
                                    ]),
                              ]),
                        ));
                      }
                    }),
                  ),
                ]),
              ),
            )
          ]))
        ]),
      ),
    );
  }

  _initEnterAnim() {
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

    _settingsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _settingsController!.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {
          if (_animationController!.isCompleted) {
            _animationController!.reset();
          } else {
            setState(() {
              _showDoors = true;
            });
            _animationController!.forward();
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
                    GameProgress(
                      solving: _solving,
                      puzzle: _puzzle,
                      size: size,
                      listenable: _animationController!,
                      selectedWidget: _selectedWidget,
                      showIndicator: _showIndicator,
                      timerKey: _timerKey,
                      giveUp: _giveUp,
                      solve: _solve,
                      showIndicatorChanged: () {
                        setState(() {
                          _showIndicator = !_showIndicator;
                        });
                      },
                      stoppedSolving: () {
                        setState(() {
                          _solving = false;
                        });
                      },
                      onWidgetPicked: (newWidget) {
                        setState(() {
                          _selectedWidget = newWidget;
                        });
                      },
                      gyroEnabled: _gyroEnabled,
                      gyroChanged: () {
                        setState(() {
                          _gyroEnabled = !_gyroEnabled;
                        });
                      },
                    ),
                    Flexible(child: Image.asset(AssetPath.dashonaut)),
                  ])),
        ],
      ));
    } else {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            GameProgress(
              solving: _solving,
              puzzle: _puzzle,
              size: size,
              listenable: _animationController!,
              selectedWidget: _selectedWidget,
              showIndicator: _showIndicator,
              timerKey: _timerKey,
              giveUp: _giveUp,
              solve: _solve,
              showIndicatorChanged: () {
                setState(() {
                  _showIndicator = !_showIndicator;
                });
              },
              stoppedSolving: () {
                setState(() {
                  _solving = false;
                });
              },
              onWidgetPicked: (newWidget) {
                setState(() {
                  _selectedWidget = newWidget;
                });
              },
              gyroEnabled: _gyroEnabled,
              gyroChanged: () {
                setState(() {
                  _gyroEnabled = !_gyroEnabled;
                });
              },
            )
          ]),
          Flexible(
            child: _gameContent(size),
          ),
          StartedControlsButtons(
            solving: _solving,
            puzzle: _puzzle,
            size: size,
            listenable: _animationController!.drive(
                CurveTween(curve: const Interval(0.5, 1.0, curve: Curves.easeInOut))),
            giveUp: _giveUp,
            solve: _solve,
            stoppedSolving: () {
              setState(() {
                _solving = false;
              });
            },
          ),
          _space,
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
                    selectedTileWidget: _selectedWidget,
                    showIndicator: _showIndicator,
                    botChild: Container(
                      width: boardContentSize,
                      height: boardContentSize,
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
                          selectedTileWidget: _selectedWidget,
                          botChild: Container(
                            width: boardContentSize,
                            height: boardContentSize,
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
              duration:
                  _timerKey.currentState?.totalDuration ?? const Duration(),
              background: _selectedWidget,
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
}
