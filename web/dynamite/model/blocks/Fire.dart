import '../DynamiteGame.dart';
import '../Entity.dart';
import '../Position.dart';
import '../pathfinding/FieldNode.dart';
import 'Block.dart';

class Fire extends Block {

  static const ENTITY_TYPE = "FIRE";

  Fire(Position position) : super(ENTITY_TYPE, position) {
    isWalkable = true;
    team = 3;
    strength = 99;
    updateLastActionTime();
    // Feuer bewegt sich erstmal nicht!!!
    // updateLastMoveTime();
    // setWalkingSpeed(DynamiteGame.FIRE_DURATION);
  }

  static bool isSpawnPossible(List<List< FieldNode >> gameField, Position spawnPoint) {
    int fieldWidth = gameField.length;
    int fieldHeight = gameField[0].length;
    bool isSpawnPossible = false;

    if(spawnPoint.getX >= 0 && spawnPoint.getX < fieldWidth && spawnPoint.getY >= 0 && spawnPoint.getY < fieldHeight) {
      isSpawnPossible = true;
      for(Entity entity  in gameField[spawnPoint.getX][spawnPoint.getY].getEntities) {
        switch(entity.getType()) {
          case "UNDESTROYABLE_BLOCK":
          case "PORTAL":
            return false;
        }
      }
    }
    return isSpawnPossible;
  }

  @override
  void action(List<List< FieldNode >> gameField, int time) {
    if ((this.lastActionTime + DynamiteGame.FIRE_DURATION) < time){
      setAlive(false, "Burned to ash");
    }
  }
}