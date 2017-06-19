import '../Entity.dart';
import '../Position.dart';
import 'Item.dart';

class SpeedBuff extends Item {

  static const ENTITY_TYPE = "SPEEDBUFF";
  static int spawnPercentage = 10;


  SpeedBuff(Position position) : super(ENTITY_TYPE, position) {
    this.isWalkable = true;
    this.team = 3;
    this.strength = 0;
  }

  bool collision(Entity entity) {
    if (this.team != entity.team) {
      print(entity.getType() + " collect Item");
      entity.setWalkingSpeed(entity.getWalkingSpeed() - 100);
      return true;
    }
    return false;
  }

  static int getSpawnRate(){
    return spawnPercentage;
  }

}