import '../Entity.dart';
import '../Position.dart';
import '../pathfinding/FieldNode.dart';

/*
    The portal is the destination for the player in each level
    It is closed for the player until all monsters in the level are killed
    It is walkable by monsters and the player all the time
 */
class Portal extends Entity {

  // The entity type identifies the entity as portal
  static const ENTITY_TYPE = "PORTAL";

  /*
      The spawn percentage of this item
      The portal should not spawn directly after destroying the first destroyable block
   */
  static int spawnPercentage = (10/Entity.destroyableBlockCount).toInt();

  Portal(Position position) : super(ENTITY_TYPE, position) {
    this.isWalkable = true;

    /*
        Increase the counter of all portals
        It is also possible to have multiple portals in the same level
     */
    Entity.portalCount += 1;
  }

  static int getSpawnRate(){
    return spawnPercentage;
  }

  static setSpawnRate(int i) {
    spawnPercentage = i;
  }

  /*
      Controls the open and closed view of the portal
      The portal is closed if there are still enemies
   */
  @override
  void action(List<List<FieldNode>> _gameField, int time) {
    // The portal should be closed if there is still an enemy
    if(Entity.monsterCounter >= 1) {
      this.extensionType = "PORTAL_CLOSED";
    } else {
      // Now the portal should be open
      this.extensionType = "";
    }
  }
}