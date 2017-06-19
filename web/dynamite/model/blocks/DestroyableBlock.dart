import '../Entity.dart';
import '../Modificator.dart';
import '../Position.dart';
import '../items/Portal.dart';
import '../pathfinding/FieldNode.dart';
import 'Block.dart';
import '../items/Item.dart';
import '../items/SpeedBuff.dart';
import '../items/DynamiteRange.dart';
import 'dart:math';

class DestroyableBlock extends Block {

  static const ENTITY_TYPE = "DESTROYABLE_BLOCK";

  DestroyableBlock(Position position) : super(ENTITY_TYPE, position) {
    Entity.destroyableBlockCount += 1;
  }

  @override
  Modificator atDestroy(List<List< FieldNode >> gameField) {
    Modificator mod = Modificator.buildModificator(gameField);
    Entity.destroyableBlockCount -= 1;
    if (Entity.destroyableBlockCount == 0){
      Position spawnPosition = position.clone();
      mod.addAddable(new Portal(spawnPosition), spawnPosition);
    }else{//Random Item
      Random r = new Random();
      if (r.nextInt(100) < SpeedBuff.getSpawnRate()){
        Position spawnPosition = position.clone();
        mod.addAddable(new SpeedBuff(spawnPosition), spawnPosition);
        return mod;
      }
      if (r.nextInt(100) < DynamiteRange.getSpawnRate()){
        Position spawnPosition = position.clone();
        mod.addAddable(new DynamiteRange(spawnPosition), spawnPosition);
        return mod;
      }
    }
    return mod;
  }
}