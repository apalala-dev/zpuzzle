import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:slide_puzzle/model/position.dart';
import 'package:slide_puzzle/model/tile.dart';

// A 3x3 puzzle board visualization:
//
//   ┌─────1───────2───────3────► x
//   │  ┌─────┐ ┌─────┐ ┌─────┐
//   1  │  1  │ │  2  │ │  3  │
//   │  └─────┘ └─────┘ └─────┘
//   │  ┌─────┐ ┌─────┐ ┌─────┐
//   2  │  4  │ │  5  │ │  6  │
//   │  └─────┘ └─────┘ └─────┘
//   │  ┌─────┐ ┌─────┐
//   3  │  7  │ │  8  │
//   │  └─────┘ └─────┘
//   ▼
//   y
//
// This puzzle is in its completed state (i.e. the tiles are arranged in
// ascending order by value from top to bottom, left to right).
//
// Each tile has a value (1-8 on example above), and a correct and current
// position.
//
// The correct position is where the tile should be in the completed
// puzzle. As seen from example above, tile 2's correct position is (2, 1).
// The current position is where the tile is currently located on the board.

/// {@template puzzle}
/// Model for a puzzle.
/// {@endtemplate}
class Puzzle extends Equatable {
  /// {@macro puzzle}f
  Puzzle({required this.tiles, List<Position>? history})
      : history = history ?? [] {
    _nbMovesSink = _nbMovesSteamController.sink;
  }

  static Puzzle generate(int size, {bool shuffle = true}) {
    /// Build a randomized, solvable puzzle of the given size.
    final correctPositions = <Position>[];
    final currentPositions = <Position>[];
    final whitespacePosition = Position(x: size, y: size);

    // Create all possible board positions.
    for (var y = 1; y <= size; y++) {
      for (var x = 1; x <= size; x++) {
        if (x == size && y == size) {
          correctPositions.add(whitespacePosition);
          currentPositions.add(whitespacePosition);
        } else {
          final position = Position(x: x, y: y);
          correctPositions.add(position);
          currentPositions.add(position);
        }
      }
    }

    if (shuffle) {
      // Randomize only the current tile positions.
      currentPositions.shuffle();
    }

    var tiles = _getTileListFromPositions(
      size,
      correctPositions,
      currentPositions,
    );

    var puzzle = Puzzle(tiles: tiles);

    if (shuffle) {
      // Assign the tiles new current positions until the puzzle is solvable and
      // zero tiles are in their correct position.
      while (!puzzle.isSolvable() || puzzle.getNumberOfCorrectTiles() != 0) {
        currentPositions.shuffle();
        tiles = _getTileListFromPositions(
          size,
          correctPositions,
          currentPositions,
        );
        puzzle = Puzzle(tiles: tiles);
      }
    }

    return puzzle;
  }

  /// Build a list of tiles - giving each tile their correct position and a
  /// current position.
  static List<Tile> _getTileListFromPositions(
    int size,
    List<Position> correctPositions,
    List<Position> currentPositions,
  ) {
    final whitespacePosition = Position(x: size, y: size);
    return [
      for (int i = 1; i <= size * size; i++)
        if (i == size * size)
          Tile(
            value: i,
            correctPosition: whitespacePosition,
            currentPosition: currentPositions[i - 1],
            previousPosition: currentPositions[i - 1],
            isWhitespace: true,
          )
        else
          Tile(
            value: i,
            correctPosition: correctPositions[i - 1],
            currentPosition: currentPositions[i - 1],
            previousPosition: currentPositions[i - 1],
          )
    ];
  }

  /// List of [Tile]s representing the puzzle's current arrangement.
  final List<Tile> tiles;

  List<Position> history = [];

  int _nbMoves = 0;
  final StreamController<int> _nbMovesSteamController = StreamController<int>();

  Stream<int> get nbMovesStream => _nbMovesSteamController.stream;
  late Sink<int> _nbMovesSink;

  Puzzle clone() {
    return Puzzle(tiles: [...tiles], history: [...history]);
  }

  /// Get the dimension of a puzzle given its tile arrangement.
  ///
  /// Ex: A 4x4 puzzle has a dimension of 4.
  int getDimension() {
    return sqrt(tiles.length).toInt();
  }

  /// Get the single whitespace tile object in the puzzle.
  Tile getWhitespaceTile() {
    return tiles.singleWhere((tile) => tile.isWhitespace);
  }

