import '../DynamiteGame.dart';
import '../Entity.dart';
import '../Modificator.dart';
import '../Movement.dart';
import '../Position.dart';
import '../pathfinding/FieldNode.dart';
import 'Block.dart';
import 'Fire.dart';

class Dynamite extends Block {

  static const ENTITY_TYPE = "DYNAMITE";

  Dynamite(Position position) : super(ENTITY_TYPE, position) {
    updateLastActionTime();
    //Dynamite bewegt sich erstmal nicht
    //updateLastMoveTime();
    //setSpeed(DynamiteGame.DYNAMITE_EXPLODE_TIME);
  }

  @override
  Modificator atDestroy(List<List< FieldNode >> gameField) {
    Modificator mod = Modificator.buildModificator(gameField);

    _spawnFireInDirection(gameField, Movement.STAY_STILL, mod);
    _spawnFireInDirection(gameField, Movement.UP, mod);
    _spawnFireInDirection(gameField, Movement.DOWN, mod);
    _spawnFireInDirection(gameField, Movement.LEFT, mod);
    _spawnFireInDirection(gameField, Movement.RIGHT, mod);

    return mod;
  }

  void _spawnFireInDirection(List<List< FieldNode >> gameField, final Position direction, Modificator modificator) {
    Position pos = position.clone();

    for(int i=1; i <= DynamiteGame.DYNAMITE_RADIUS; i++) {
      pos.addOffset(direction);
      if(Fire.isSpawnPossible(gameField, pos)) {
        Position positionFire = pos.clone();

        Fire fire = new Fire(positionFire);
        modificator.addAddable(fire, positionFire);

        _collisionWithEntities(fire, gameField, pos);
      } else {
        return; // Do not spawn fire in this row after a not possible spawn fire block
      }
    }
  }

  /**
   * Do collision on fire spawning field directly after fire is spawned
   */
  void _collisionWithEntities(Fire fire, List<List< FieldNode >> gameField, Position pos) {
    List<Entity> allFieldEntities = gameField[pos.getX][pos.getY].getEntities;
    for(Entity entity in allFieldEntities) {
        if (entity.collision(fire)) {
          entity.setAlive(false);
        }
    }
  }

  @override
  void action(List<List< FieldNode >> gameField, int time) {
    if ((this.lastActionTime + DynamiteGame.DYNAMITE_EXPLODE_TIME) < time){
      setAlive(false);
    }
  }
}