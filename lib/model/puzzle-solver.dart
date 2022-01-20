import 'dart:math';

import 'package:slide_puzzle/model/position.dart';
import 'package:slide_puzzle/model/puzzle.dart';
import 'package:slide_puzzle/model/tile.dart';

class PuzzleSolver {
  /// Part 1: Solve top row
  /// Part 2: Solve left column
  /// Part 3: Repeat until 3x2 puzzle remains
  /// Part 4: Solve the 3x2 puzzle
  Puzzle solve(Puzzle puzzle) {
    var dim = puzzle.getDimension();

    Tile toMove;
    List<Tile> lockedTiles = [];

    int nbRowsToLock = puzzle.getDimension() - 2;
    int nbColumnsToLock = puzzle.getDimension() - 3;

    var pos3x2 = [
      Position(x: dim, y: dim),
      Position(x: dim - 1, y: dim),
      Position(x: dim - 2, y: dim),
      Position(x: dim, y: dim - 1),
      Position(x: dim - 1, y: dim - 1),
      Position(x: dim - 2, y: dim - 1),
    ];

    // Part 1
    // Move tile n°1 to top left corner
    int idxColumn = 1;
    int idxRow = 1;
    for (int i = 1; i <= nbRowsToLock + nbColumnsToLock; i++) {
      List<Position> posToTake;

      if (i.isOdd) {
        // Take a Row and handle it
        posToTake = [
          for (int x = idxColumn; x <= dim; x++) Position(x: x, y: idxRow)
        ];
        idxRow++;
      } else {
        // Take a Column and handle it
        posToTake = [
          for (int y = idxRow; y <= dim; y++) Position(x: idxColumn, y: y)
        ];
        idxColumn++;
      }

      for (int k = 0; k < posToTake.length - 2; k++) {
        var p = posToTake[k];
        toMove = puzzle.tiles.firstWhere((e) => e.correctPosition == p);
        puzzle = moveTileToPosition(puzzle, toMove, toMove.correctPosition,
            lockedTiles.map((e) => e.correctPosition).toList());
        lockedTiles.add(puzzle.tiles.firstWhere((e) => e.correctPosition == p));
      }
      // Now I need to place last tiles of the Row/Column

      // Put both in a place where we can move them wherever we need later first
      // Note: this adds more moves
      var bottomRightCorner = Position(x: dim, y: dim);
      var nextToBottomRightCorner =
          Position(x: dim + (i.isEven ? 0 : -1), y: dim + (i.isEven ? -1 : 0));

      var bottomRightCornerTile = puzzle.tiles.firstWhere(
          (e) => e.correctPosition == posToTake[posToTake.length - 1]);
      // var nextToBottomRightCornerTile = puzzle.tiles.firstWhere(
      //     (e) => e.correctPosition == posToTake[posToTake.length - 2]);

      puzzle = moveTileToPosition(puzzle, bottomRightCornerTile,
          bottomRightCorner, [...lockedTiles.map((e) => e.correctPosition)]);

      // Refresh tiles now that we moved them
      bottomRightCornerTile = puzzle.tiles.firstWhere(
          (e) => e.correctPosition == posToTake[posToTake.length - 1]);
      // nextToBottomRightCornerTile = puzzle.tiles.firstWhere(
      //     (e) => e.correctPosition == posToTake[posToTake.length - 2]);

      // print(
      //     "try to move ${nextToBottomRightCornerTile.value} to ${puzzle.tiles.firstWhere((t) => t.currentPosition == nextToBottomRightCorner).value} ($nextToBottomRightCorner) with i=$i");
      // puzzle = moveTileToPosition(
      //     puzzle,
      //     nextToBottomRightCornerTile,
      //     nextToBottomRightCorner,
      //     [bottomRightCorner, ...lockedTiles.map((e) => e.correctPosition)]);

      bottomRightCornerTile = puzzle.tiles.firstWhere(
          (e) => e.correctPosition == posToTake[posToTake.length - 1]);
      // nextToBottomRightCornerTile = puzzle.tiles.firstWhere(
      //     (e) => e.correctPosition == posToTake[posToTake.length - 2]);

      // Now place them in position to be moved into their correct position
      // First put dim-1 tile on top right corner (for a Row) or bottom left corner (for a Column)
      toMove = puzzle.tiles.firstWhere(
          (e) => e.correctPosition == posToTake[posToTake.length - 2]);
      puzzle = moveTileToPosition(
          puzzle,
          toMove,
          posToTake[posToTake.length - 1],
          lockedTiles.map((e) => e.correctPosition).toList());
      var tmpLockedTile = posToTake[posToTake.length - 1];
      // lockedTiles.add(puzzle.tiles.firstWhere((e) => e.correctPosition == p));

      toMove = puzzle.tiles.firstWhere(
          (e) => e.correctPosition == posToTake[posToTake.length - 1]);
      var secondLockedTile = Position(
          x: toMove.correctPosition.x + (i.isOdd ? 0 : 1),
          y: toMove.correctPosition.y + (i.isOdd ? 1 : 0));
      puzzle = moveTileToPosition(puzzle, toMove, secondLockedTile,
          [tmpLockedTile, ...lockedTiles.map((e) => e.correctPosition)]);

      // I need to put a whitespace in dim-1 correctPosition with both tiles locked
      puzzle = moveWhiteTileTo(puzzle, posToTake[posToTake.length - 2], [
        tmpLockedTile,
        secondLockedTile,
        ...lockedTiles.map((e) => e.correctPosition)
      ]);

      // Move dim-1 tile to its correctPosition (one move only needed)
      puzzle = puzzle.moveTiles(
          puzzle.tiles.firstWhere((t) => t.currentPosition == tmpLockedTile),
          []);
      lockedTiles.add(puzzle.tiles.firstWhere(
          (t) => t.currentPosition == posToTake[posToTake.length - 2]));
      // Move dim tile to its correctPosition (one move only needed)
      puzzle = puzzle.moveTiles(
          puzzle.tiles.firstWhere((t) => t.currentPosition == secondLockedTile),
          []);
      lockedTiles.add(puzzle.tiles.firstWhere(
          (t) => t.currentPosition == posToTake[posToTake.length - 1]));
      // Row or column should be fixed now!
    }

    if (puzzle.tiles
        .where((t) => !t.isInCorrectPosition)
        .map((t) => t.currentPosition)
        .where((p) => !pos3x2.contains(p))
        .isEmpty) {
      // Tiles not in the 3x2 final grid are in good position
      // break;
      print("we're good to go for the 3x2 grid");
    }
    // return puzzle;
    return solve3x2(puzzle);
  }