  /// Gets the number of tiles that are currently in their correct position.
  int getNumberOfCorrectTiles() {
    final whitespaceTile = getWhitespaceTile();
    var numberOfCorrectTiles = 0;
    for (final tile in tiles) {
      if (tile != whitespaceTile) {
        if (tile.currentPosition == tile.correctPosition) {
          numberOfCorrectTiles++;
        }
      }
    }
    return numberOfCorrectTiles;
  }

  /// Determines if the puzzle is completed.
  bool isComplete() {
    return (tiles.length - 1) - getNumberOfCorrectTiles() == 0;
  }

  /// Determines if the tapped tile can move in the direction of the whitespace
  /// tile.
  bool isTileMovable(Tile tile) {
    final whitespaceTile = getWhitespaceTile();
    if (tile == whitespaceTile) {
      return false;
    }

    // A tile must be in the same row or column as the whitespace to move.
    if (whitespaceTile.currentPosition.x != tile.currentPosition.x &&
        whitespaceTile.currentPosition.y != tile.currentPosition.y) {
      return false;
    }
    return true;
  }

  /// Determines if the tapped tile can move in the direction of the whitespace
  /// tile.
  bool isTileMovableTowards(Tile tile, Position dest) {
    final whitespaceTile = getWhitespaceTile();
    if (tile == whitespaceTile) {
      return false;
    }

    // A tile must be in the same row or column as the whitespace to move.
    if (whitespaceTile.currentPosition.x != tile.currentPosition.x &&
        whitespaceTile.currentPosition.y != tile.currentPosition.y) {
      return false;
    } else {
      if (whitespaceTile.currentPosition.distance(dest) <
          tile.currentPosition.distance(dest)) {
        return true;
      } else {
        return false;
      }
    }
  }

  /// Determines if the puzzle is solvable.
  bool isSolvable() {
    final size = getDimension();
    final height = tiles.length ~/ size;
    assert(
      size * height == tiles.length,
      'tiles must be equal to size * height',
    );
    final inversions = countInversions();

    if (size.isOdd) {
      return inversions.isEven;
    }

    final whitespace = tiles.singleWhere((tile) => tile.isWhitespace);
    final whitespaceRow = whitespace.currentPosition.y;

    if (((height - whitespaceRow) + 1).isOdd) {
      return inversions.isEven;
    } else {
      return inversions.isOdd;
    }
  }

  /// Gives the number of inversions in a puzzle given its tile arrangement.
  ///
  /// An inversion is when a tile of a lower value is in a greater position than
  /// a tile of a higher value.
  int countInversions() {
    var count = 0;
    for (var a = 0; a < tiles.length; a++) {
      final tileA = tiles[a];
      if (tileA.isWhitespace) {
        continue;
      }

      for (var b = a + 1; b < tiles.length; b++) {
        final tileB = tiles[b];
        if (_isInversion(tileA, tileB)) {
          count++;
        }
      }
    }
    return count;
  }

  /// Determines if the two tiles are inverted.
  bool _isInversion(Tile a, Tile b) {
    if (!b.isWhitespace && a.value != b.value) {
      if (b.value < a.value) {
        return b.currentPosition.compareTo(a.currentPosition) > 0;
      } else {
        return a.currentPosition.compareTo(b.currentPosition) > 0;
      }
    }
    return false;
  }

  /// Shifts one or many tiles in a row/column with the whitespace and returns
  /// the modified puzzle.
  ///
  // Recursively stores a list of all tiles that need to be moved and passes the
  // list to _swapTiles to individually swap them.
  Puzzle moveTiles(Tile tile) {
    final oldTiles = [
      ...tiles.map((t) => t.copyWith(newCurrentPosition: t.currentPosition))
    ];

    final newPuzzle = _moveTiles(tile, []);

    for (int i = 0; i < newPuzzle.tiles.length; i++) {
      // If it already as a different previousPosition than currentPosition,
      // the previousPosition is going to be updated by the animationController
      // at the end of the animation.
      // It allows multiple animations to run at the same time.
      if (!newPuzzle.tiles[i].hasMoved()) {
        newPuzzle.tiles[i] = newPuzzle.tiles[i].copyWith(
            newPreviousPosition: oldTiles
                .firstWhere((o) => o.value == newPuzzle.tiles[i].value)
                .currentPosition);
      }
    }
    return newPuzzle;
  }

