import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_size_getter/image_size_getter.dart' as imgSizeGetter;
import 'package:rive/rive.dart';
import 'package:slide_puzzle/model/puzzle-solver.dart';
import 'package:slide_puzzle/model/puzzle.dart';
import 'package:slide_puzzle/puzzle-board-widget.dart';
import 'package:image/image.dart' as imglib;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:slide_puzzle/ui/background/space-widget.dart';
import 'package:slide_puzzle/ui/background/space-widget2.dart';
import 'package:slide_puzzle/ui/settings/background-picker.dart';
import 'package:slide_puzzle/ui/settings/background-widget-picker.dart';
import 'package:slide_puzzle/ui/settings/crop-dialog.dart';
import 'package:slide_puzzle/ui/settings/size-picker.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

class NewGameScreen extends StatefulWidget {
  const NewGameScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NewGameScreenState();
  }
}

class _NewGameScreenState extends State<NewGameScreen>
    with TickerProviderStateMixin {
  late Puzzle _puzzle;
  int _puzzleSize = 3;

  Offset? _mousePosition;
  StreamSubscription<int>? _nbMovesListener;
  int _nbMoves = 0;

  final List<String> _assetImgs = [
    "assets/img/dashatar_1.png",
    "assets/img/dashonaute_1.png",
    "assets/img/dashonaute_2.png",
  ];
  int _idxDashImg = 0;

  final totalAnim = 8000;
  final tileEnterAnimTile = 700;
  AnimationController? _animationController;
  late List<Animation<double>> _tileEnterAnimation;
  late List<Animation<double>> _letterDepthAnimation;
  late List<Animation<double>> _letterFadeAnimation;
  late Animation<double> _flipAnimation;

  bool _solving = false;
  bool _started = false;
  bool _tilesAppearing = true;

  Uint8List? _pickedImageCropped;
  ImageProvider? _pickedImageProvider;
  double? _pickedImageSize;

  Widget? _selectedWidget;

  @override
  void initState() {
    super.initState();
    _initPuzzle();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      Size size = MediaQuery.of(context).size;
      var canvasRect = Offset.zero & size;

      gyroscopeEvents.listen((GyroscopeEvent event) {
        // print("gyro: ${event.x}, ${event.y}, ${event.z}");
        _mousePosition = Offset(event.x * 100, event.y * 100);
      });
      // _loadImage();
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  _initPuzzle() {
    _puzzle = Puzzle.generate(_puzzleSize, shuffle: true);
    _nbMovesListener?.cancel();
    _nbMovesListener = _puzzle.nbMovesStream.listen((e) {
      setState(() {
        _nbMoves = e;
      });
    });
    _initEnterAnim();
  }

  @override
  Widget build(BuildContext context) {
    var canvasRect = Offset.zero & MediaQuery.of(context).size;
    double percentInclinaisonY = (_mousePosition != null
        ? (_mousePosition!.dx - canvasRect.center.dx) / 5
        : 0.0);

    Widget content = MouseRegion(
      child: Stack(children: [
        // const Positioned.fill(
        //     child: SpaceWidget(
        //   title: "Flutter Puzzle Hack",
        // )),
        const Positioned.fill(
            child: SpaceWidget2(
          title: "Flutter Puzzle Hack",
        )),
        Positioned.fill(
          child: Align(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.1, end: 1.0),
              duration: const Duration(milliseconds: 2000),
              curve: Curves.easeInOut,
              builder: (ctx, anim, child) => Transform.scale(
                child: child,
                scale: anim,
              ),
              child: const SizedBox(
                child: RiveAnimation.asset(
                  'assets/rive/earth.riv',
                  fit: BoxFit.scaleDown,
                ),
                height: 100,
                width: 100,
              ),
            ),
            alignment: Alignment.centerLeft,
          ),
        ),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.1, end: 1.0),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOut,
          builder: (ctx, anim, child) => Transform.scale(
            child: child,
            scale: anim,
          ),
          child: Column(children: [
            Text(
              "Flutter Puzzle Hack",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.shortestSide / 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _started ? _startedControls() : _notStartedControls(),
              transitionBuilder: (child, anim) {
                return FadeTransition(
                  opacity: anim,
                  child: ScaleTransition(
                    child: child,
                    scale: anim,
                  ),
                );
              },
            ),
            Expanded(
              child: AnimatedBuilder(
                  animation: _animationController!,
                  builder: (context, child) {
                    return OldPuzzleBoardWidget(
                      mousePosition: _mousePosition,
                      // Offset(canvasRect.center.dx,
                      //     canvasRect.center.dy),
                      xPercent: 0,
                      yPercent: -0.35,
                      puzzle: _puzzle,
                      imageProvider: _pickedImageCropped == null
                          ? const AssetImage("assets/img/moon.png")
                              as ImageProvider
                          : MemoryImage(_pickedImageCropped!),
                      imgSize:
                          _pickedImageSize == null ? 1668.0 : _pickedImageSize!,
                      tileEnterAnimation: _tileEnterAnimation,
                      flipAnimation: _flipAnimation,
                      tileLetterFadeAnimation: _letterFadeAnimation,
                      tileLetterDepthAnimation: _letterDepthAnimation,
                      exiting: !_tilesAppearing,
                      backgroundWidget: _selectedWidget,
                    );
                  }),
            ),
            if (false)
              Flexible(
                  child: GestureDetector(
                child: Image.asset(
                  _assetImgs[_idxDashImg],
                  width: 200,
                  height: 200,
                ),
                onTap: () {
                  _idxDashImg++;
                  if (_idxDashImg >= _assetImgs.length) {
                    _idxDashImg = 0;
                  }
                },
              )),
          ]),
        )
      ]),
      onHover: (event) {
        // print("hover ${event.position}");
        setState(() {
          _mousePosition = event.position;
        });
      },
    );

    return content;
  }

  _initEnterAnim() {
    final nbTiles = _puzzle.getDimension() * _puzzle.getDimension();

    final tileEnterAnimTime = nbTiles * tileEnterAnimTile * 0.3;
    const flipTime = 1200;
    final tileTextDepthTime = nbTiles * tileEnterAnimTile * 0.1;
    final tileTextOpacityTime = nbTiles * tileEnterAnimTile * 0.05;
    var totalTime =
        (tileEnterAnimTime + flipTime + tileTextDepthTime + tileTextOpacityTime)
            .round();

    final tilesAnimPart = tileEnterAnimTime / totalTime;
    final textAnimPart = tileTextDepthTime / totalTime;
    final textAnimFadePart = tileTextOpacityTime / totalTime;

    _animationController?.dispose();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: totalTime));

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
                  tilesAnimPart *
                      (i * tileEnterAnimTile + i * spacing) /
                      totalTimeTiles,
                  tilesAnimPart *
                      ((i + 1) * tileEnterAnimTile + i * spacing) /
                      totalTimeTiles,
                  curve: Curves.easeInBack,
                ),
              ))
    ];

    _flipAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Interval(
        tilesAnimPart,
        1.0 - textAnimPart - textAnimFadePart,
        // curve: Curves.fastOutSlowIn,
        curve: Curves.easeInOutBack,
      ),
    ));
    // _flipAnimation = TweenSequence<double>(
    //   <TweenSequenceItem<double>>[
    //     TweenSequenceItem<double>(
    //       tween: Tween<double>(begin: 1.0, end: 0.0)
    //           .chain(CurveTween(curve: Curves.easeInOutBack)),
    //       weight: baseFlipTime / totalTime,
    //     ),
    //     TweenSequenceItem<double>(
    //       tween: ConstantTween<double>(0.0),
    //       weight: tileEnterAnimTime / totalTime,
    //     ),
    //     TweenSequenceItem<double>(
    //       tween: Tween<double>(begin: 0.0, end: 1.0)
    //           .chain(CurveTween(curve: Curves.easeInOutBack)),
    //       weight: baseFlipTime / totalTime,
    //     ),
    //   ],
    // ).animate(_animationController!);

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
            _puzzle.tiles.firstWhere((element) => element.currentPosition == h));
      });
    }
    setState(() {
      _solving = false;
    });
  }

  Widget _startedControls() {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      key: const ValueKey(1),
      height: size.height / 4,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Text.rich(TextSpan(
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
              fontSize: MediaQuery.of(context).size.shortestSide / 24,
              color: Colors.black,
            ))),
        Row(mainAxisSize: MainAxisSize.min, children: [
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _started = false;
                  _tilesAppearing = false;
                });
              },
              child: Text("RESET")),
          const SizedBox(
            width: 20,
          ),
          if (_solving)
            OutlinedButton(
                onPressed: () {
                  setState(() {
                    _solving = false;
                  });
                },
                child: Text("CANCEL"))
          else
            ElevatedButton(
                onPressed: () {
                  _solve();
                },
                child: Text("SOLVE")),
        ]),
        ElevatedButton(
            onPressed: () {
              initExitAnim();

              if (_animationController!.isCompleted) {
                setState(() {
                  _animationController!.reset();
                });
              } else {
                setState(() {
                  _tilesAppearing = false;
                });
                _animationController!.forward();
                _animationController!.addStatusListener((status) {
                  if (status == AnimationStatus.completed) {
                    setState(() {
                      _started = false;
                    });
                  }
                });
              }
            },
            child: Text("EXIT"))
      ]),
    );
  }

  Widget _notStartedControls() {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      key: const ValueKey(2),
      height: size.height / 4,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        SizedBox(
          child: SizePicker(onSizePicked: (size) {
            _puzzleSize = size;
          }),
          height: size.height / 16,
        ),
        // SizedBox(
        //   child:
        //       BackgroundPicker(onBackgroundPicked: (imageProvider, imageSize) {
        //     setState(() {
        //       _pickedImageProvider = imageProvider;
        //       _pickedImageSize = imageSize;
        //     });
        //   }),
        //   height: size.height / 16,
        // ),
        SizedBox(
          child: BackgroundWidgetPicker(onBackgroundPicked: (selectedWidget) {
            setState(() {
              _selectedWidget = selectedWidget;
            });
          }),
          height: size.height / 16,
        ),
        if (false && _pickedImageProvider != null)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                image: DecorationImage(image: _pickedImageProvider!)),
          ),
        ElevatedButton(
            onPressed: () {
              _initPuzzle();
              setState(() {
                if (_animationController!.isCompleted) {
                  _animationController!.reset();
                } else {
                  setState(() {
                    _tilesAppearing = true;
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
            },
            child: Text("START")),
      ]),
    );
  }
}
