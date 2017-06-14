import '../Entity.dart';
import '../Position.dart';

class Portal extends Entity {

  static final ENTITY_TYPE = "PORTAL";

  Portal(Position position) : super(ENTITY_TYPE, position) {
    this.isWalkable = true;

    // team = friendly to all
  }

}