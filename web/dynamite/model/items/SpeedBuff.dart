import '../Entity.dart';
import '../Position.dart';
import 'Item.dart';

class SpeedBuff extends Item {

  static const ENTITY_TYPE = "SPEEDBUFF";
  static int spawnPercentage;
  static int speedOffset;


  SpeedBuff(Position position) : super(ENTITY_TYPE, position) {
    this.isWalkable = true;
    this.team = 3;
    this.strength = 0;
  }

  bool collision(Entity entity) {
    if (this.team != entity.team) {
      print(entity.getType() + " collect Item");
      entity.setWalkingSpeed(entity.getWalkingSpeed() - speedOffset);
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

  static setSpeedOffset(int i) {
  speedOffset = i;
  }

}