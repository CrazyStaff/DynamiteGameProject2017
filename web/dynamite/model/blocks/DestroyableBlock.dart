import '../Entity.dart';
import '../Modificator.dart';
import '../Position.dart';
import '../items/Portal.dart';
import 'Block.dart';

class DestroyableBlock extends Block {

  static final ENTITY_TYPE = "DESTROYABLE_BLOCK";

  DestroyableBlock(Position position) : super(ENTITY_TYPE, position) {
    Entity.destroyableBlockCount += 1;
  }

  @override
  Modificator atDestroy(List<List<List<Entity>>> gameField) {
    Modificator mod = Modificator.buildModificator(gameField);
    Entity.destroyableBlockCount -= 1;
    if (Entity.destroyableBlockCount == 0){
      Position spawnPosition = position.clone();
      mod.addAddable(new Portal(spawnPosition), spawnPosition);
    }
    return mod;
  }
}