  /// Shifts one or many tiles in a row/column with the whitespace and returns
  /// the modified puzzle.
  ///
  // Recursively stores a list of all tiles that need to be moved and passes the
  // list to _swapTiles to individually swap them.
  Puzzle _moveTiles(Tile tile, List<Tile> tilesToSwap) {
    if (tilesToSwap.isEmpty) {
      _nbMovesSink.add(++_nbMoves);
    }
    final whitespaceTile = getWhitespaceTile();
    final deltaX = whitespaceTile.currentPosition.x - tile.currentPosition.x;
    final deltaY = whitespaceTile.currentPosition.y - tile.currentPosition.y;

    if ((deltaX.abs() + deltaY.abs()) > 1) {
      final shiftPointX = tile.currentPosition.x + deltaX.sign;
      final shiftPointY = tile.currentPosition.y + deltaY.sign;
      final tileToSwapWith = tiles.singleWhere(
        (tile) =>
            tile.currentPosition.x == shiftPointX &&
            tile.currentPosition.y == shiftPointY,
      );
      tilesToSwap.add(tile);
      return _moveTiles(tileToSwapWith, tilesToSwap);
    } else {
      tilesToSwap.add(tile);
      var result = _swapTiles(tilesToSwap);
      history.add(getWhitespaceTile().currentPosition);
      return result;
    }
  }

  /// Returns puzzle with new tile arrangement after individually swapping each
  /// tile in tilesToSwap with the whitespace.
  Puzzle _swapTiles(List<Tile> tilesToSwap) {
    for (final tileToSwap in tilesToSwap.reversed) {
      final tileIndex = tiles.indexOf(tileToSwap);
      final tile = tiles[tileIndex];
      final whitespaceTile = getWhitespaceTile();
      final whitespaceTileIndex = tiles.indexOf(whitespaceTile);

      // Swap current board positions of the moving tile and the whitespace.
      tiles[tileIndex] = tile.copyWith(
        newCurrentPosition: whitespaceTile.currentPosition,
      );
      tiles[whitespaceTileIndex] = whitespaceTile.copyWith(
        newCurrentPosition: tile.currentPosition,
      );
    }

    return Puzzle(tiles: tiles, history: history);
  }

  /// Sorts puzzle tiles so they are in order of their current position.
  Puzzle sort() {
    final sortedTiles = tiles.toList()
      ..sort((tileA, tileB) {
        return tileA.currentPosition.compareTo(tileB.currentPosition);
      });
    return Puzzle(tiles: sortedTiles, history: history);
  }

  List<Tile>? shortestPathBetween(
      Tile start, Tile end, List<Position> lockedPositions, int dimension,
      {int? minFound}) {
    if (minFound == 0) {
      return null;
    }
    List<List<Tile>> paths = [];
    // Find the shortest path between this and other while not going through any
    // lockedPositions in a grid of [dimension] (ignoring White Tile)
    List<Position> possibleMoves = List<Position>.from([
      start.left(lockedPositions, dimension),
      start.top(lockedPositions, dimension),
      start.right(lockedPositions, dimension),
      start.bottom(lockedPositions, dimension),
    ].where((e) => e != null));
    possibleMoves.sort((m1, m2) {
      return m1
          .distance(end.currentPosition)
          .compareTo(m2.distance(end.currentPosition));
    });

    for (var p in possibleMoves) {
      if (p == end) {
        paths.add([
          tiles.firstWhere((t) => t.currentPosition == p),
        ]);
        break;
      } else {
        var shortestTmp = shortestPathBetween(
            tiles.firstWhere((t) => t.currentPosition == p),
            end,
            lockedPositions,
            dimension,
            minFound: minFound == null ? null : minFound - 1);
        if (shortestTmp != null) {
          var totalPath = [
            tiles.firstWhere((t) => t.currentPosition == p),
            ...shortestTmp
          ];
          paths.add(totalPath);
          if (minFound == null || minFound > totalPath.length) {
            minFound = totalPath.length;
          }
        }
      }
    }

    if (paths.isEmpty) {
      return null;
    } else {
      var minPathLength = paths.map((p) => p.length).reduce(min);
      return paths.where((p) => p.length == minPathLength).first;
    }
  }

  String toVisualString() {
    String str = "";
    var dim = getDimension();
    for (int j = 0; j < dim; j++) {
      for (int k = 0; k < dim; k++) {
        str += " -";
      }
      str += " \n";
      for (int i = 1; i <= dim; i++) {
        var baseIdx = i + j * dim;
        var pos = tiles
            .firstWhere((element) => element.value == baseIdx)
            .correctPosition;
        var actualTile =
            tiles.firstWhere((element) => element.currentPosition == pos);
        str += "|${actualTile.isWhitespace ? " " : actualTile.value}";
        if (i == dim) {
          str += "|\n";
        }
      }
    }
    for (int k = 0; k < dim; k++) {
      str += " -";
    }
    str += " \n";
    return str;
  }

  @override
  List<Object> get props => [tiles];
}
