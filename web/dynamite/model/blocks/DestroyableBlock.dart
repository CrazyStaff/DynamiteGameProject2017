import '../Entity.dart';
import '../Modificator.dart';
import '../Position.dart';
import '../items/Portal.dart';
import 'Block.dart';

class DestroyableBlock extends Block {

  static final ENTITY_TYPE = "DESTROYABLE_BLOCK";

  DestroyableBlock(Position position) : super(ENTITY_TYPE, position){
    Entity.KistenCount++;
  }

  @override
  Modificator atDestroy(List<List<List<Entity>>> gameField) {
    Modificator mod = Modificator.buildModificator(gameField);
    if ((--Entity.KistenCount) == 0){
     mod.addAddable(new Portal(position.clone()), position.clone());
    }
    return mod;
  }
}