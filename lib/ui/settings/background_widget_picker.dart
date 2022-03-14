import 'dart:io';
import 'dart:math';

import 'package:analog_clock/analog_clock.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_color/flutter_color.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:mime/mime.dart';
import 'package:rive/rive.dart' as rive;
import 'package:zpuzzle/asset_path.dart';
import 'package:zpuzzle/home_screen.dart';
import 'package:zpuzzle/rive/rive-animation-bytes.dart';
import 'package:zpuzzle/ui/fit_or_scale_widget.dart';
import 'package:zpuzzle/ui/zwidget_wrapper.dart';
import 'package:zwidget/zwidget.dart';

import '../pickable_widgets/basic_app.dart';

class BackgroundWidgetPicker extends StatefulWidget {
  final Widget baseWidget;
  final Function(Widget) onBackgroundPicked;
  final Widget currentlySelectedWidget;
  final int crossAxisCount;

  // final RiveAnimationController riveAnimationController;

  const BackgroundWidgetPicker({
    Key? key,
    required this.baseWidget,
    required this.onBackgroundPicked,
    required this.crossAxisCount,
    required this.currentlySelectedWidget,
    // required this.riveAnimationController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BackgroundWidgetPickerState();
  }
}

class _BackgroundWidgetPickerState extends State<BackgroundWidgetPicker>
    with SingleTickerProviderStateMixin {
  final custom = "custom";
  final picker = "picker";
  final List<Widget> _backgrounds = [
    // const Image(image: AssetImage(AssetPath.dashatar), fit: BoxFit.cover),
    if (!kIsWeb)
      Container(
        key: const ValueKey('zFlutter'),
        child: Center(
          child: ZWidgetWrapper(
            midChild: SvgPicture.asset(
              AssetPath.flutter,
              color: Colors.black87,
            ),
            midToBotChild: SvgPicture.asset(
              AssetPath.flutter,
              color: Colors.blueGrey,
            ),
            layers: 21,
            depth: 30,
            alignment: Alignment.center,
            rotationX: -pi / 3,
            rotationY: 0,
            direction: ZDirection.both,
            topChild: SvgPicture.asset(AssetPath.flutter),
          ),
        ),
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.black, Colors.white],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft)),
      ),
    if (!kIsWeb)
      Container(
        key: const ValueKey('zDashatar'),
        child: const Center(
          child: ZWidgetWrapper(
            midChild:
                Image(image: AssetImage(AssetPath.dashatar), fit: BoxFit.cover),
            layers: 5,
            depth: 10,
            rotationX: 0,
            rotationY: -pi / 4,
            direction: ZDirection.forwards,
            topChild:
                Image(image: AssetImage(AssetPath.dashatar), fit: BoxFit.cover),
          ),
        ),
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.lime, Colors.greenAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
      ),
    const Image(
        key: ValueKey('img01'),
        image: AssetImage(AssetPath.img01),
        fit: BoxFit.cover),
    const Image(
        key: ValueKey('img02'),
        image: AssetImage(AssetPath.img02),
        fit: BoxFit.cover),
    AnalogClock(
      key: const ValueKey('clockKey'),
      decoration: BoxDecoration(
          border: Border.all(width: 2.0, color: Colors.black),
          color: Colors.white,
          shape: BoxShape.circle),
      width: 150.0,
      isLive: true,
      hourHandColor: Colors.black,
      minuteHandColor: Colors.black,
      showSecondHand: true,
      secondHandColor: Colors.red,
      numberColor: Colors.black87,
      showNumbers: true,
      textScaleFactor: 1.4,
      showTicks: true,
      showDigitalClock: false,
      // datetime: DateTime(2019, 1, 1, 9, 12, 15),
    ),
    const FitOrScaleWidget(
      key: ValueKey('basicAppKey'),
      minWidth: 200,
      minHeight: 200,
      child: AbsorbPointer(
        child: BasicApp(),
        absorbing: true,
      ),
    ),
    const Image(
        key: ValueKey('img03'),
        image: AssetImage(AssetPath.img03),
        fit: BoxFit.cover),
    const Image(
        key: ValueKey('img04'),
        image: AssetImage(AssetPath.img04),
        fit: BoxFit.cover),
    AbsorbPointer(
      key: const ValueKey('zMap'),
      child: FlutterMap(
        options: MapOptions(
          center: LatLng(48.858370, 2.294481),
          zoom: 13.0,
          interactiveFlags: InteractiveFlag.none,
        ),
        layers: [
          TileLayerOptions(
            tileProvider: !kIsWeb &&
                    (Platform.isLinux || Platform.isWindows || Platform.isMacOS)
                ? NetworkTileProvider()
                : const NonCachingNetworkTileProvider(),
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            // attributionBuilder: (_) {
            //   return const Text("© OpenStreetMap contributors");
            // },
          ),
        ],
      ),
    ),
    const Image(
        key: ValueKey('img06'),
        image: AssetImage(AssetPath.img06),
        fit: BoxFit.cover),
    Container(
      key: const ValueKey('zGirlStudent'),
      child: const Center(
        child: ZWidgetWrapper(
          midChild: Image(
              image: AssetImage(AssetPath.girlGraduationStudent),
              color: Colors.black,
              fit: BoxFit.cover),
          layers: 7,
          depth: 15,
          rotationX: 0,
          rotationY: pi / 4,
          direction: ZDirection.forwards,
          topChild: Image(
              image: AssetImage(AssetPath.girlGraduationStudent),
              fit: BoxFit.cover),
        ),
      ),
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.white, Colors.black54])),
    ),
    Container(
      key: const ValueKey('zStudentGraduationDance'),
      child: const Center(
        child: ZWidgetWrapper(
          midChild: Image(
              image: AssetImage(AssetPath.studentGraduationDance),
              color: Colors.black,
              fit: BoxFit.cover),
          layers: 7,
          depth: 15,
          rotationX: pi / 9,
          rotationY: pi / 6,
          direction: ZDirection.forwards,
          topChild: Image(
              image: AssetImage(AssetPath.studentGraduationDance),
              fit: BoxFit.cover),
        ),
      ),
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.white, Colors.black54])),
    ),
    if (!kIsWeb)
      Container(
        key: const ValueKey('zIcon'),
        child: Center(
          child: LayoutBuilder(
              builder: (ctx, constraints) => ZWidgetWrapper(
                    midChild: Icon(
                      Icons.star,
                      color: Colors.grey,
                      size: min(constraints.maxWidth, constraints.maxHeight) *
                          0.85,
                    ),
                    topChild: Icon(
                      Icons.star,
                      color: Colors.black,
                      size: min(constraints.maxWidth, constraints.maxHeight) *
                          0.85,
                    ),
                    layers: (min(constraints.maxWidth, constraints.maxHeight) *
                            0.05)
                        .round(),
                    depth:
                        min(constraints.maxWidth, constraints.maxHeight) * 0.1,
                    perspective: 0.5,
                    direction: ZDirection.forwards,
                    rotationX: pi / 9,
                    rotationY: -pi / 5,
                  )),
        ),
        decoration: const BoxDecoration(
          gradient: RadialGradient(colors: [Colors.white, Colors.amber]),
        ),
      ),
    const Image(
        key: ValueKey('dashonaut'),
        image: AssetImage(AssetPath.dashonaut),
        fit: BoxFit.cover),
    if (false)
      FitOrScaleWidget(
        key: const ValueKey('homeScreenKey'),
        minWidth: 600,
        minHeight: 400,
        child: AbsorbPointer(
          child: HomeScreen(changeTheme: (_) {}),
          absorbing: true,
        ),
      )
  ];
  int _selectedBackground = 0;
  PlatformFile? _pickedFile;

  late AnimationController _animationController;
  late Map<int, Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _backgrounds.insert(0, widget.baseWidget);
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    if (widget.baseWidget.key == widget.currentlySelectedWidget.key) {
      _selectedBackground = 1;
    } else {
      _selectedBackground = _backgrounds.indexWhere((w) =>
          w == widget.currentlySelectedWidget ||
          w.key != null && w.key == widget.currentlySelectedWidget.key);
      if (_selectedBackground == -1) {
        _backgrounds.add(widget.currentlySelectedWidget);
        _selectedBackground = _backgrounds.length - 1;
      } else {
        _selectedBackground++;
      }
    }
    _animateSelection(-1, _selectedBackground, updateUi: false);
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _animationController.forward();
    });
  }

  _animateSelection(int idxPreviousSelection, int idxNewSelection,
      {bool updateUi = true}) {
    _anims = {};

    for (var d in [for (int i = 0; i <= _backgrounds.length + 1; i++) i]) {
      if (d == idxPreviousSelection) {
        _anims[idxPreviousSelection] = Tween<double>(begin: 1.0, end: 0.6)
            .animate(CurvedAnimation(
                parent: _animationController, curve: Curves.easeInOut));
      } else if (d == idxNewSelection) {
        _anims[d] = Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(
            parent: _animationController, curve: Curves.fastOutSlowIn));
      } else {
        _anims[d] = const AlwaysStoppedAnimation(0.6);
      }
    }
    if (updateUi) {
      setState(() {
        _selectedBackground = idxNewSelection;
        _animationController.reset();
        _animationController.forward();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Center(
        child: SizedBox(
          height: constraints.maxHeight,
          child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.crossAxisCount,
                  crossAxisSpacing:
                      min(constraints.maxWidth, constraints.maxHeight) / 80,
                  mainAxisSpacing:
                      min(constraints.maxWidth, constraints.maxHeight) / 80),
              scrollDirection: Axis.vertical,
              itemCount: _backgrounds.length + 1,
              itemBuilder: (context, index) {
                // final multiplier = idx == _selectedBackground ? 1.0 : 0.7;

                final isFilePicker = index == 0;
                Widget child;
                if (isFilePicker) {
                  child = Padding(
                    child: SvgPicture.asset(AssetPath.pickImage,
                        color: Theme.of(context).textTheme.titleLarge?.color),
                    padding: EdgeInsets.all(constraints.maxWidth / 40),
                  );
                } else {
                  child = _backgrounds[index - 1];
                }

                return Material(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: AnimatedBuilder(
                        animation: _anims[index]!,
                        child: ClipRRect(
                          child: child,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        builder: (BuildContext context, Widget? child) {
                          return Transform.rotate(
                            child: Transform.scale(
                                scale: _anims[index]!.value, child: child),
                            angle: 4 * pi * _anims[index]!.value / 0.4,
                          );
                        },
                      ),
                    ),
                    onTap: () async {
                      if (isFilePicker) {
                        try {
                          var _paths = (await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            withData: kIsWeb ||
                                !(Platform.isLinux ||
                                    Platform.isWindows ||
                                    Platform.isMacOS),
                            allowMultiple: false,
                            allowedExtensions: [
                              'jpg',
                              'jpeg',
                              'png',
                              'gif',
                              'bmp',
                              'svg',
                              // 'riv' // Disabled for now
                            ],
                          ))
                              ?.files;
                          String? mimeType;
                          if (_paths?.isNotEmpty == true) {
                            setState(() {
                              final tmp = _paths!.first;

                              if (tmp.extension == 'svg') {
                                _pickedFile = tmp;
                                _backgrounds.insert(
                                    1,
                                    SvgPicture.memory(
                                      _pickedFile!.bytes!,
                                      fit: BoxFit.cover,
                                    ));
                              } else if (false && tmp.extension == 'riv') {
                                _pickedFile = tmp;
                                final rivFile = rive.RiveFile.import(
                                    ByteData.sublistView(_pickedFile!.bytes!));
                                _backgrounds.add(RiveAnimationBytes.bytes(
                                  ByteData.sublistView(_pickedFile!.bytes!),
                                  fit: BoxFit.cover,
                                  // controllers: [widget.riveAnimationController],
                                ));
                              } else {
                                if (kIsWeb) {
                                  mimeType = 'image/any';
                                } else {
                                  mimeType = lookupMimeType(tmp.path!);
                                }
                                if (mimeType != null) {
                                  final fileType = mimeType!.split('/');
                                  final type = fileType[0];
                                  _pickedFile = tmp;
                                  if (type == 'image') {
                                    // test to add the option withdata to see if it works better
                                    _backgrounds.insert(
                                        0,
                                        Image(
                                          image: (kIsWeb ||
                                                  !(Platform.isLinux ||
                                                      Platform.isWindows ||
                                                      Platform.isMacOS))
                                              ? MemoryImage(_pickedFile!.bytes!)
                                              : FileImage(
                                                      File(_pickedFile!.path!))
                                                  as ImageProvider,
                                          fit: BoxFit.cover,
                                        ));
                                  }
                                }
                              }
                            });
                            if (mimeType != null) {
                              _animateSelection(_selectedBackground, 1);
                              widget.onBackgroundPicked(_backgrounds[0]);
                            }
                          }
                        } on PlatformException catch (e) {
                          if (kDebugMode) {
                            print(e);
                          }
                        } catch (e) {
                          if (kDebugMode) {
                            print(e);
                          }
                        }
                      } else {
                        if (_selectedBackground != index) {
                          _animateSelection(_selectedBackground, index);
                          widget.onBackgroundPicked(child);
                          // onBackgroundPicked();
                        }
                      }
                      // widget.onBackgroundPicked(_dimensions[idx]);
                    },
                  ),
                );
              }),
        ),
      );
    });
  }
}
