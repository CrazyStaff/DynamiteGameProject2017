import '../Entity.dart';
import '../Position.dart';

abstract class Block extends Entity {

   Block(String type, Position position) : super(type, position){
      isWalkable = false;
   }

   @override
   void atDestroy(List<List< List<Entity>>> _gameField) {

   }
}