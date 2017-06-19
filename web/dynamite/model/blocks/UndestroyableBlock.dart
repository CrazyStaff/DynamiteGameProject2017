import '../Entity.dart';
import '../Modificator.dart';
import '../Position.dart';
import '../pathfinding/FieldNode.dart';
import 'Block.dart';

class UndestroyableBlock extends Block {

  static const ENTITY_TYPE = "UNDESTROYABLE_BLOCK";

  UndestroyableBlock(Position position) : super(ENTITY_TYPE, position);

  @override
  Modificator atDestroy(List<List< FieldNode >> gameField) {
    return null;
  }
}