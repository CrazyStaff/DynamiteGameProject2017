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

class DestroyableBlock extends Block {  // This Blocks can be destroyed

  static const ENTITY_TYPE = "DESTROYABLE_BLOCK"; // The Type identefies the Block as Destroyable

  DestroyableBlock(Position position) : super(ENTITY_TYPE, position) {
    Entity.destroyableBlockCount += 1;    // when this Type gets construkted, the Counter gets inceased, so we can see how many blocks are ingame
  }

  @override
  Modificator atDestroy(List<List< FieldNode >> gameField) {    // when this block gets destroyed he can spawn items und decrease the Block counter
    Modificator mod = Modificator.buildModificator(gameField);
    Entity.destroyableBlockCount -= 1;
    if ((Entity.destroyableBlockCount == 0)&&(Entity.portalCount == 0)){
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
      if ((r.nextInt(100) < Portal.getSpawnRate())&&(Entity.portalCount == 0)){
        Position spawnPosition = position.clone();
        mod.addAddable(new Portal(spawnPosition), spawnPosition);
        return mod;
      }
    }
    return mod;
  }
}