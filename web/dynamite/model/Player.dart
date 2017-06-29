import 'Entity.dart';
import 'Position.dart';
import 'pathfinding/FieldNode.dart';

class Player extends Entity {
  static final ENTITY_TYPE = "PLAYER";

  Player(Position position) : super(ENTITY_TYPE, position) {
      this.team = 1;
      this.strength = 42;
      this.isWalkable = true;

      updateLastMoveTime();
      setWalkingSpeed(300);
  }

  // TODO: Constructor with startPosition and other variables of Entity

  void setNextMove(Position moveOffset) {
      nextPosition = position.clone(); // immer von aktueller Position ausgehen!
      nextPosition.addOffset(moveOffset);
  }

  @override
  Position getNextMove(List<List< FieldNode >> gameField) {
    // TODO: 'gameField' not neccessary?!!
    return nextPosition;
  }

  @override
  void standStillStrategy() {
    // needs to be empty implemented!
    // -> allow player to move directly in the game tact after no input of user
  }
}