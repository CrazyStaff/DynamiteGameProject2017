import '../Position.dart';
import 'Monster.dart';

/*
  Fridolin is the normal type of monster
  This monster doesn´t have any extra behaviour
 */
class Fridolin extends Monster {

  // The entity type identifies the monster as fridolin
  static const ENTITY_TYPE = "FRIDOLIN";

  Fridolin(Position position) : super(ENTITY_TYPE, position);

  @override
  int getViewOrder() {
    return 40;
  }
}