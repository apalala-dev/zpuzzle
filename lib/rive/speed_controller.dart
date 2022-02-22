import 'package:rive/rive.dart';

class SpeedController extends SimpleAnimation {
  final double speedMultiplier;

  /// Stops the animation on the next apply
  bool _stopOnNextApply = false;

  SpeedController(
    String animationName, {
    double mix = 1,
    this.speedMultiplier = 1,
    bool autoplay = true,
  }) : super(animationName, mix: mix, autoplay: autoplay);

  @override
  void apply(RuntimeArtboard artboard, double elapsedSeconds) {
    if (_stopOnNextApply || instance == null) {
      isActive = false;
    }

    instance!.animation.apply(instance!.time, coreContext: artboard, mix: mix);
    if (!instance!.advance(elapsedSeconds * speedMultiplier)) {
      _stopOnNextApply = true;
    }
  }

  @override
  void onActivate() => _stopOnNextApply = false;
}
