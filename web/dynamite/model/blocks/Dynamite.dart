import '../DynamiteGame.dart';
import '../Entity.dart';
import '../Modificator.dart';
import '../Movement.dart';
import '../Position.dart';
import '../Team.dart';
import '../pathfinding/FieldNode.dart';
import 'Block.dart';
import 'Fire.dart';

/*
    This type of block can explode and causes fire around the destroyed dynamite
 */
class Dynamite extends Block {

  // The entity type identifies the block as dynamite
  static const ENTITY_TYPE = "DYNAMITE";

  /*
      The explosion radius creates fire on the field itself and based on this range in explosionRadius
      to the vertical and horizontal fields next to the position of dynamite
   */
  int _explosionRadius;

  /*
      All Teams which are not harmed by the fire and dynamite
   */
   List<Team> teamsNotToHarm;

  Dynamite(Position position, int explosionRadius) : super(ENTITY_TYPE, position) {
    this._explosionRadius = explosionRadius;

    // Increase the counter of existing Dynamites
    Entity.dynamiteCount += 1;
    /*
      this updates the time of the last action so that the action method
      can be called from 'DynamiteGame'
    */
    updateLastActionTime();
  }

  /*
      Set all teams which shouldn´t get harmed by the fire of this dynamite
   */
  void doNotHarmThisTeamsByFire(List<Team> teamsNotToHarm) {
      this.teamsNotToHarm = teamsNotToHarm;
  }

  /*
      Spawns fire based on the 'explosionRadius'
   */
  @override
  Modificator atDestroy(List<List< FieldNode >> gameField) {
    Modificator mod = Modificator.buildModificator(gameField);

    Entity.dynamiteCount -= 1;

    _spawnFireInDirection(gameField, Movement.STAY_STILL, mod);
    _spawnFireInDirection(gameField, Movement.UP, mod);
    _spawnFireInDirection(gameField, Movement.DOWN, mod);
    _spawnFireInDirection(gameField, Movement.LEFT, mod);
    _spawnFireInDirection(gameField, Movement.RIGHT, mod);

    return mod;
  }

  /*
      Spawns fire in a specialized direction
      The fire is created based on the range of 'explosionRadius' in this direction
   */
  void _spawnFireInDirection(List<List< FieldNode >> gameField, final Position direction, Modificator modificator) {
    Position pos = position.clone();

    for(int i=1; i <= _explosionRadius; i++) {
      pos.addOffset(direction);
      if(Fire.isSpawnPossible(gameField, pos)) {
        Position positionFire = pos.clone();

        Fire fire = new Fire(positionFire);
        if(teamsNotToHarm != null) {
          for(Team notToHarm in teamsNotToHarm) {
            fire.addToTeam(notToHarm);
          }
        }
        modificator.addAddable(fire, positionFire);

        _collisionWithEntities(fire, gameField, pos);
      } else {
        return; // Do not spawn fire in this row after a not possible spawn fire block
      }
    }
  }

  /*
   * Proof collisions on fire spawning field directly after fire is spawned
   */
  void _collisionWithEntities(Fire fire, List<List< FieldNode >> gameField, Position pos) {
    List<Entity> allFieldEntities = gameField[pos.getX][pos.getY].getEntities;
    for(Entity entity in allFieldEntities) {
        if (entity.collision(fire)) {
          entity.setAlive(false, "Dynamite killes you");
        }
    }
  }

  /*
      Sets the dynamite to not alive if the dynamite is exploded
   */
  @override
  Modificator action(List<List< FieldNode >> gameField, int time) {
    if ((this.lastActionTime + DynamiteGame.DYNAMITE_EXPLODE_TIME) < time){
      setAlive(false, "Dynamite killes you");
    }
    return null;
  }
}