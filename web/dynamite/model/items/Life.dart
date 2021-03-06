import '../Entity.dart';
import '../Position.dart';
import '../Team.dart';
import 'Item.dart';
import '../DynamiteGame.dart';

/*
    This item puts extra life to the player
    Monsters are also able to take this item but there is no effect for them
    Players are able to increase their life with this item
 */
class Life extends Item {

  // The entity type identifies the item as life
  static const ENTITY_TYPE = "LIFE";

  // The spawn percentage of this item
  static int spawnPercentage = 1;

  Life(Position position) : super(ENTITY_TYPE, position) {
    this.isWalkable = true;
    this.setAbsolutelyNewTeam(Team.ITEMS);

    // this item could be taken by any other entity
    this.strength = 0;
  }

  static int getSpawnRate(){
    return spawnPercentage;
  }

  static setSpawnRate(int i) {
    spawnPercentage = i;
  }
}