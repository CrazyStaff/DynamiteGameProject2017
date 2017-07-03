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

/*
    This type of block can be destroyed
 */
class DestroyableBlock extends Block {

  // The entity type identifies the block as destroyable
  static const ENTITY_TYPE = "DESTROYABLE_BLOCK";

  DestroyableBlock(Position position) : super(ENTITY_TYPE, position) {
    // Increase the counter for each block so we can see how many blocks are in the game
    Entity.destroyableBlockCount += 1;
  }

  /*
      If this block gets destroyed there is a spawn possibility to spawn new items
      It is only possible to spawn one portal in each level through destroying a destroyable block
      It only spawns ONE item through destroying this block
   */
  @override
  Modificator atDestroy(List<List< FieldNode >> gameField) {
    Modificator mod = Modificator.buildModificator(gameField);
    Entity.destroyableBlockCount -= 1;
    if ((Entity.destroyableBlockCount == 0)&&(Entity.portalCount == 0)){
      // Makes sure that the portal is spawning after last destroyable block is destroyed
      Position spawnPosition = position.clone();
      mod.addAddable(new Portal(spawnPosition), spawnPosition);
    }else{
      // Makes sure there is a real random function
      Random r = new Random.secure();

      // Drops randomly a speed buff item
      if (r.nextInt(100) < SpeedBuff.getSpawnRate()){
        Position spawnPosition = position.clone();
        mod.addAddable(new SpeedBuff(spawnPosition), spawnPosition);
        return mod;
      }

      // Drops randomly a dynamite rang item
      if (r.nextInt(100) < DynamiteRange.getSpawnRate()){
        Position spawnPosition = position.clone();
        mod.addAddable(new DynamiteRange(spawnPosition), spawnPosition);
        return mod;
      }

      // Drops randomly a portal item
      if ((r.nextInt(100) < Portal.getSpawnRate())&&(Entity.portalCount == 0)){
        Position spawnPosition = position.clone();
        mod.addAddable(new Portal(spawnPosition), spawnPosition);
        return mod;
      }
    }
    return mod;
  }

  @override
  int getViewOrder() {
    return 20;
  }
}