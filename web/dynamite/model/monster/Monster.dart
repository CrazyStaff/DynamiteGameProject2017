import '../Entity.dart';
import '../Modificator.dart';
import '../Position.dart';
import '../Target.dart';

class Monster extends Entity {
  static const int VIEW_FIELD_RANGE = 3;

  static final ENTITY_TYPE = "MONSTER";

  Target _target;
  Position nextPosition;

  Monster(Position position) : super(ENTITY_TYPE, position) {
     _target = new Target();
  }

  void setNextMove(Position nextPosition) {
     this.nextPosition = nextPosition;
  }

  @override
  void moveTo(List<Entity> entityField) {
      super.moveTo(entityField);
      // TODO: Testen ob sich im View_Field_Range der Player befindet (mithilfe von direction => wo man hinguckt)
      // TODO => und die neue Position dann in Target '_target' updaten
      // if player found use => List<Position> path = PathFinder.findPath(gameField, this.position, TARGET_POSITION_PLAYER);
  }

  @override
  Position getNextMove(List<List< List<Entity>>> gameField) {
    if(!_target.hasPathToTarget()) {
      // 1) TODO: use random movement
      // 2) TODO: use defined path ( read from file -> monster path )
      // =>  nextPosition = ...
    } else {
      // TODO: Lauf zum Punkt wo du den Helden das letzte mal gesehen hast
      nextPosition = _target.nextStepToTarget();
    }
    return nextPosition;
  }
}