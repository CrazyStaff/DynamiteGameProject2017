import '../DynamiteGame.dart';
import '../Entity.dart';
import '../Position.dart';
import '../pathfinding/FieldNode.dart';
import 'Block.dart';

/*
    This type of block can cause harm to other entities
 */
class Fire extends Block {

  // The entity type identifies the block as fire
  static const ENTITY_TYPE = "FIRE";

  Fire(Position position) : super(ENTITY_TYPE, position) {
    isWalkable = true;
    team = 3;
    strength = 99;

    /*
      this updates the time of the last action so that the action method
      can be called from 'DynamiteGame'
    */
    updateLastActionTime();
  }

  /*
      Proofs if the spawn of fire is possible on this 'gameField'
      f.e. it is not possible to spawn fire on a undestroyable block or a portal
      In our implementation the portal is intended to be a save point
      for the player and monsters against fire
   */
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

  /*
      Sets the fire to not alive if the duration of fire is over
   */
  @override
  void action(List<List< FieldNode >> gameField, int time) {
    if ((this.lastActionTime + DynamiteGame.FIRE_DURATION) < time){
      setAlive(false, "Burned to ash");
    }
  }
}