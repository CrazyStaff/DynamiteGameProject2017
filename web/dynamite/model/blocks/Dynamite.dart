import '../DynamiteGame.dart';
import '../Entity.dart';
import '../Position.dart';
import 'Block.dart';
import 'Fire.dart';

class Dynamite extends Block {

  static final ENTITY_TYPE = "DYNAMITE";

  Dynamite(Position position) : super(ENTITY_TYPE, position) {
      updateLastMoveTime();
      setSpeed(DynamiteGame.DYNAMITE_EXPLODE_TIME);
  }
  @override
  void atDestroy(List<List< List<Entity>>> gameField) {
    Position pos = position.clone();
    for(int x=1; x <= DynamiteGame.DYNAMITE_RADIUS; x++ ) {
      pos.addOffset(1, 0);
      if (Fire.isSpawnPossible(gameField, pos)){
        gameField[pos.getX][pos.getY].add(new Fire(pos));
      }
    }
    pos = position.clone();
    for(int y=1; y <= DynamiteGame.DYNAMITE_RADIUS; y++ ) {
      pos.addOffset(0, 1);
      if (Fire.isSpawnPossible(gameField, pos)){
        gameField[pos.getX][pos.getY].add(new Fire(pos));
      }
    }
  }

  @override
  void action(List<List< List<Entity>>> gameField, int time) {
    if ((this.lastMoveTime + this.speed) < time){
    setAlive(false);
    }
  }
}