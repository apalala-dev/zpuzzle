# ZPuzzle

A slide puzzle made with Flutter for the Flutter Puzzle Hack.

Its core features are:

- **3D effect**: 3D like animations using the plugin made for this hackathon, `zwidget`
- **Widget as background**: Use of almost any Widget as background of the puzzle. You can also pick
  your own images, including Gif.
- **Correct position indicators**: They point towards the correct position of each tile.
- **Auto-solve**: An easy to learn approach is used so the player can reproduce it.
- **Responsive design**: Looks well on almost any screen size.
- **Multiplatform**: Works on Mobile, Desktop and Web (with limitations on the Web)
- **Inputs**: Play the puzzle with your mouse or keyboard on Desktop and Web or by tapping on the tiles on
  Mobile
- **Gyroscope**: Use the gyroscope to see the 3D effect in action on Mobile

Find the details of each feature below.

## 3D effect

Overlapping widgets with some matrix transformations can lead to a 3D like effect. That's what
ZWidget uses to make this effect. Find more on the Github repo
of [ZWidget](https://github.com/apalala-dev/zwidget) or
on [pub.dev](https://pub.dev/packages/zwidget).

## Widget as background

The use of the OverflowBox widget with an alignment calculated using a FractionalOffset is the key
for this feature. This is what it looks:

``` dart
Stack(children: [
    Positioned.fill(
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: OverflowBox(
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          alignment: fracOff,
          child: SizedBox(
            child: widget.child,
            height: nbTiles * widget.tileSize,
            width: nbTiles * widget.tileSize,
          ),
        ),
      ),
    ),
    Center(child: indicator),
])
```

Once this was done, I just had to place the `PuzzleTileAnyWidget` in a `Stack` with `Positioned`
widget.

## Correct position indicators

`MaybeShowIndicator` determines if it should show and eventually animate our indicator or not.

It should show the indicator if it's on a tile that is not in its correct position.

It should appear/disappear with an animation if:

- it moved from its correct position to an incorrect position or the reverse,
- the user asked to show/hide it. I use the `didUpdateWidget()` to check if the user changed the
  showIndicator setting and I animate the appearance or disappearance of the indicator in
  consequence.

It should also animate the rotation of the indicator if the angle between is current position and
its correct position has changed.

## Auto-solve

Instead of taking an approach where the AI would find the best or one of the best set of moves to
solve the puzzle by trying a lot of moves, I decided to use a more human approach that I found
on [wikiHow](https://www.wikihow.com/Solve-Slide-Puzzles). Thanks to this, the player might learn
the AI technique by looking how it solves the puzzle. This method is not the best in terms of moves
or time it takes to complete the puzzle so the player might still beat the AI score. To make this
feature, I used an unit test to iterate quickly on the solve feature and make sure that everything
kept working after changes.

## Responsive design

I used the LayoutBuilder a lot to determine my Widgets maxWidth and maxHeight and made them depend
on it. Font sizes are based on these measures until a minimal width and height where I scale the
whole interface instead. This way, the UI keeps looking well on almost any screen size. I made a
specific widget for the scale feature: `FitOrScaleWidget` that again also uses `OverflowBox`
and `LayoutBuilder`.

## Multiplatform

ZPuzzle works well on Mobile, Desktop and Web.

It has been well tested on MacOS since I own one. However, it was not very convenient to have a
Windows and Linux device with a development environment set to test on these platforms. It should
work on these, but since I could not test them I didn't include them here.

Mobile platform has one feature that others don't have: it can use the gyroscope to move the tiles
and see the 3D effect in motion.

Working with the Web platform was the most painful point for me in this project. I expected it to
work similarly to the Desktop platform, but instead I ran into several performances problems which
cost me a lot of time. The use of a lot of animations and/or a lot of widgets made the app become
unresponsive. Even displaying a simple Gif could lead to unresponsiveness without much logs. It
seemed to be (at least partially) related
to [an issue](https://github.com/flutter/flutter/issues/98275) on the Skia engine. As a workaround,
I disabled the use of my package `ZWidget` on Web since it draws a lot of widgets and used shadows
instead where applicable. I don't think it solves every case, but most of my tests ran well after
that.

The Web platform has other problems: for instance, we can't use `Isolates`. I also had to use the
canvasKit renderer to prevent issues with the html renderer and general performances are lower than
on other platforms.

Despite the issues on the Web, I was quite happy and proud to be able to build once for every
platform with only occasional changes for each. I will definitively consider building more apps for
Desktop and Web. I hope that the later one will getting better and better and especially that our
Flutter web apps will become more SEO friendly.

## Inputs

Flutter handles pretty well the use of the mouse in addition to touch controls with the InkWell
widgets. It just worked out of the box which is really nice!

I added the use of the arrow keys to move the tiles on platforms that support it (mostly Desktop and
Web). The process was quite easy and it ran well very quickly.

## Gyroscope

I added a gyroscope feature to be able to rotate the board and see better the 3D tiles. However, I
am not fully satisfied with this feature, especially with getting the current x, y and z values of
the gyroscope. More works need to be done to improve it.