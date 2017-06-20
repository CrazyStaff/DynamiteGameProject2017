import '../Entity.dart';
import '../Position.dart';

class Portal extends Entity {

  static const ENTITY_TYPE = "PORTAL";
  static int spawnPercentage = (100/Entity.destroyableBlockCount).toInt();

  Portal(Position position) : super(ENTITY_TYPE, position) {
    this.isWalkable = true;
    Entity.portalCount += 1;
    // team = friendly to all
  }

  static int getSpawnRate(){
    return spawnPercentage;
  }

}