import '../Entity.dart';
import '../Position.dart';
import 'Block.dart';

class UndestroyableBlock extends Block {

  static final ENTITY_TYPE = "UNDESTROYABLE_BLOCK";

  UndestroyableBlock(Position position) : super(ENTITY_TYPE, position);

  @override
  void atDestroy(List<List< List<Entity>>> gameField) {
    // TODO: implement atDestroy
  }
}