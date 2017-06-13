import '../Entity.dart';
import '../Modificator.dart';
import '../Position.dart';
import '../Target.dart';
import 'dart:math';

class Monster extends Entity {
  static const int VIEW_FIELD_RANGE = 3;

  static final ENTITY_TYPE = "MONSTER";

  Target _target;


  Monster(Position position) : super(ENTITY_TYPE, position) {
    //Entity.monsterCounter += 1;
   // _target = new Target();

    this.isWalkable = true;
    this.strength = 43;
    this.team = 2;

    this.setWalkingSpeed(1000);
    this.updateLastMoveTime();
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
    //return new Position(0,0);
    Random random = new Random();
    for (int versuch = 0; versuch<4; versuch++) {
      switch (random.nextInt(4)) {
        case 0:
          nextPosition = new Position(position.getX + 1, position.getY);
          break;
        case 1:
          nextPosition = new Position(position.getX - 1, position.getY);
          break;
        case 2:
          nextPosition = new Position(position.getX, position.getY + 1);
          break;
        case 3:
          nextPosition = new Position(position.getX, position.getY - 1);
          break;
      }
      if (isMovePossible(gameField[nextPosition.getX][nextPosition.getY])){
        return nextPosition;
      }
    }
    updateLastMoveTime();
    return nextPosition;

    /*if(!_target.hasPathToTarget()) {
      // 1) TODO: use random movement
      // 2) TODO: use defined path ( read from file -> monster path )
      // =>  nextPosition = ...
    } else {
      // TODO: Lauf zum Punkt wo du den Helden das letzte mal gesehen hast
      nextPosition = _target.nextStepToTarget();
    }*/

  }

  @override
  Modificator atDestroy(List<List<List<Entity>>> gameField) {
    //Entity.monsterCounter -= 1;

    return null;
  }


}