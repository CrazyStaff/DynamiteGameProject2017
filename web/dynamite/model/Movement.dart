import 'Entity.dart';
import 'Position.dart';
import 'pathfinding/FieldNode.dart';

class Movement {

  // Position: Horizontal and vertical
  static final Position STAY_STILL = new Position(0, 0);
  static final Position RIGHT = new Position(1, 0);
  static final Position LEFT = new Position(-1, 0);
  static final Position DOWN = new Position(0, 1);
  static final Position UP = new Position(0, -1);

  // Position: At an angle
  static final Position ANGLE_TOP_LEFT = new Position(-1, -1);
  static final Position ANGLE_TOP_RIGHT = new Position(1, -1);
  static final Position ANGLE_BOT_LEFT = new Position(-1, 1);
  static final Position ANGLE_BOT_RIGHT = new Position(1, 1);

  static final List<Position> CORNERS_EXCLUDED = [RIGHT, LEFT, DOWN, UP];
  static final List<Position> CORNERS_INCLUDED = [
    RIGHT, LEFT, DOWN, UP,
    ANGLE_TOP_LEFT, ANGLE_TOP_RIGHT,
    ANGLE_BOT_LEFT, ANGLE_BOT_RIGHT
  ];

  static bool isMovePossible(Position destination, List<List< FieldNode >> gameField) {
    if(destination == null) return false;

    int fieldWidth = gameField.length;
    int fieldHeight = gameField[0].length;

    if(destination.getX >= 0 && destination.getX < fieldWidth && destination.getY >= 0 && destination.getY < fieldHeight) {
      return true;
    }
    return false;
  }
}