import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:zpuzzle/model/position.dart';

/// {@template tile}
/// Model for a puzzle tile.
/// {@endtemplate}
class Tile extends Equatable {
  /// {@macro tile}
  const Tile({
    required this.value,
    required this.correctPosition,
    required this.currentPosition,
    required this.previousPosition,
    this.isWhitespace = false,
  });

  /// Value representing the correct position of [Tile] in a list.
  final int value;

  /// The correct 2D [Position] of the [Tile]. All tiles must be in their
  /// correct position to complete the puzzle.
  final Position correctPosition;

  /// The current 2D [Position] of the [Tile].
  final Position currentPosition;

  /// The previous 2D [Position] of the [Tile].
  final Position previousPosition;

  /// Denotes if the [Tile] is the whitespace tile or not.
  final bool isWhitespace;

  bool get isInCorrectPosition => currentPosition == correctPosition;

  double get previousIndicatorAngle => _indicatorAngle(previousPosition);

  double get currentIndicatorAngle => _indicatorAngle(currentPosition);

  double _indicatorAngle(Position position) {
    final corX = correctPosition.x;
    final corY = correctPosition.y;
    final posX = position.x;
    final posY = position.y;

    if (posX > corX) {
      if (posY > corY) {
        // (1, 1) > (0, 0)
        return -3 * pi / 4;
      } else if (posY == corY) {
        return pi;
      } else {
        return 3 * pi / 4;
      }
    } else if (posX < corX) {
      if (posY > corY) {
        // (1, 1) > (0, 0)
        return -pi / 4;
      } else if (posY == corY) {
        return 0;
      } else {
        return pi / 4;
      }
    } else {
      // posX == corX
      if (posY > corY) {
        // (1, 1) > (0, 0)
        return -pi / 2;
      } else if (posY == corY) {
        return 0;
      } else {
        return pi / 2;
      }
    }
  }

  /// Create a copy of this [Tile] with updated current position.
  Tile copyWith({Position? newCurrentPosition, Position? newPreviousPosition}) {
    return Tile(
      value: value,
      correctPosition: correctPosition,
      currentPosition: newCurrentPosition ?? currentPosition,
      previousPosition: newPreviousPosition ?? previousPosition,
      isWhitespace: isWhitespace,
    );
  }

  @override
  List<Object> get props => [
        value,
        correctPosition,
        currentPosition,
        isWhitespace,
      ];

  Position? _move(
      Position newPosition, List<Position> lockedPositions, int dimension) {
    if (newPosition.isValid(lockedPositions, dimension)) {
      return newPosition;
    } else {
      return null;
    }
  }

  Position? left(List<Position> lockedPositions, int dimension) {
    return _move(Position(x: currentPosition.x - 1, y: currentPosition.y),
        lockedPositions, dimension);
  }

  Position? top(List<Position> lockedPositions, int dimension) {
    return _move(Position(x: currentPosition.x, y: currentPosition.y - 1),
        lockedPositions, dimension);
  }

  Position? right(List<Position> lockedPositions, int dimension) {
    return _move(Position(x: currentPosition.x + 1, y: currentPosition.y),
        lockedPositions, dimension);
  }

  Position? bottom(List<Position> lockedPositions, int dimension) {
    return _move(Position(x: currentPosition.x, y: currentPosition.y + 1),
        lockedPositions, dimension);
  }

  bool hasMoved() {
    return currentPosition != previousPosition;
  }
}
