import 'Entity.dart';
import 'Position.dart';

class Player extends Entity {
  static final ENTITY_TYPE = "PLAYER";

  Player(Position position) : super(ENTITY_TYPE, position) {
      this.nextPosition = position.clone();
      updateLastMoveTime();
      setWalkingSpeed(100);
      team = 1;
      strength = 42;
  }

  // TODO: Constructor with startPosition and other variables of Entity

  void setNextMove(int offsetX, int offsetY) {
      nextPosition = position.clone(); // immer von aktueller Position ausgehen!
      nextPosition.addOffset(offsetX, offsetY);
      //print("$nextPostion vs $position");
  }

  @override
  Position getNextMove(List<List< List<Entity>>> gameField) { // TODO: 'gameField' not neccessary?!!
      return nextPosition;
  }
}