import '../Entity.dart';
import '../Position.dart';
import 'Item.dart';
import '../DynamiteGame.dart';

class DynamiteRange extends Item {

  static const ENTITY_TYPE = "DYNAMITERANGE";
  static int spawnPercentage = 1;


  DynamiteRange(Position position) : super(ENTITY_TYPE, position) {
    this.isWalkable = true;
    this.team = 3;
    this.strength = 0;

  }

  bool collision(Entity entity) {
    if (this.team != entity.team) {
      print(entity.getType() + " collect Item");
      if (entity.getType() == "PLAYER") {
        DynamiteGame.DYNAMITE_RADIUS++;
      }
      return true;
    }
    return false;
  }

  static int getSpawnRate(){
    return spawnPercentage;
  }

}