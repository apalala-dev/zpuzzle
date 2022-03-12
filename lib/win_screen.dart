import 'dart:math';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zpuzzle/asset_path.dart';
import 'package:zpuzzle/home_screen.dart';
import 'package:zpuzzle/ui/animated_board_widget.dart';
import 'package:zpuzzle/ui/fit_or_scale_widget.dart';
import 'package:zpuzzle/utils.dart';

import 'app_colors.dart';
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
        child: FitOrScaleWidget(
            minWidth: 300,
            minHeight: 300,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Screenshot(
                  controller: _screenshotController,
                  child: FitOrScaleWidget(
                    minWidth: min(screenSize.width * 0.7, 400),
                    minHeight: min(screenSize.height * 0.7, 400),
                    child: Container(
                      width: min(screenSize.width * 0.7, 400),
                      height: min(screenSize.height * 0.7, 400),
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
                            child: Align(
                              child: Padding(
                                child: Image.asset(
                                  AssetPath.dashonaut,
                                  width: screenSize.shortestSide / 5,
                                  height: screenSize.shortestSide / 5,
                                ),
                                padding: EdgeInsets.only(
                                    top: min(screenSize.width / 100, 20),
                                    right: min(screenSize.width / 100, 20)),
                              ),
                              alignment: Alignment.topRight,
                            ),
                          ),
                          Positioned.fill(
                              child: Column(children: [
                            Expanded(
                              child: Row(children: [
                                Expanded(
                                  child: Center(
                                    child: LayoutBuilder(
                                        builder: (ctx, constraints) {
                                      final contentSize = Size(
                                          constraints.maxWidth / 1.4,
                                          constraints.maxHeight / 1.4);
                                      final aroundPadding =
                                          contentSize.shortestSide / 25;
                                      final boardContentSize =
                                          contentSize.shortestSide -
                                              aroundPadding * 2;

                                      return Transform.translate(
                                        offset: Offset(contentSize.width / 3,
                                            contentSize.height / 3.2),
                                        child: Transform.rotate(
                                          angle: pi / 12,
                                          child: Padding(
                                            padding:
                                                EdgeInsets.all(aroundPadding),
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
                                                  selectedTileWidget:
                                                      widget.background,
                                                  showIndicator: false,
                                                  botChild: Container(
                                                    width: boardContentSize,
                                                    height: boardContentSize,
                                                    // padding: EdgeInsets.all(innerBoardSpacing * 2),
                                                    decoration: BoxDecoration(
                                                        color: AppColors
                                                            .perspectiveColor,
                                                        borderRadius: BorderRadius
                                                            .circular(contentSize
                                                                    .shortestSide /
                                                                30)),
                                                  ),
                                                  rotationXTween:
                                                      _rotationXTween,
                                                  rotationYTween:
                                                      _rotationYTween,
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
                                    width: screenSize.width / 2,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .congrats,
                                            style: TextStyle(
                                              fontSize: min(
                                                  screenSize.shortestSide / 16,
                                                  30),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          spacer,
                                          Text(
                                            AppLocalizations.of(context)!
                                                .puzzleChallengeCompleted,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontSize: min(
                                                    screenSize.shortestSide /
                                                        24,
                                                    20),
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .subtitle1
                                                    ?.color),
                                          ),
                                          spacer,
                                          Text(
                                            AppLocalizations.of(context)!.score,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontSize: min(
                                                    screenSize.shortestSide /
                                                        22,
                                                    20),
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .subtitle1
                                                    ?.color),
                                          ),
                                          SizedBox(
                                            height:
                                                screenSize.shortestSide / 60,
                                          ),
                                          _timer(screenSize),
                                          SizedBox(
                                            height:
                                                screenSize.shortestSide / 80,
                                          ),
                                          Text(
                                              AppLocalizations.of(context)!
                                                  .nbMoves(widget
                                                      .puzzle.history.length),
                                              style: GoogleFonts.robotoMono(
                                                fontSize: min(
                                                    screenSize.shortestSide /
                                                        22,
                                                    20),
                                                // fontWeight: FontWeight.bold,
                                              )),
                                        ])),
                                padding: EdgeInsets.only(
                                    left: min(screenSize.width / 20, 40),
                                    top: min(screenSize.width / 20, 40)),
                              ),
                              alignment: Alignment.topLeft,
                            ),
                          ),
                        ]),
                      ),
                    ),
                  )),
              SizedBox(
                height: min(screenSize.height / 20, 40),
              ),
              _share(screenSize),
            ])),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Colors.black,
    );
  }

  Widget _timer(Size screenSize) {
    const fontDivider = 22;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(widget.duration.toDisplayableString(),
          style: GoogleFonts.robotoMono(
            fontSize: min(screenSize.shortestSide / fontDivider, 20),
            // fontWeight: FontWeight.bold,
          )),
      SizedBox(width: screenSize.shortestSide / (fontDivider * 4)),
      Icon(
        Icons.timer_outlined,
        size: min(screenSize.shortestSide / fontDivider * 1.2, 20),
      ),
    ]);
  }

  Widget _share(Size screenSize) {
    return SizedBox(
      width: min(screenSize.width * 0.7, 500),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (screenSize.height / 28 > 19) ...[
          Text(
            AppLocalizations.of(context)!.shareScore,
            style: TextStyle(
                fontSize: screenSize.shortestSide / 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor),
          ),
          SizedBox(height: screenSize.height / 100),
          Text(
            AppLocalizations.of(context)!.shareScoreWithFriends,
            style: TextStyle(
                fontSize: screenSize.shortestSide / 30,
                color: Theme.of(context).textTheme.subtitle1?.color),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenSize.height / 30),
        ],
        Wrap(
            spacing: screenSize.width / 20,
            runSpacing: 4.0,
            alignment: WrapAlignment.center,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryColor)),
                onPressed: () {
                  Share.share(
                      AppLocalizations.of(context)!.shareMessage(
                          AppLocalizations.of(context)!
                              .nbMoves(widget.puzzle.history.length)
                              .toLowerCase(),
                          widget.duration.toDisplayableString()),
                      subject:
                          AppLocalizations.of(context)!.shareMessageSubject);
                },
                icon: const Icon(Icons.share),
                label: Text(AppLocalizations.of(context)!.share),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryColor)),
                onPressed: () {
                  _screenshotController
                      .capture(pixelRatio: 2)
                      .then((value) async {
                    final result = await FileSaver.instance.saveFile(
                        'zpuzzle_completed', value!, 'png',
                        mimeType: MimeType.PNG);
                    OpenFile.open(result);
                  });
                },
                icon: const Icon(Icons.download),
                label: Text(AppLocalizations.of(context)!.download),
              ),
            ])
      ]),
    );
  }
}
