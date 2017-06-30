import '../Entity.dart';
import '../Modificator.dart';
import '../Position.dart';
import '../pathfinding/FieldNode.dart';

abstract class Block extends Entity { // Interface for all Type of Blocks

   Block(String type, Position position) : super(type, position); // no changing on the Construktor

   // needs to be overriden by each superclass of 'Block'
   Modificator atDestroy(List<List< FieldNode >> gameField);  // Bloks can have an action @ destroy
}