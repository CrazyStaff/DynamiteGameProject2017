import '../Position.dart';
import 'Block.dart';

class Dynamite extends Block {

  static final ENTITY_TYPE = "DYNAMITE";

  int _destroyableRadius;

  Dynamite(Position position) : super(ENTITY_TYPE, position);

  @override
  void atDestroy() {
    // TODO: implement atDestroy
  }
}