import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_size_getter/image_size_getter.dart' as imgSizeGetter;
import 'package:slide_puzzle/model/puzzle-solver.dart';
import 'package:slide_puzzle/model/puzzle.dart';
import 'package:slide_puzzle/puzzle-board-widget.dart';
import 'package:image/image.dart' as imglib;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:slide_puzzle/space-widget.dart';
import 'package:slide_puzzle/ui/crop-dialog.dart';
import 'package:slide_puzzle/ui/size-picker.dart';
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
  final totalAnim = 8000;
  final tileEnterAnimTile = 700;
  Offset? _mousePosition;
  StreamSubscription<int>? _nbMovesListener;
  int _nbMoves = 0;
  imglib.Image? _boardImg;
  List<Image>? _images;
  List<String> _assetImgs = [
    "assets/img/dashatar_1.png",
    "assets/img/dashonaute_1.png",
    "assets/img/dashonaute_2.png",
  ];
  int _idxDashImg = 0;

  AnimationController? _animationController;
  late List<Animation<double>> _tileEnterAnimation;
  late List<Animation<double>> _letterDepthAnimation;
  late List<Animation<double>> _letterFadeAnimation;
  late Animation<double> _flipAnimation;

  bool _solving = false;
  Uint8List? _pickedImageCropped;
  double? _pickedImageSize;

  @override
  void initState() {
    super.initState();
    _initPuzzle();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      Size size = MediaQuery.of(context).size;
      var canvasRect = Offset.zero & size;

      gyroscopeEvents.listen((GyroscopeEvent event) {
        print("gyro: ${event.x}, ${event.y}, ${event.z}");
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

  _loadImage() async {
    _boardImg = imglib.decodeImage(
        (await rootBundle.load("assets/img/moon.png")).buffer.asUint8List());
    print("image should not be null now ${_boardImg == null}");
    setState(() {});
    if (_boardImg != null) {
      _images = splitImage(
          inputImage: _boardImg!,
          horizontalPieceCount: _puzzle.getDimension(),
          verticalPieceCount: _puzzle.getDimension());
      print("We got ${_images?.length}");
      setState(() {});
    }
  }

  List<Image> splitImage({
    required imglib.Image inputImage,
    required int horizontalPieceCount,
    required int verticalPieceCount,
  }) {
    imglib.Image image = inputImage;

    final int xLength = (image.width / horizontalPieceCount).round();
    final int yLength = (image.height / verticalPieceCount).round();
    List<imglib.Image> pieceList = [];

    for (int y = 0; y < verticalPieceCount; y++) {
      for (int x = 0; x < horizontalPieceCount; x++) {
        pieceList.add(
          imglib.copyCrop(image, x, y, x * xLength, y * yLength),
        );
      }
    }

    //Convert image from image package to Image Widget to display
    List<Image> outputImageList = [];
    for (imglib.Image img in pieceList) {
      outputImageList.add(
        Image.memory(
          Uint8List.fromList(imglib.encodePng(img)),
        ),
      );
    }

    return outputImageList;
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
            ? const AlwaysStoppedAnimation<double>(1)
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
        Column(children: [
          Text(
            "Flutter Puzzle Hack",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.shortestSide / 20,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text.rich(TextSpan(
              children: [
                TextSpan(
                    text: "${_nbMoves}",
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
          SizedBox(
            child: SizePicker(onSizePicked: (size) {
              _puzzleSize = size;
            }),
            height: MediaQuery.of(context).size.height / 8,
          ),
          Row(children: [
            if (_pickedImageCropped == null)
              Image.asset(
                "assets/img/moon.png",
                width: 100,
                height: 100,
              )
            else
              Image.memory(
                _pickedImageCropped!,
                width: 100,
                height: 100,
              ),
            ElevatedButton(
                onPressed: () async {
                  try {
                    var _paths = (await FilePicker.platform.pickFiles(
                      type: FileType.image,
                      allowMultiple: false,
                      onFileLoading: (FilePickerStatus status) => print(status),
                    ))
                        ?.files;
                    if (_paths?.isNotEmpty == true) {
                      var pickedImage = _paths!.first;
                      var croppedImage = await CropDialog.show(context,
                          imageData: pickedImage.bytes!);
                      if (croppedImage != null) {
                        var imgSize = imgSizeGetter.ImageSizeGetter.getSize(
                            imgSizeGetter.MemoryInput(croppedImage));
                        var shortestImgSide =
                            min(imgSize.width, imgSize.height).toDouble();
                        setState(() {
                          _pickedImageCropped = croppedImage;
                          _pickedImageSize = shortestImgSide;
                        });
                      }
                    }
                  } on PlatformException catch (e) {
                    print(e);
                  } catch (e) {
                    print(e);
                  }
                },
                child: Text("Pick image")),
          ]),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _puzzle = Puzzle.generate(3);
                });
              },
              child: Text("RESET")),
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
          Expanded(
            child: AnimatedBuilder(
                animation: _animationController!,
                builder: (context, child) {
                  return PuzzleBoardWidget(
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
                  );
                }),
          ),
          ElevatedButton(
              onPressed: () {
                _initPuzzle();
                setState(() {});

                if (_animationController!.isCompleted) {
                  setState(() {
                    _animationController!.reset();
                  });
                } else {
                  _animationController!.forward();
                }
              },
              child: Text("Animate")),
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
        ])
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
}
