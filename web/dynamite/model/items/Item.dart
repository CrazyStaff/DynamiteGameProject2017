import '../Entity.dart';
import '../Modificator.dart';
import '../Position.dart';


class Item extends Entity {

  static final ENTITY_TYPE = "ITEM";
  int _spawnPercentage;

  Item(Position position) : super(ENTITY_TYPE, position){

  }
}