// ignore_for_file: avoid_print

import 'package:slide_puzzle/model/position.dart';
import 'package:slide_puzzle/model/puzzle.dart';
import 'package:slide_puzzle/model/puzzle_solver.dart';
import 'package:slide_puzzle/model/tile.dart';
import 'package:test/test.dart';

void main() {
  var randomPuzzle1 = Puzzle(tiles: const [
    Tile(
        value: 1,
        correctPosition: Position(x: 1, y: 1),
        currentPosition: Position(x: 2, y: 1),
        previousPosition: Position(x: 2, y: 1),
        isWhitespace: false),
    Tile(
        value: 2,
        correctPosition: Position(x: 2, y: 1),
        currentPosition: Position(x: 3, y: 1),
        previousPosition: Position(x: 3, y: 1),
        isWhitespace: false),
    Tile(
        value: 3,
        correctPosition: Position(x: 3, y: 1),
        currentPosition: Position(x: 1, y: 1),
        previousPosition: Position(x: 1, y: 1),
        isWhitespace: false),
    Tile(
        value: 4,
        correctPosition: Position(x: 4, y: 1),
        currentPosition: Position(x: 1, y: 3),
        previousPosition: Position(x: 1, y: 3),
        isWhitespace: false),
    Tile(
        value: 5,
        correctPosition: Position(x: 1, y: 2),
        currentPosition: Position(x: 2, y: 2),
        previousPosition: Position(x: 2, y: 2),
        isWhitespace: false),
    Tile(
        value: 6,
        correctPosition: Position(x: 2, y: 2),
        currentPosition: Position(x: 4, y: 1),
        previousPosition: Position(x: 4, y: 1),
        isWhitespace: false),
    Tile(
        value: 7,
        correctPosition: Position(x: 3, y: 2),
        currentPosition: Position(x: 4, y: 3),
        previousPosition: Position(x: 4, y: 3),
        isWhitespace: false),
    Tile(
        value: 8,
        correctPosition: Position(x: 4, y: 2),
        currentPosition: Position(x: 1, y: 4),
        previousPosition: Position(x: 1, y: 4),
        isWhitespace: false),
    Tile(
        value: 9,
        correctPosition: Position(x: 1, y: 3),
        currentPosition: Position(x: 3, y: 3),
        previousPosition: Position(x: 3, y: 3),
        isWhitespace: false),
    Tile(
        value: 10,
        correctPosition: Position(x: 2, y: 3),
        currentPosition: Position(x: 1, y: 2),
        previousPosition: Position(x: 1, y: 2),
        isWhitespace: false),
    Tile(
        value: 11,
        correctPosition: Position(x: 3, y: 3),
        currentPosition: Position(x: 4, y: 4),
        previousPosition: Position(x: 4, y: 4),
        isWhitespace: false),
    Tile(
        value: 12,
        correctPosition: Position(x: 4, y: 3),
        currentPosition: Position(x: 3, y: 2),
        previousPosition: Position(x: 3, y: 2),
        isWhitespace: false),
    Tile(
        value: 13,
        correctPosition: Position(x: 1, y: 4),
        currentPosition: Position(x: 4, y: 2),
        previousPosition: Position(x: 4, y: 2),
        isWhitespace: false),
    Tile(
        value: 14,
        correctPosition: Position(x: 2, y: 4),
        currentPosition: Position(x: 3, y: 4),
        previousPosition: Position(x: 3, y: 4),
        isWhitespace: false),
    Tile(
        value: 15,
        correctPosition: Position(x: 3, y: 4),
        currentPosition: Position(x: 2, y: 4),
        previousPosition: Position(x: 2, y: 4),
        isWhitespace: false),
    Tile(
        value: 16,
        correctPosition: Position(x: 4, y: 4),
        currentPosition: Position(x: 2, y: 3),
        previousPosition: Position(x: 2, y: 3),
        isWhitespace: true),
  ]);

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
    assert(puzzle.isComplete(),
        "Puzzle is not solved:\n${puzzle.toVisualString()}");
  });

  test("Solve already solved puzzle 3x3", () {
    // for(int i = 0;i< 100; i++) {
    PuzzleSolver solver = PuzzleSolver();
    Puzzle puzzle = Puzzle.generate(3, shuffle: false);
    puzzle = solver.solve(puzzle);
    print("Puzzle complete in ${puzzle.history.length} moves");
    assert(puzzle.isComplete(),
        "Puzzle is not solved:\n${puzzle.toVisualString()}");
    // }
  });

  test("Solve random puzzle 3x3", () {
    for (int i = 0; i < 3; i++) {
      PuzzleSolver solver = PuzzleSolver();
      Puzzle puzzle = Puzzle.generate(3);
      puzzle = solver.solve(puzzle);
      print("Puzzle complete in ${puzzle.history.length} moves");
      assert(puzzle.isComplete(),
          "Puzzle $i is not solved:\n${puzzle.toVisualString()}");
    }
  });
  test("Solve random puzzle 4x4", () {
    for (int i = 0; i < 100; i++) {
      PuzzleSolver solver = PuzzleSolver();
      Puzzle puzzle = Puzzle.generate(4);
      puzzle = solver.solve(puzzle);
      assert(puzzle.isComplete(),
          "Puzzle is not solved:\n${puzzle.toVisualString()}");
    }
  });
  test("Solve random puzzle 5x5", () {
    for (int i = 0; i < 100; i++) {
      PuzzleSolver solver = PuzzleSolver();
      Puzzle puzzle = Puzzle.generate(5);
      puzzle = solver.solve(puzzle);
      assert(puzzle.isComplete(),
          "Puzzle is not solved:\n${puzzle.toVisualString()}");
    }
  });

  test("Print puzzle to console", () {
    Puzzle puzzle = Puzzle.generate(3);
    var str = puzzle.toVisualString();
    print(str);

    assert(str.isNotEmpty);
  });
}
