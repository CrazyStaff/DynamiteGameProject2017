import '../Entity.dart';
import '../Modificator.dart';
import '../Position.dart';
import '../pathfinding/FieldNode.dart';

/*
   Abstract class for all type of blocks
 */
abstract class Block extends Entity {

   Block(String type, Position position) : super(type, position);

   // Needs to be overriden by each superclass of 'Block'
   Modificator atDestroy(List<List< FieldNode >> gameField);

   // Blocks could override an action
}