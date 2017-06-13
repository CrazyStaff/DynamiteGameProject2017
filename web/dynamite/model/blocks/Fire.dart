import '../DynamiteGame.dart';
import '../Entity.dart';
import '../Modificator.dart';
import '../Position.dart';
import 'Block.dart';

class Fire extends Block {

  static final ENTITY_TYPE = "FIRE";

  Fire(Position position) : super(ENTITY_TYPE, position) {
    isWalkable = true;
    team = 3;
    strength = 99;
    updateLastActionTime();
    // Feuer bewegt sich erstmal nicht!!!
    // updateLastMoveTime();
    // setWalkingSpeed(DynamiteGame.FIRE_DURATION);
  }

  static bool isSpawnPossible(List<List<List<Entity>>> gameField, Position spawnPoint) {
    int fieldWidth = gameField.length;
    int fieldHeight = gameField[0].length;
    bool isSpawnPossible = false;

    if(spawnPoint.getX >= 0 && spawnPoint.getX < fieldWidth && spawnPoint.getY >= 0 && spawnPoint.getY < fieldHeight) {
      isSpawnPossible = true;
      for(Entity entity  in gameField[spawnPoint.getX][spawnPoint.getY]) {
        switch(entity.getType()) {
          case "UNDESTROYABLE_BLOCK":
            return false;
            break;
          case "PORTAL":
            return false;
        }
      }
    }
    return isSpawnPossible;
  }

  @override
  void action(List<List< List<Entity>>> gameField, int time) {
    if ((this.lastActionTime + DynamiteGame.FIRE_DURATION) < time){
      setAlive(false);
    }
  }
}