  Puzzle solve3x2(Puzzle puzzle) {
    var dim = puzzle.getDimension();
    Position prime1EndPos = Position(x: dim - 2, y: dim - 1);
    Position prime4EndPos = Position(x: dim - 2, y: dim);
    Tile prime1 =
        puzzle.tiles.firstWhere((t) => t.correctPosition == prime1EndPos);
    Tile prime4 =
        puzzle.tiles.firstWhere((t) => t.correctPosition == prime4EndPos);
    List<Position> baseLocked = [
      ...puzzle.tiles
          .where((t) => !(t.currentPosition.x >= puzzle.getDimension() - 2 &&
              t.currentPosition.y >= puzzle.getDimension() - 1))
          .map((t) => t.currentPosition)
    ];

    if (!(prime1.isInCorrectPosition && prime4.isInCorrectPosition)) {
      // Put them in the good position to just have to solve the 2x2 puzzle
      var white = puzzle.getWhitespaceTile();
      if (white.currentPosition.y != dim - 1) {
        // TODO check if necessart
        puzzle = moveWhiteTileTo(puzzle,
            Position(x: white.currentPosition.x, y: dim - 1), baseLocked);
      }
      print("A:\n${puzzle.toVisualString()}");
      prime4 =
          puzzle.tiles.firstWhere((t) => t.correctPosition == prime4EndPos);
      puzzle = moveTileToPosition(
          puzzle, prime4, Position(x: dim, y: dim), baseLocked);
      prime1 =
          puzzle.tiles.firstWhere((t) => t.correctPosition == prime1EndPos);
      prime4 =
          puzzle.tiles.firstWhere((t) => t.correctPosition == prime4EndPos);
      print("B:\n${puzzle.toVisualString()}");
      var tmpWhite = puzzle.getWhitespaceTile();
      if (tmpWhite.currentPosition.x == dim) {
        puzzle = moveWhiteTileTo(
            puzzle,
            Position(
                x: tmpWhite.currentPosition.x - 1,
                y: tmpWhite.currentPosition.y),
            baseLocked);
      }
      print("C:\n${puzzle.toVisualString()}");
      puzzle = moveTileToPosition(
          puzzle,
          puzzle.tiles.firstWhere((t) => t.correctPosition == prime1EndPos),
          prime4EndPos,
          baseLocked);
      print("D:\n${puzzle.toVisualString()}");
      puzzle = moveTileToPosition(
          puzzle,
          puzzle.tiles.firstWhere((t) => t.correctPosition == prime4EndPos),
          Position(x: dim - 1, y: dim),
          [...baseLocked, prime4EndPos]);
      print("E:\n${puzzle.toVisualString()}");
      puzzle = moveTileToPosition(
          puzzle,
          puzzle.tiles.firstWhere((t) => t.correctPosition == prime1EndPos),
          prime1EndPos,
          [...baseLocked, Position(x: dim - 1, y: dim)]);
      print("F:\n${puzzle.toVisualString()}");
      puzzle = moveTileToPosition(
          puzzle,
          puzzle.tiles.firstWhere((t) => t.correctPosition == prime4EndPos),
          prime4EndPos,
          baseLocked);
      // rotation2x2(
      //   puzzle,
      //   puzzle.tiles.firstWhere(
      //       (t) => t.currentPosition == Position(x: dim - 1, y: dim - 1)),
      //   puzzle.tiles.firstWhere(
      //       (t) => t.currentPosition == Position(x: dim, y: dim - 1)),
      //   puzzle.tiles
      //       .firstWhere((t) => t.currentPosition == Position(x: dim, y: dim)),
      //   puzzle.tiles.firstWhere(
      //       (t) => t.currentPosition == Position(x: dim - 1, y: dim)),
      // );
    }
    print("G:\n${puzzle.toVisualString()}");

    var locked = [
      ...baseLocked,
      prime1EndPos,
      prime4EndPos,
    ];

    // After this we have a 2x2 puzzle to solve, by rotating pieces around until
    // they match well
    var firstOf2x2 = puzzle.tiles.firstWhere((t) =>
        t.correctPosition ==
        Position(x: puzzle.getDimension() - 1, y: puzzle.getDimension() - 1));
    puzzle = moveTileToPosition(
        puzzle, firstOf2x2, firstOf2x2.correctPosition, locked);

    // Place the whitetile in its correctPosition
    // Other tiles should be placed correctly automatically
    return moveWhiteTileTo(
        puzzle, puzzle.getWhitespaceTile().correctPosition, locked);

    return puzzle;
  }

