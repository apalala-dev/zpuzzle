import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slide_puzzle/model/puzzle.dart';
import 'package:slide_puzzle/puzzle-board-widget.dart';
import 'package:image/image.dart' as imglib;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:slide_puzzle/space-widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GameScreenState();
  }
}

class _GameScreenState extends State<GameScreen> {
  late Puzzle _puzzle;
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
    _puzzle = Puzzle.generate(3, shuffle: false);
    _nbMovesListener?.cancel();
    _nbMovesListener = _puzzle.nbMovesStream.listen((e) {
      setState(() {
        _nbMoves = e;
      });
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
        const Positioned.fill(
            child: SpaceWidget(
          title: "Flutter Puzzle Hack",
        )),
        Row(children: [
          Expanded(
              child: PuzzleBoardWidget(
            mousePosition: _mousePosition,
            tileEnterAnimation: [const AlwaysStoppedAnimation<double>(1)],
            tileLetterDepthAnimation: [const AlwaysStoppedAnimation<double>(1)],
            tileLetterFadeAnimation: [const AlwaysStoppedAnimation<double>(1)],
            flipAnimation: const AlwaysStoppedAnimation<double>(1),
            puzzle: _puzzle,
            imageProvider: const AssetImage("assets/img/moon.png"),
            imgSize: 1668,
          )),
          Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                Text(
                  "Flutter Puzzle Hack",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.shortestSide / 20,
                    color: Colors.white,
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
                      color: Colors.white,
                    ))),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _puzzle = Puzzle.generate(3);
                      });
                    },
                    child: Text("RESET")),
                GestureDetector(
                  child: Image.asset(_assetImgs[_idxDashImg]),
                  onTap: () {
                    _idxDashImg++;
                    if (_idxDashImg >= _assetImgs.length) {
                      _idxDashImg = 0;
                    }
                  },
                ),
              ])),
        ])
      ]),
      onHover: (event) {
        // print("hover ${event.position}");
        // setState(() {
        _mousePosition = event.position;
        // });
      },
    );

    return content;
  }
}
