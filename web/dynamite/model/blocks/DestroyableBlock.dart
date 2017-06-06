import '../Entity.dart';
import '../Position.dart';
import 'Block.dart';

class DestroyableBlock extends Block {

  static final ENTITY_TYPE = "DESTROYABLE_BLOCK";

  DestroyableBlock(Position position) : super(ENTITY_TYPE, position);

  @override
  void atDestroy(List<List< List<Entity>>> gameField) {
    // TODO: implement atDestroy
  }
}