  Puzzle solve3x2old(Puzzle puzzle) {
    // In terms of 3x2 grid, we need first to put 1' in bottom left corner,
    // then 4' in middle bottom. Then we only have to move them so they fill
    // their correct place
//   ┌─────1───────2───────3────► x
//   │  ┌─────┐ ┌─────┐ ┌─────┐
//   1  │  ?  │ │  ?  │ │  ?  │
//   │  └─────┘ └─────┘ └─────┘
//   │  ┌─────┐ ┌─────┐ ┌─────┐
//   2  │  1' │ │  4' │ │  ?  │
//   │  └─────┘ └─────┘ └─────┘
//   ▼w

    // 1' is:
    Position topLeft =
        Position(x: puzzle.getDimension() - 2, y: puzzle.getDimension() - 1);
    Position bottomLeft =
        Position(x: puzzle.getDimension() - 2, y: puzzle.getDimension());

    // Place topLeft and bottomLeft tiles in the scheme configuration above
    var firstToMove =
        puzzle.tiles.firstWhere((e) => e.correctPosition == topLeft);
    puzzle = moveTileToPosition(
        puzzle,
        firstToMove,
        Position(x: puzzle.getDimension() - 2, y: puzzle.getDimension()),
        puzzle.tiles
            .where((t) => !(t.currentPosition.x >= puzzle.getDimension() - 2 &&
                t.currentPosition.y >= puzzle.getDimension() - 1))
            .map((t) => t.currentPosition)
            .toList());

    firstToMove = puzzle.tiles.firstWhere((e) => e.correctPosition == topLeft);
    var secondToMove =
        puzzle.tiles.firstWhere((e) => e.correctPosition == bottomLeft);
    puzzle = moveTileToPosition(puzzle, secondToMove,
        Position(x: puzzle.getDimension() - 1, y: puzzle.getDimension()), [
      ...puzzle.tiles
          .where((t) => !(t.currentPosition.x >= puzzle.getDimension() - 2 &&
              t.currentPosition.y >= puzzle.getDimension() - 1))
          .map((t) => t.currentPosition),
      firstToMove.currentPosition
    ]);
    firstToMove = puzzle.tiles.firstWhere((e) => e.correctPosition == topLeft);
    secondToMove =
        puzzle.tiles.firstWhere((e) => e.correctPosition == bottomLeft);

    // Then move topLeft tile to its correct position
    puzzle =
        moveTileToPosition(puzzle, firstToMove, firstToMove.correctPosition, [
      ...puzzle.tiles
          .where((t) => !(t.currentPosition.x >= puzzle.getDimension() - 2 &&
              t.currentPosition.y >= puzzle.getDimension() - 1))
          .map((t) => t.currentPosition),
      secondToMove.currentPosition
    ]);
    firstToMove = puzzle.tiles.firstWhere((e) => e.correctPosition == topLeft);
    secondToMove =
        puzzle.tiles.firstWhere((e) => e.correctPosition == bottomLeft);

    // Then move bottomLeft tile to its correct position
    puzzle =
        moveTileToPosition(puzzle, secondToMove, secondToMove.correctPosition, [
      ...puzzle.tiles
          .where((t) => !(t.currentPosition.x >= puzzle.getDimension() - 2 &&
              t.currentPosition.y >= puzzle.getDimension() - 1))
          .map((t) => t.currentPosition),
      firstToMove.currentPosition
    ]);

    // topLeft and bottomLeft must be locked now
    var locked = [
      ...puzzle.tiles
          .where((t) => !(t.currentPosition.x >= puzzle.getDimension() - 2 &&
              t.currentPosition.y >= puzzle.getDimension() - 1))
          .map((t) => t.currentPosition),
      firstToMove.correctPosition,
      secondToMove.correctPosition
    ];

    // After this we have a 2x2 puzzle to solve, by rotating pieces around until
    // they match well
    var firstOf2x2 = puzzle.tiles.firstWhere((t) =>
        t.correctPosition ==
        Position(x: puzzle.getDimension() - 1, y: puzzle.getDimension() - 1));
    puzzle = moveTileToPosition(
        puzzle, firstOf2x2, firstOf2x2.correctPosition, locked);

    // Place the whitetile in its correctPosition
    // Other tiles should be placed correctly automatically
    return moveWhiteTileTo(
        puzzle, puzzle.getWhitespaceTile().correctPosition, locked);
  }

