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
    Entity.monsterCounter += 1;

    this._target = new Target();
    this.isWalkable = true;
    this.strength = 50;
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

      // TODO: Testen ob sich im , der Player befindet (mithilfe von direction => wo man hinguckt)
      // TODO => und die neue Position dann in Target '_target' updaten
      // if player found use => List<Position> path = PathFinder.findPath(gameField, this.position, TARGET_POSITION_PLAYER);
  }

  @override
  Modificator atDestroy(List<List<List<Entity>>> gameField) {
        Entity.monsterCounter -= 1;
        return null;
  }

  @override
  Position getNextMove(List<List< List<Entity>>> gameField) {
    if(!_target.hasPathToTarget()) {
      return _moveRandom(gameField);
      // 1) TODO - other strategy -> use defined path ( read from file -> monster path ) instead of random movement
    } else {

      // TODO: Lauf zum Punkt wo du den Helden das letzte mal gesehen hast
      //nextPosition = _target.nextStepToTarget();
    }
    return nextPosition;
  }

  Position _moveRandom(List<List< List<Entity>>> gameField) {
    //if(position == null) return null;

    /*Position newPosition = _proofIfPossibleToKillEnemy(gameField); // // doesnt work yet :/
    if(newPosition != null)
      return newPosition; */

    Random random = new Random();
    for (int versuch = 0; versuch < 4; versuch++) {
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
      if( _proofIfNextPositionIsValid(nextPosition, gameField)) {
        if (isMovePossible(gameField[nextPosition.getX][nextPosition.getY])) {
          return nextPosition;
        }
      }
    }
    //updateLastMoveTime();
    return null; /* returns null to stand still on the same field */
  }

  bool _proofIfNextPositionIsValid(Position position, List<List< List<Entity>>> gameField) {
    if(position == null) return false;

    int fieldWidth = gameField.length;
    int fieldHeight = gameField[0].length;
    if(position.getX >= 0 && position.getX < fieldWidth && position.getY >= 0 && position.getY < fieldHeight) {
      return true;
    }
    return false;
  }

/* Position _proofIfPossibleToKillEnemy(List<List< List<Entity>>> gameField) {
    List<Position> possibleFields = new List<Position>();
    possibleFields.add(_proofIfEnemyOnField(gameField, Position.RIGHT));
    possibleFields.add(_proofIfEnemyOnField(gameField, Position.LEFT));
    possibleFields.add(_proofIfEnemyOnField(gameField, Position.DOWN));
    possibleFields.add(_proofIfEnemyOnField(gameField, Position.UP));

    for(Position possibleField in possibleFields) {
        if(possibleField != null) {
          return possibleField;
        }
    }
    return null;
  }

  Position _proofIfEnemyOnField(List<List< List<Entity>>> gameField, Position proofDirection) {
    if(position ==  null) return null;

    int newX = position.getX+proofDirection.getX;
    int newY = position.getY+proofDirection.getY;

    List<Entity> entityField = gameField[newX][newY];

    if(isMovePossible(entityField) && isLowerEnemyOnField(entityField) ) {
      return new Position(newX, newY);
    }
    return null;
  }

  bool isLowerEnemyOnField(List<Entity> entityField) {
      for(Entity enemy in entityField) {
        if(enemy.collision(this)) { // we are stronger than enemy
            return true;
        }
      }
      return false;
  }*/
}