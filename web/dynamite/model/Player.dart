import 'Entity.dart';
import 'Position.dart';

class Player extends Entity {
  Position nextPostion;
  static final ENTITY_TYPE = "PLAYER";

  Player(Position position) : super(ENTITY_TYPE, position) {
      this.nextPostion = position.clone();
      updateLastMoveTime();
      setWalkingSpeed(100);
  }

  // TODO: Constructor with startPosition and other variables of Entity

  void setNextMove(int offsetX, int offsetY) {
      nextPostion = position.clone(); // immer von aktueller Position ausgehen!
      nextPostion.addOffset(offsetX, offsetY);
      //print("$nextPostion vs $position");
  }

  @override
  Position getNextMove(List<List< List<Entity>>> gameField) { // TODO: 'gameField' not neccessary?!!
      return nextPostion;
  }
}