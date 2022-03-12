import 'dart:io';
import 'dart:math';

import 'package:analog_clock/analog_clock.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:mime/mime.dart';
import 'package:rive/rive.dart' as rive;
import 'package:slide_puzzle/asset_path.dart';
import 'package:slide_puzzle/home_screen.dart';
import 'package:slide_puzzle/rive/rive-animation-bytes.dart';
import 'package:slide_puzzle/ui/fit_or_scale_widget.dart';
import 'package:slide_puzzle/ui/zwidget_wrapper.dart';
import 'package:zwidget/zwidget.dart';

import '../pickable_widgets/basic_app.dart';

class BackgroundWidgetPicker extends StatefulWidget {
  final Widget baseWidget;
  final Function(Widget) onBackgroundPicked;
  final Widget? currentlySelectedWidget;
  final int crossAxisCount;

  // final RiveAnimationController riveAnimationController;

  const BackgroundWidgetPicker({
    Key? key,
    required this.baseWidget,
    required this.onBackgroundPicked,
    required this.crossAxisCount,
    this.currentlySelectedWidget,
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
    const Image(
        image: AssetImage('assets/img/dashatar_1.png'), fit: BoxFit.cover),
    const Image(
        image: AssetImage('assets/img/dashonaute_1.png'), fit: BoxFit.cover),
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
    Container(
      key: const ValueKey('zDashatar'),
      child: const Center(
        child: ZWidgetWrapper(
          midChild: Image(
              image: AssetImage('assets/img/dashatar_1.png'),
              fit: BoxFit.cover),
          layers: 5,
          depth: 10,
          rotationX: 0,
          rotationY: -pi / 4,
          direction: ZDirection.forwards,
          topChild: Image(
              image: AssetImage('assets/img/dashatar_1.png'),
              fit: BoxFit.cover),
        ),
      ),
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.white, Colors.black54])),
    ),
    Container(
      key: const ValueKey('zIcon'),
      child: Center(
        child: LayoutBuilder(
            builder: (ctx, constraints) => ZWidget(
                  midChild: Icon(
                    Icons.star,
                    color: Colors.grey,
                    size:
                        min(constraints.maxWidth, constraints.maxHeight) * 0.85,
                  ),
                  topChild: Icon(
                    Icons.star,
                    color: Colors.black,
                    size:
                        min(constraints.maxWidth, constraints.maxHeight) * 0.85,
                  ),
                  layers:
                      (min(constraints.maxWidth, constraints.maxHeight) * 0.05)
                          .round(),
                  depth: min(constraints.maxWidth, constraints.maxHeight) * 0.1,
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
    if (false)
      FitOrScaleWidget(
        key: const ValueKey('homeScreenKey'),
        minWidth: 600,
        minHeight: 400,
        child: AbsorbPointer(
          child: HomeScreen(changeTheme: () {}),
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
    _selectedBackground = widget.currentlySelectedWidget != null
        ? _backgrounds.indexWhere((w) =>
            w == widget.currentlySelectedWidget! ||
            w.key != null && w.key == widget.currentlySelectedWidget!.key)
        : -1;
    if (_selectedBackground == -1 && widget.currentlySelectedWidget != null) {
      _backgrounds.add(widget.currentlySelectedWidget!);
      _selectedBackground = _backgrounds.length - 1;
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
                                print("mimetype: $mimeType");
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
                          print(e);
                        } catch (e) {
                          print(e);
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
