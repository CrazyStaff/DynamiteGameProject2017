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

  static int getSpawnRate(){
    return spawnPercentage;
  }
}