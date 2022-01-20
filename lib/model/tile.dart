import 'package:equatable/equatable.dart';
import 'package:slide_puzzle/model/position.dart';

/// {@template tile}
/// Model for a puzzle tile.
/// {@endtemplate}
class Tile extends Equatable {
  /// {@macro tile}
  const Tile({
    required this.value,
    required this.correctPosition,
    required this.currentPosition,
    this.isWhitespace = false,
  });

  /// Value representing the correct position of [Tile] in a list.
  final int value;

  /// The correct 2D [Position] of the [Tile]. All tiles must be in their
  /// correct position to complete the puzzle.
  final Position correctPosition;

  /// The current 2D [Position] of the [Tile].
  final Position currentPosition;

  /// Denotes if the [Tile] is the whitespace tile or not.
  final bool isWhitespace;

  bool get isInCorrectPosition => currentPosition == correctPosition;

  /// Create a copy of this [Tile] with updated current position.
  Tile copyWith({required Position currentPosition}) {
    return Tile(
      value: value,
      correctPosition: correctPosition,
      currentPosition: currentPosition,
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
}
