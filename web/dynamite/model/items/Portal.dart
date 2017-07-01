import '../Entity.dart';
import '../Position.dart';
import '../pathfinding/FieldNode.dart';

class Portal extends Entity {

  static const ENTITY_TYPE = "PORTAL";
  static int spawnPercentage = (10/Entity.destroyableBlockCount).toInt();

  Portal(Position position) : super(ENTITY_TYPE, position) {
    this.isWalkable = true;
    Entity.portalCount += 1;
  }

  static int getSpawnRate(){
    return spawnPercentage;
  }

  static setSpawnRate(int i) {
    spawnPercentage = i;
  }

  @override
  void action(List<List<FieldNode>> _gameField, int time) {
    /* Show only a closed portal */
    if(Entity.monsterCounter >= 1) {
      this.extensionType = "PORTAL_CLOSED";
    } else {
      // now portal is open
      this.extensionType = "";
    }
  }
}