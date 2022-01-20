import 'dart:math';

import 'package:slide_puzzle/model/position.dart';
import 'package:slide_puzzle/model/puzzle-solver.dart';
import 'package:slide_puzzle/model/puzzle.dart';
import 'package:slide_puzzle/model/tile.dart';
import 'package:test/test.dart';

void main() {
  var randomPuzzle1 = Puzzle(tiles: const [
    Tile(
        value: 1,
        correctPosition: Position(x: 1, y: 1),
        currentPosition: Position(x: 2, y: 1),
        isWhitespace: false),
    Tile(
        value: 2,
        correctPosition: Position(x: 2, y: 1),
        currentPosition: Position(x: 3, y: 1),
        isWhitespace: false),
    Tile(
        value: 3,
        correctPosition: Position(x: 3, y: 1),
        currentPosition: Position(x: 1, y: 1),
        isWhitespace: false),
    Tile(
        value: 4,
        correctPosition: Position(x: 4, y: 1),
        currentPosition: Position(x: 1, y: 3),
        isWhitespace: false),
    Tile(
        value: 5,
        correctPosition: Position(x: 1, y: 2),
        currentPosition: Position(x: 2, y: 2),
        isWhitespace: false),
    Tile(
        value: 6,
        correctPosition: Position(x: 2, y: 2),
        currentPosition: Position(x: 4, y: 1),
        isWhitespace: false),
    Tile(
        value: 7,
        correctPosition: Position(x: 3, y: 2),
        currentPosition: Position(x: 4, y: 3),
        isWhitespace: false),
    Tile(
        value: 8,
        correctPosition: Position(x: 4, y: 2),
        currentPosition: Position(x: 1, y: 4),
        isWhitespace: false),
    Tile(
        value: 9,
        correctPosition: Position(x: 1, y: 3),
        currentPosition: Position(x: 3, y: 3),
        isWhitespace: false),
    Tile(
        value: 10,
        correctPosition: Position(x: 2, y: 3),
        currentPosition: Position(x: 1, y: 2),
        isWhitespace: false),
    Tile(
        value: 11,
        correctPosition: Position(x: 3, y: 3),
        currentPosition: Position(x: 4, y: 4),
        isWhitespace: false),
    Tile(
        value: 12,
        correctPosition: Position(x: 4, y: 3),
        currentPosition: Position(x: 3, y: 2),
        isWhitespace: false),
    Tile(
        value: 13,
        correctPosition: Position(x: 1, y: 4),
        currentPosition: Position(x: 4, y: 2),
        isWhitespace: false),
    Tile(
        value: 14,
        correctPosition: Position(x: 2, y: 4),
        currentPosition: Position(x: 3, y: 4),
        isWhitespace: false),
    Tile(
        value: 15,
        correctPosition: Position(x: 3, y: 4),
        currentPosition: Position(x: 2, y: 4),
        isWhitespace: false),
    Tile(
        value: 16,
        correctPosition: Position(x: 4, y: 4),
        currentPosition: Position(x: 2, y: 3),
        isWhitespace: true),
  ]);

  test("Tiles order", () {
    Puzzle puzzle = Puzzle.generate(4);
    PuzzleSolver solver = PuzzleSolver();

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
      print("Take $posToTake");

      for (var p in posToTake) {
        toMove = puzzle.tiles.firstWhere((e) => e.currentPosition == p);
        // moveTileToPosition(
        //     puzzle, toMove, lockedTiles.map((e) => e.currentPosition).toList());
        lockedTiles.add(toMove);
      }
    }

    print("izokah");
  });

  test("Shortest path test", () {
    Puzzle puzzle = Puzzle.generate(4, shuffle: false);
    PuzzleSolver solver = PuzzleSolver();
    var dim = puzzle.getDimension();

    var shortestPath = solver.shortestPathBetween(
        puzzle,
        puzzle.tiles.firstWhere((t) => t.value == 6),
        puzzle.tiles.firstWhere((t) => t.value == 1),
        [],
        dim);
    equals(shortestPath?.length, 2);

    shortestPath = solver.shortestPathBetween(
        puzzle,
        puzzle.tiles.firstWhere((t) => t.value == 14),
        puzzle.tiles.firstWhere((t) => t.value == 1),
        [],
        dim);
    equals(shortestPath?.length, 4);

    shortestPath = solver.shortestPathBetween(
        puzzle,
        puzzle.tiles.firstWhere((t) => t.value == 7),
        puzzle.tiles.firstWhere((t) => t.value == 1),
        [const Position(x: 2, y: 1), const Position(x: 2, y: 2)],
        dim);
    equals(shortestPath?.length, 5);
  });

  test("Move tile test", () {
    Puzzle puzzle = Puzzle.generate(4, shuffle: false);
    PuzzleSolver solver = PuzzleSolver();
    const newT1Position = Position(x: 3, y: 3);
    var newPuzzle = solver.moveTileToPosition(
      puzzle,
      puzzle.tiles.firstWhere((element) => element.value == 1),
      newT1Position,
      [],
    );
    assert(
        newPuzzle.tiles
                .firstWhere((element) => element.value == 1)
                .currentPosition ==
            newT1Position,
        "New T1 position is not good: ${newPuzzle.tiles.firstWhere((element) => element.value == 1).currentPosition} should be $newT1Position}");
  });

  test("Test solve first tile", () {
    PuzzleSolver solver = PuzzleSolver();
    Puzzle puzzle = randomPuzzle1;

    puzzle = solver.moveTileToPosition(
      puzzle,
      puzzle.tiles.firstWhere((t) => t.value == 1),
      puzzle.tiles.firstWhere((t) => t.value == 1).correctPosition,
      [],
    );
    var firstTile = puzzle.tiles.firstWhere((t) => t.value == 1);
    assert(firstTile.currentPosition == firstTile.correctPosition,
        "First tile is not in its correctPosition: $firstTile");

    puzzle = solver.moveTileToPosition(
      puzzle,
      puzzle.tiles.firstWhere((t) => t.value == 2),
      puzzle.tiles.firstWhere((t) => t.value == 2).correctPosition,
      [firstTile.correctPosition],
    );
    var secondTile = puzzle.tiles.firstWhere((t) => t.value == 2);
    assert(secondTile.currentPosition == secondTile.correctPosition,
        "Second tile is not in its correctPosition: $secondTile");

    puzzle = solver.moveTileToPosition(
      puzzle,
      puzzle.tiles.firstWhere((t) => t.value == 3),
      puzzle.tiles.firstWhere((t) => t.value == 3).correctPosition,
      [firstTile.correctPosition, secondTile.correctPosition],
    );
    var thirdTile = puzzle.tiles.firstWhere((t) => t.value == 1);
    assert(thirdTile.currentPosition == thirdTile.correctPosition,
        "Third tile is not in its correctPosition: $thirdTile");
  });

  test("Solve preset puzzle 4x4", () {
    PuzzleSolver solver = PuzzleSolver();
    Puzzle puzzle = randomPuzzle1;
    // Disable solve3x2 if you want to test parts individually
    puzzle = solver.solve(puzzle);
    assert(
        puzzle.tiles
                .where((t) => t.currentPosition != t.correctPosition)
                .length <
            6,
        "Puzzle has ${puzzle.tiles.where((t) => t.currentPosition != t.correctPosition).length} tiles instead of the 3x2 grid expected");

    // puzzle = solver.solve3x2(puzzle);
    assert(puzzle.isComplete(), "Puzzle is not solved:\n${puzzle.toVisualString()}");
  });

  test("Solve random puzzle 3x3", () {
    for(int i = 0;i< 100; i++) {
      PuzzleSolver solver = PuzzleSolver();
      Puzzle puzzle = Puzzle.generate(3);
      puzzle = solver.solve(puzzle);
      print("Puzzle complete:\n${puzzle.toVisualString()}");
      assert(puzzle.isComplete(), "Puzzle is not solved:\n${puzzle
          .toVisualString()}");
    }
  });
  test("Solve random puzzle 4x4", () {
    for(int i = 0;i< 100; i++) {
      PuzzleSolver solver = PuzzleSolver();
      Puzzle puzzle = Puzzle.generate(4);
      puzzle = solver.solve(puzzle);
      assert(puzzle.isComplete(), "Puzzle is not solved:\n${puzzle
          .toVisualString()}");
    }
  });
  test("Solve random puzzle 5x5", () {
    for(int i = 0;i< 100; i++) {
      PuzzleSolver solver = PuzzleSolver();
      Puzzle puzzle = Puzzle.generate(5);
      puzzle = solver.solve(puzzle);
      assert(puzzle.isComplete(), "Puzzle is not solved:\n${puzzle
          .toVisualString()}");
    }
  });

  test("Print puzzle to console", () {
    Puzzle puzzle = Puzzle.generate(3);
    var str = puzzle.toVisualString();
    print(str);

    assert(str.length > 0);
  });
}