import '../Entity.dart';
import '../Position.dart';
import '../Target.dart';

class Monster extends Entity {
  static const int VIEW_FIELD_RANGE = 3;

  static final ENTITY_TYPE = "MONSTER";

  Target _target;
  Position nextPosition;

  Monster(Position position) : super(ENTITY_TYPE, position) {
     _target = new Target();
     this.isWalkable = true;
     updateLastMoveTime();
     setWalkingSpeed(1000);
     this.strength = 43;
     this.team = 2;
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
    /*if(!_target.hasPathToTarget()) {
      // 1) TODO: use random movement
      // 2) TODO: use defined path ( read from file -> monster path )
      // =>  nextPosition = ...
    } else {
      // TODO: Lauf zum Punkt wo du den Helden das letzte mal gesehen hast
      nextPosition = _target.nextStepToTarget();
    }*/
    String random = (new DateTime.now().millisecondsSinceEpoch).toString();
    random = random.substring(random.length-4, random.length-3);
    switch (random) {
      case "0":
        nextPosition = new Position(position.getX+1, position.getY);
        break;
      case "1":
        nextPosition = new Position(position.getX, position.getY+1);
        break;
      case "2":
        nextPosition = new Position(position.getX, position.getY-1);
        break;
      case "3":
        nextPosition = new Position(position.getX-1, position.getY);
        break;
      case "4":
        nextPosition = new Position(position.getX-1, position.getY);
        break;
      case "5":
        nextPosition = new Position(position.getX+1, position.getY);
        break;
      case "6":
        nextPosition = new Position(position.getX, position.getY+1);
        break;
      case "7":
        nextPosition = new Position(position.getX, position.getY-1);
        break;
      case "8":
        nextPosition = new Position(position.getX+1, position.getY);
        break;
      case "9":
        nextPosition = new Position(position.getX, position.getY+1);
        break;
    }
    updateLastMoveTime();
    return nextPosition;
  }
}