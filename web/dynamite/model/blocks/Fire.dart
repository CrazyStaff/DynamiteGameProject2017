import '../DynamiteGame.dart';
import '../Entity.dart';
import '../Position.dart';
import 'Block.dart';

class Fire extends Block {

  static final ENTITY_TYPE = "FIRE";

  Fire(Position position) : super(ENTITY_TYPE,  position.clone()) {
    updateLastMoveTime();
    setSpeed(DynamiteGame.FIRE_DURATION);
  }

  static bool isSpawnPossible(List<List< List<Entity>>> gameField, Position spawnPoint) {
    int fieldWidth = gameField[0].length;
    int fieldHeight = gameField.length;
    bool possible = false;

    if(spawnPoint.getX >= 0 && spawnPoint.getX < fieldWidth && spawnPoint.getY >= 0 && spawnPoint.getY < fieldHeight) {
      possible = true;
      for (Entity e in gameField[spawnPoint.getX][spawnPoint.getY]){
        if (e.getType() == "UNDESTROYABLE_BLOCK"){
          possible = false;
        }
    }
    return possible;
    }
  }

  @override
  void action(List<List< List<Entity>>> gameField, int time) {
    if ((this.lastMoveTime + this.speed) < time){
      setAlive(false);
    }
  }

}