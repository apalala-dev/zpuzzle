import 'dart:math';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_file/open_file.dart';
import 'package:screenshot/screenshot.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:slide_puzzle/asset-path.dart';
import 'package:slide_puzzle/home-screen.dart';
import 'package:slide_puzzle/ui/animated-board-widget.dart';
import 'package:slide_puzzle/utils.dart';

import 'app-colors.dart';
import 'model/puzzle.dart';

class WinScreen extends StatefulWidget {
  final Puzzle puzzle;
  final Duration duration;
  final Widget background;
  final VoidCallback changeTheme;

  const WinScreen({
    Key? key,
    required this.duration,
    required this.background,
    required this.puzzle,
    required this.changeTheme,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WinScreenState();
  }
}

class _WinScreenState extends State<WinScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScreenshotController _screenshotController = ScreenshotController();

  final Tween<double> _rotationXTween =
      Tween<double>(begin: 2 * pi, end: -pi / 9);
  final Tween<double> _rotationYTween =
      Tween<double>(begin: 2 * pi, end: -pi / 9);
  final Tween<double> _scaleBoardTween = Tween<double>(begin: 0.0, end: 1.0);

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _animationController.forward();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final spacer = SizedBox(
      height: screenSize.height / 30,
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (ctx) => HomeScreen(changeTheme: widget.changeTheme)),
          );
        },
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Screenshot(
            controller: _screenshotController,
            child: Container(
              width: min(screenSize.width * 0.7, 360),
              height: min(screenSize.height * 0.7, 360),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                    )
                  ]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(children: [
                  Positioned.fill(
                      child: Container(color: AppColors.primaryColor)),
                  Positioned.fill(
                      child: Column(children: [
                    Expanded(
                      child: Row(children: [
                        Expanded(
                          child: Center(
                            child: LayoutBuilder(builder: (ctx, constraints) {
                              final contentSize = Size(
                                  constraints.maxWidth / 1.4,
                                  constraints.maxHeight / 1.4);
                              final aroundPadding =
                                  contentSize.shortestSide / 25;
                              final boardContentSize =
                                  contentSize.shortestSide - aroundPadding * 2;

                              return Transform.translate(
                                offset: Offset(contentSize.width / 3,
                                    contentSize.height / 3.2),
                                child: Transform.rotate(
                                  angle: pi / 12,
                                  child: Padding(
                                    padding: EdgeInsets.all(aroundPadding),
                                    child: SizedBox(
                                      width: boardContentSize,
                                      height: boardContentSize,
                                      child: AnimatedBoardWidget(
                                          puzzle: widget.puzzle,
                                          contentSize: contentSize,
                                          boardContentSize: Size(
                                              boardContentSize,
                                              boardContentSize),
                                          onTileMoved: (_) {},
                                          selectedTileWidget: widget.background,
                                          showIndicator: false,
                                          botChild: Container(
                                            width: boardContentSize,
                                            height: boardContentSize,
                                            // padding: EdgeInsets.all(innerBoardSpacing * 2),
                                            decoration: BoxDecoration(
                                                color: AppColors
                                                    .perspectiveColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        contentSize
                                                                .shortestSide /
                                                            30)),
                                          ),
                                          rotationXTween: _rotationXTween,
                                          rotationYTween: _rotationYTween,
                                          scaleTween: _scaleBoardTween,
                                          gyroEvent: Offset.zero,
                                          animationController:
                                              _animationController),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ]),
                    ),
                  ])),
                  Positioned.fill(
                    child: Align(
                      child: Padding(
                        child: SizedBox(
                            width: screenSize.width / 3.5,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Congrats!',
                                    style: TextStyle(
                                      fontSize: screenSize.shortestSide / 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  spacer,
                                  Text(
                                    'Puzzle challenge completed.',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: screenSize.shortestSide / 28,
                                        color: Theme.of(context)
                                            .textTheme
                                            .subtitle1
                                            ?.color),
                                  ),
                                  spacer,
                                  Text(
                                    'Score',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: screenSize.shortestSide / 28,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .textTheme
                                            .subtitle1
                                            ?.color),
                                  ),
                                  SizedBox(
                                    height: screenSize.shortestSide / 60,
                                  ),
                                  _timer(screenSize),
                                  SizedBox(
                                    height: screenSize.shortestSide / 80,
                                  ),
                                  Text("${widget.puzzle.history.length} Moves",
                                      style: TextStyle(
                                        fontSize: screenSize.shortestSide / 24,
                                        // fontWeight: FontWeight.bold,
                                      )),
                                ])),
                        padding: EdgeInsets.only(
                            left: screenSize.width / 20,
                            top: screenSize.width / 20),
                      ),
                      alignment: Alignment.topLeft,
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      child: Padding(
                        child: Image.asset(
                          AssetPath.dashonaut,
                          width: screenSize.width / 5,
                          height: screenSize.height / 5,
                        ),
                        padding: EdgeInsets.only(
                            top: screenSize.width / 100,
                            right: screenSize.width / 100),
                      ),
                      alignment: Alignment.topRight,
                    ),
                  ),
                  if (false)
                    Positioned.fill(
                      child: Align(
                        child: SizedBox(
                          width: screenSize.width / 3,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _timer(screenSize),
                                SizedBox(width: screenSize.shortestSide / 34),
                                Text("${widget.puzzle.history.length} Moves",
                                    style: TextStyle(
                                        fontSize: screenSize.shortestSide / 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.accentColor)),
                              ]),
                        ),
                        alignment: Alignment.centerRight,
                      ),
                    ),
                  if (false)
                    Positioned.fill(
                      child: Align(
                        child: Padding(
                          child: SvgPicture.asset(
                            AssetPath.zPuzzleIcon,
                            width: screenSize.width / 10,
                            height: screenSize.height / 10,
                            color: AppColors.accentColor,
                          ),
                          padding: EdgeInsets.only(
                              left: screenSize.shortestSide / 40,
                              top: screenSize.shortestSide / 40),
                        ),
                        alignment: Alignment.topLeft,
                      ),
                    )
                ]),
              ),
            ),
          ),
          SizedBox(
            height: screenSize.height / 20,
          ),
          _share(screenSize),
        ]),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Colors.black,
    );
  }

  Widget _timer(Size screenSize) {
    const fontDivider = 24;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(widget.duration.toDisplayableString(),
          style: TextStyle(
            fontSize: screenSize.shortestSide / fontDivider,
            // fontWeight: FontWeight.bold,
          )),
      SizedBox(width: screenSize.shortestSide / (fontDivider * 4)),
      Icon(
        Icons.timer_outlined,
        size: screenSize.shortestSide / fontDivider * 1.2,
      ),
    ]);
  }

  Widget _share(Size screenSize) {
    return SizedBox(
      width: min(screenSize.width * 0.7, 360),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Share your score!',
            style: TextStyle(
                fontSize: screenSize.shortestSide / 26,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor),
          ),
          SizedBox(height: screenSize.height / 100),
          Text(
            'Share your score on this puzzle with your friends and challenge them.',
            style: TextStyle(
                fontSize: screenSize.shortestSide / 32,
                color: Theme.of(context).textTheme.subtitle1?.color),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenSize.height / 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryColor)),
                onPressed: () {
                  Share.share(
                      'I completed the ZPuzzle challenge with ${widget.puzzle.history.length} moves in ⏳ ${widget.duration.toDisplayableString()} ! https://zpuzzle.web.app',
                      subject: 'ZPuzzle challenge completed');
                },
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
              SizedBox(
                width: screenSize.width / 10,
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryColor)),
                onPressed: () {
                  _screenshotController
                      .capture(pixelRatio: 2)
                      .then((value) async {
                    print('Screenshot done, value null? ${value == null}');
                    final result = await FileSaver.instance.saveFile(
                        'zpuzzle_completed', value!, 'png',
                        mimeType: MimeType.PNG);
                    OpenFile.open(result);
                  });
                },
                icon: const Icon(Icons.download),
                label: const Text('Download'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
