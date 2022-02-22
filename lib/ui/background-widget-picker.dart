import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:mime/mime.dart';
import 'package:rive/rive.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:slide_puzzle/rive/rive-animation-bytes.dart';
import 'package:slide_puzzle/ui/crop-dialog.dart';
import 'package:supercharged_dart/supercharged_dart.dart';
import 'package:image_size_getter/image_size_getter.dart' as imgSizeGetter;

class BackgroundWidgetPicker extends StatefulWidget {
  final Function(Widget) onBackgroundPicked;

  // final RiveAnimationController riveAnimationController;

  const BackgroundWidgetPicker({
    Key? key,
    required this.onBackgroundPicked,
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
    const Image(image: AssetImage('assets/img/moon.png'), fit: BoxFit.cover),
    const Image(
        image: AssetImage('assets/img/dashatar_1.png'), fit: BoxFit.cover),
    const Image(
        image: AssetImage('assets/img/dashonaute_1.png'), fit: BoxFit.cover),
    AbsorbPointer(
      child: FlutterMap(
        options: MapOptions(
          center: LatLng(48.858370, 2.294481),
          zoom: 13.0,
          interactiveFlags: InteractiveFlag.none,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            // attributionBuilder: (_) {
            //   return const Text("© OpenStreetMap contributors");
            // },
          ),
        ],
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
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
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
      return SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: Center(
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _backgrounds.length + 1,
                shrinkWrap: true,
                itemBuilder: (context, idx) {
                  final multiplier = idx == _selectedBackground ? 1.0 : 0.7;

                  final isFilePicker = idx == _backgrounds.length;
                  Widget child;
                  if (isFilePicker) {
                    child = Icon(Icons.image);
                  } else {
                    child = _backgrounds[idx];
                  }

                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: AnimatedBuilder(
                        animation: _anims[idx]!,
                        child: child,
                        builder: (BuildContext context, Widget? child) {
                          return Transform.rotate(
                            child: Transform.scale(
                                scale: _anims[idx]!.value, child: child),
                            angle: 4 * pi * _anims[idx]!.value / 0.4,
                          );
                        },
                      ),
                    ),
                    onTap: () async {
                      if (isFilePicker) {
                        try {
                          var _paths = (await FilePicker.platform.pickFiles(
                            type: FileType.custom,
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
                            onFileLoading: (FilePickerStatus status) =>
                                print(status),
                          ))
                              ?.files;
                          String? mimeType;
                          if (_paths?.isNotEmpty == true) {
                            setState(() {
                              final tmp = _paths!.first;

                              if (tmp.extension == 'svg') {
                                _pickedFile = tmp;
                                _backgrounds.add(SvgPicture.memory(
                                  _pickedFile!.bytes!,
                                  fit: BoxFit.cover,
                                ));
                              } else if (false && tmp.extension == 'riv') {
                                _pickedFile = tmp;
                                final rivFile = RiveFile.import(
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
                                    _backgrounds.add(Image(
                                      image: MemoryImage(_pickedFile!.bytes!),
                                      fit: BoxFit.cover,
                                    ));
                                  }
                                }
                              }
                            });
                            if (mimeType != null) {
                              _animateSelection(
                                  _selectedBackground, _backgrounds.length - 1);
                              widget.onBackgroundPicked(
                                  _backgrounds[_backgrounds.length - 1]);
                            }
                          }
                        } on PlatformException catch (e) {
                          print(e);
                        } catch (e) {
                          print(e);
                        }
                      } else {
                        if (_selectedBackground != idx) {
                          _animateSelection(_selectedBackground, idx);
                          widget.onBackgroundPicked(child);
                          // onBackgroundPicked();
                        }
                      }
                      // widget.onBackgroundPicked(_dimensions[idx]);
                    },
                  );
                })),
      );
    });
  }
}
