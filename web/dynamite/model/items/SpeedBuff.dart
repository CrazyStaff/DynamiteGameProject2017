import '../Entity.dart';
import '../Position.dart';
import 'Item.dart';

/*
    The speed buff gives the player extra movement speed
    Monsters are also able to take this item but there is no effect for them
    Players are able to increase their movement speed with each speed buff item
 */
class SpeedBuff extends Item {

  // The entity type identifies the item as speed buff
  static const ENTITY_TYPE = "SPEEDBUFF";

  // The spawn percentage of this item
  static int spawnPercentage;

  // This is the offset for the players movement
  static int speedOffset;

  SpeedBuff(Position position) : super(ENTITY_TYPE, position) {
    this.isWalkable = true;
    this.team = 3;

    // This item could be taken by any other entity
    this.strength = 0;
  }

  /*
      Set a higher speed to the entity which is colliding with this item
   */
  bool collision(Entity entity) {
    if (this.team != entity.team) {
      entity.setWalkingSpeed(entity.getWalkingSpeed() - 100);
      return true;
    }
    return false;
  }

  static int getSpawnRate(){
    return spawnPercentage;
  }

  static setSpawnRate(int i) {
    spawnPercentage = i;
  }

  /*
      Set the offset of the movement speed for the player
   */
  static setSpeedOffset(int i) {
    speedOffset = i;
  }
}