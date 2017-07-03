import '../Entity.dart';
import '../Modificator.dart';
import '../Position.dart';
import '../pathfinding/FieldNode.dart';
import 'Block.dart';

/*
    This type of block is undestroyable
    Fire doesn´t cause any harm against this block
 */
class UndestroyableBlock extends Block {

  // The entity type identifies the block as undestroyable
  static const ENTITY_TYPE = "UNDESTROYABLE_BLOCK";

  UndestroyableBlock(Position position) : super(ENTITY_TYPE, position);

  /*
      There is nothing to destroy because this type of block is undestroyable
   */
  @override
  Modificator atDestroy(List<List< FieldNode >> gameField) {
    return null;
  }

  @override
  int getViewOrder() {
    return 10;
  }
}