import 'Entity.dart';
import 'Position.dart';

class Player extends Entity {
  static final ENTITY_TYPE = "PLAYER";

  Player(Position position) : super(ENTITY_TYPE, position) {
      this.team = 1;
      this.strength = 42;
      this.isWalkable = true;

      updateLastMoveTime();
      setWalkingSpeed(500);
  }

  // TODO: Constructor with startPosition and other variables of Entity

  void setNextMove(int offsetX, int offsetY) {
      nextPosition = position.clone(); // immer von aktueller Position ausgehen!
      nextPosition.addOffset(offsetX, offsetY);
  }

  @override
  Position getNextMove(List<List< List<Entity>>> gameField) {
    // TODO: 'gameField' not neccessary?!!
    return nextPosition;
  }

  @override
  void standStillStrategy() {
    // needs to be empty implemented!
    // -> allow player to move directly in the game tact after no input of user
  }
}