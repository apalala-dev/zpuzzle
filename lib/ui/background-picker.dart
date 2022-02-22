import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:slide_puzzle/ui/crop-dialog.dart';
import 'package:supercharged_dart/supercharged_dart.dart';
import 'package:image_size_getter/image_size_getter.dart' as imgSizeGetter;

class BackgroundPicker extends StatefulWidget {
  final Function(ImageProvider, double) onBackgroundPicked;

  const BackgroundPicker({Key? key, required this.onBackgroundPicked})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BackgroundPickerState();
  }
}

class _BackgroundPickerState extends State<BackgroundPicker>
    with SingleTickerProviderStateMixin {
  final custom = "custom";
  final picker = "picker";
  final _backgrounds = [
    "assets/img/moon.png",
    "assets/img/dashatar_1.png",
    "assets/img/dashonaute_1.png"
  ];
  int _selectedBackground = 0;
  Uint8List? _imagePicked;
  late AnimationController _animationController;
  late Map<String, Animation<double>> _anims;

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
    String? previousDim;
    if (idxPreviousSelection == -1) {
      previousDim = null;
    } else if (idxPreviousSelection >= _backgrounds.length) {
      previousDim = custom;
    } else {
      previousDim = _backgrounds[idxPreviousSelection];
    }
    String? newDim;
    if (idxNewSelection == -1) {
      newDim = null;
    } else if (idxNewSelection >= _backgrounds.length) {
      newDim = custom;
    } else {
      newDim = _backgrounds[idxNewSelection];
    }

    _anims = {};

    for (var d in [..._backgrounds, custom, picker]) {
      if (d == previousDim) {
        _anims[d] =
            Tween<double>(begin: 1.0, end: 0.7).animate(_animationController);
      } else if (d == newDim) {
        _anims[d] =
            Tween<double>(begin: 0.7, end: 1.0).animate(_animationController);
      } else {
        _anims[d] = const AlwaysStoppedAnimation(0.7);
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
                itemCount:
                    _backgrounds.length + 1 + (_imagePicked == null ? 0 : 1),
                shrinkWrap: true,
                itemBuilder: (context, idx) {
                  final multiplier = idx == _selectedBackground ? 1.0 : 0.7;
                  final isImagePicked =
                      idx == _backgrounds.length && _imagePicked != null;
                  final isFilePicker =
                      idx == _backgrounds.length && _imagePicked == null ||
                          idx == _backgrounds.length + 1;

                  ImageProvider? imageProvider;
                  if (isImagePicked) {
                    imageProvider = MemoryImage(_imagePicked!);
                  } else if (isFilePicker) {
                    // No image provider for picker
                  } else {
                    imageProvider = AssetImage(_backgrounds[idx]);
                  }

                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: AnimatedBuilder(
                        animation: _anims[isImagePicked
                            ? custom
                            : isFilePicker
                                ? picker
                                : _backgrounds[idx]]!,
                        child: DecoratedBox(
                          child: isFilePicker ? const Icon(Icons.image) : Ink(),
                          decoration: BoxDecoration(
                              image: imageProvider == null
                                  ? null
                                  : DecorationImage(image: imageProvider),
                              border:
                                  Border.all(width: 1, color: Colors.black54),
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        builder: (BuildContext context, Widget? child) {
                          return Transform.scale(
                              scale: _anims[isImagePicked
                                      ? custom
                                      : isFilePicker
                                          ? picker
                                          : _backgrounds[idx]]!
                                  .value,
                              child: child);
                        },
                      ),
                    ),
                    onTap: () async {
                      if (isFilePicker) {
                        try {
                          var _paths = (await FilePicker.platform.pickFiles(
                            type: FileType.image,
                            allowMultiple: false,
                            onFileLoading: (FilePickerStatus status) =>
                                print(status),
                          ))
                              ?.files;
                          if (_paths?.isNotEmpty == true) {
                            var pickedImage = _paths!.first;
                            _imagePicked = pickedImage.bytes!;
                            onBackgroundPicked();

                            // var croppedImage = await CropDialog.show(context,
                            //     imageData: pickedImage.bytes!);
                            // if (croppedImage != null) {
                            //   _imagePicked = croppedImage;
                            //   _animateSelection(_selectedBackground, idx);
                            //   onBackgroundPicked();
                            // }
                          }
                        } on PlatformException catch (e) {
                          print(e);
                        } catch (e) {
                          print(e);
                        }
                      } else {
                        if (_selectedBackground != idx) {
                          _animateSelection(_selectedBackground, idx);
                          onBackgroundPicked();
                        }
                      }
                      // widget.onBackgroundPicked(_dimensions[idx]);
                    },
                  );
                })),
      );
    });
  }

  void onBackgroundPicked() {
    ImageProvider imageProvider;
    double shortestSide = 1668; // Assume all assets image are same size
    if (_selectedBackground == _backgrounds.length) {
      imageProvider = MemoryImage(_imagePicked!);
      var imgSize = imgSizeGetter.ImageSizeGetter.getSize(
          imgSizeGetter.MemoryInput(_imagePicked!));
      shortestSide = min(imgSize.width, imgSize.height).toDouble();
    } else {
      imageProvider = AssetImage(_backgrounds[_selectedBackground]);
    }
    widget.onBackgroundPicked(imageProvider, shortestSide);
  }
}