  Puzzle moveTileToPosition(Puzzle basePuzzle, Tile tile, Position dest,
      List<Position> lockedPosition) {
    // Should not move already well placed tiles
    Puzzle puzzle = basePuzzle.clone();
    var pathToDest = shortestPathBetween(
        puzzle,
        tile,
        puzzle.tiles.firstWhere((t) => t.currentPosition == dest),
        lockedPosition,
        puzzle.getDimension());
    if (pathToDest != null) {
      for (var p in {...pathToDest}) {
        var whiteTile = puzzle.getWhitespaceTile();
        if (p.currentPosition != whiteTile.currentPosition) {
          // First move the WhiteTile to p so we can swap p and whiteTile after
          moveWhiteTileTo(puzzle, p.currentPosition, [
            puzzle.tiles
                .firstWhere((t) => t.value == tile.value)
                .currentPosition,
            ...lockedPosition
          ]);
        }
        // Swap p and WhiteTile
        puzzle = puzzle.moveTiles(
            puzzle.tiles.firstWhere((t) => t.value == tile.value), []);
        // Don't come back to the tile we're on now
        // lockedPosition.add(p.currentPosition);
        // Don't come back to the current white tile neither?
      }
    }
    return puzzle;
  }

  List<Tile>? shortestPathBetween(Puzzle puzzle, Tile start, Tile end,
      List<Position> lockedPositions, int dimension,
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
      if (p == end.currentPosition) {
        paths.add([
          puzzle.tiles.firstWhere((t) => t.currentPosition == p),
        ]);
        break;
      } else {
        var shortestTmp = shortestPathBetween(
            puzzle,
            puzzle.tiles.firstWhere((t) => t.currentPosition == p),
            end,
            [...lockedPositions, p],
            dimension,
            minFound: minFound == null ? null : minFound - 1);
        if (shortestTmp != null) {
          var totalPath = [
            puzzle.tiles.firstWhere((t) => t.currentPosition == p),
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

  Puzzle moveWhiteTileTo(
      Puzzle puzzle, Position dest, List<Position> lockedPositions) {
    var pathWhiteToP = shortestPathBetween(
        puzzle,
        puzzle.getWhitespaceTile(),
        puzzle.tiles.firstWhere((t) => t.currentPosition == dest),
        lockedPositions,
        puzzle.getDimension());
    if (pathWhiteToP == null) {
      print(puzzle);
      throw Exception(
          "Can't find path between WhiteSpace and ${puzzle.tiles.firstWhere((t) => t.currentPosition == dest).value}.\nLockedTiles:${lockedPositions.map((p) => puzzle.tiles.firstWhere((t) => p == t.currentPosition).value)}\n${puzzle.toVisualString()}");
    }
    for (var pW in pathWhiteToP) {
      // Move the white tile one step at a time
      puzzle = puzzle.moveTiles(pW, []);
    }
    return puzzle;
  }

  Puzzle rotation3x2(
      Puzzle puzzle, List<Tile> tiles, Position whiteTileEndPosition,
      {bool leftToRight = true}) {
    if (tiles.where((t) => t.isWhitespace).isEmpty) {
      throw Exception("3x2 tile list does not contain whiteSpace");
    } else if (tiles.length != 6) {
      throw Exception("3x2 tile list does not contain 6 tiles");
    }
    if (puzzle.getWhitespaceTile().currentPosition == whiteTileEndPosition) {
      return puzzle;
    }
    var dim = puzzle.getDimension();
    do {
      var white = puzzle.getWhitespaceTile();
      var curWhite = white.currentPosition;

      // Note: code can be shorter but it might be harder to understand well
      if (leftToRight) {
        if (curWhite.y == dim) {
          if (curWhite.x == dim - 2) {
            // Go Up
            puzzle = puzzle.moveTiles(
                tiles.firstWhere((t) =>
                    t.currentPosition ==
                    Position(x: curWhite.x, y: curWhite.y - 1)),
                []);
          } else {
            // Go left
            puzzle = puzzle.moveTiles(
                tiles.firstWhere((t) =>
                    t.currentPosition ==
                    Position(x: curWhite.x - 1, y: curWhite.y)),
                []);
          }
        } else {
          if (curWhite.x == dim) {
            // Go down
            puzzle = puzzle.moveTiles(
                tiles.firstWhere((t) =>
                    t.currentPosition ==
                    Position(x: curWhite.x, y: curWhite.y + 1)),
                []);
          } else {
            // Go right
            puzzle = puzzle.moveTiles(
                tiles.firstWhere((t) =>
                    t.currentPosition ==
                    Position(x: curWhite.x + 1, y: curWhite.y)),
                []);
          }
        }
      } else {
        if (curWhite.y == dim - 1) {
          if (curWhite.x == dim - 2) {
            // Go Down
            puzzle = puzzle.moveTiles(
                tiles.firstWhere((t) =>
                    t.currentPosition ==
                    Position(x: curWhite.x, y: curWhite.y + 1)),
                []);
          } else {
            // Go left
            puzzle = puzzle.moveTiles(
                tiles.firstWhere((t) =>
                    t.currentPosition ==
                    Position(x: curWhite.x - 1, y: curWhite.y)),
                []);
          }
        } else {
          if (curWhite.x == dim) {
            // Go Up
            puzzle = puzzle.moveTiles(
                tiles.firstWhere((t) =>
                    t.currentPosition ==
                    Position(x: curWhite.x, y: curWhite.y - 1)),
                []);
          } else {
            // Go right
            puzzle = puzzle.moveTiles(
                tiles.firstWhere((t) =>
                    t.currentPosition ==
                    Position(x: curWhite.x + 1, y: curWhite.y)),
                []);
          }
        }
      }
    } while (
        puzzle.getWhitespaceTile().currentPosition != whiteTileEndPosition);

    return puzzle;
  }

  Puzzle rotation2x2(Puzzle puzzle, Tile topLeftTile, Tile topRightTile,
      Tile bottomLeftTile, Tile bottomRightTile, Position whiteTileEndPosition,
      {bool leftToRight = true}) {
    var dim = puzzle.getDimension();
    if (!topLeftTile.isWhitespace &&
        !topRightTile.isWhitespace &&
        !bottomLeftTile.isWhitespace &&
        !bottomRightTile.isWhitespace) {
      throw Exception("2x2 tile list does not contain whiteSpace");
    } else if (!(topLeftTile.right([], dim) == topRightTile.currentPosition &&
        topRightTile.bottom([], dim) == bottomRightTile.currentPosition &&
        bottomRightTile.left([], dim) == bottomLeftTile.currentPosition &&
        bottomLeftTile.top([], dim) == topLeftTile.currentPosition)) {
      throw Exception("Tiles are not placed in a 2x2 grid");
    }
    if (puzzle.getWhitespaceTile().currentPosition == whiteTileEndPosition) {
      return puzzle;
    }

    do {
      var white = puzzle.getWhitespaceTile();
      var curWhite = white.currentPosition;

      Position topLeft = topLeftTile.currentPosition;
      Position topRight = topRightTile.currentPosition;
      Position bottomLeft = bottomLeftTile.currentPosition;
      Position bottomRight = bottomRightTile.currentPosition;

      if (curWhite == topLeft) {
        puzzle =
            moveWhiteTileTo(puzzle, leftToRight ? topRight : bottomLeft, []);
      } else if (curWhite == topRight) {
        puzzle =
            moveWhiteTileTo(puzzle, leftToRight ? bottomRight : topLeft, []);
      } else if (curWhite == bottomRight) {
        puzzle =
            moveWhiteTileTo(puzzle, leftToRight ? bottomLeft : topRight, []);
      } else if (curWhite == bottomLeft) {
        puzzle =
            moveWhiteTileTo(puzzle, leftToRight ? topLeft : bottomRight, []);
      }
    } while (
        puzzle.getWhitespaceTile().currentPosition != whiteTileEndPosition);

    return puzzle;
  }
}
