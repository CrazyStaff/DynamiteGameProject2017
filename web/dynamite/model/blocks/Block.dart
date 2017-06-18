import '../Entity.dart';
import '../Modificator.dart';
import '../Position.dart';
import '../pathfinding/FieldNode.dart';

abstract class Block extends Entity {

   Block(String type, Position position) : super(type, position);

   // needs to be overriden by each superclass of 'Block'
   Modificator atDestroy(List<List< FieldNode >> gameField);
}