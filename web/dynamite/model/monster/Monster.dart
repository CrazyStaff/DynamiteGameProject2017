import '../Entity.dart';
import '../Modificator.dart';
import '../Movement.dart';
import '../Position.dart';
import '../Target.dart';
import '../items/Portal.dart';
import '../pathfinding/FieldNode.dart';
import 'dart:math';

class Monster extends Entity {
  static const int VIEW_FIELD_RANGE = 4;

  static const ENTITY_TYPE = "MONSTER";

  Position viewDirection;
  Position nextViewDirection;

  Target _target;

  Monster(Position position) : super(ENTITY_TYPE, position) {
    Entity.monsterCounter += 1;

    this._target = new Target();
    this.isWalkable = true;
    this.strength = 50;
    this.team = 2;
    this.viewDirection = Movement.RIGHT; // change init here

    this.setWalkingSpeed(1000);
    this.updateLastMoveTime();
  }

  void setNextMove(Position nextPosition) {
     this.nextPosition = nextPosition;
  }

  @override
  void moveTo(List<Entity> entityField) {
      super.moveTo(entityField);
      _setViewDirection();
  }

  @override
  Modificator atDestroy(List<List< FieldNode >> gameField) {
        Entity.monsterCounter -= 1;
        return null;
  }

  _setViewDirection() {
      viewDirection = nextViewDirection;
  }

  _setNextViewDirection() {
    if(nextPosition == null) return;
    this.nextViewDirection = nextPosition - position;
  }


  @override
  Position getNextMove(List<List< FieldNode >> gameField) {
    _registerEnemiesInViewRange(gameField);

    if(!_target.hasPathToTarget()) {
      // 1) TODO - other strategy -> use defined path ( read from file -> monster path ) instead of random movement
      nextPosition = _moveRandom(gameField);
    } else {
      // TODO: Lauf zum Punkt wo du den Helden das letzte mal gesehen hast
      nextPosition = _target.nextStepToTarget();
    }

    _setNextViewDirection();
    return nextPosition;
  }

  void _registerEnemiesInViewRange(List<List< FieldNode >> gameField) {
    List<Position> fullViewRange = _getFieldsOfViewRange();
    List<Position> walkableViewRange = getWalkableFieldsOfViewRange(fullViewRange, gameField);

    if(!_target.hasPathToTarget()) { // reset attention of enemy
      this.extensionType = "";
    }

    if(_killWeakerEnemyBesideMonster(gameField)) {
      return;
    }

        for(Position pos in fullViewRange) {
          if(_proofIfPositionIsValid(pos, gameField)) {
              List<Entity> entityField = gameField[pos.getX][pos.getY].getEntities;

              /* Select a target if it attains all conditions as a new target
                  1) entityField is walkable
                  2) entityField has enemy
                  3) im stronger than enemy
               */
              for(Entity entity in entityField) {
                if(_isWeakerEnemy(entity, entityField)) {
                  //print("Monster found target at $pos");

                  if (!_proofIfObstaclesInView(walkableViewRange, entity, gameField)) {
                    _target.setTarget(entity);
                    _target.setPathToTargetFrom(this, gameField);
                    this.extensionType = "ENTITY_ATTENTION";
                    return;
                  }
                }
              }
          }
        }
  }
  bool _killWeakerEnemyBesideMonster(List<List< FieldNode >> gameField) {
    Position down = this.position + Movement.DOWN;
    Position up = this.position + Movement.UP;
    Position left = this.position + Movement.LEFT;
    Position right = this.position + Movement.RIGHT;

    Entity killEntity;
    if(viewDirection == Movement.UP || viewDirection == Movement.DOWN) {
      if(Movement.isMovePossible(left, gameField)) {
        List<Entity> fieldEntities = gameField[left.getX][left.getY].getEntities;
        for (Entity entity in fieldEntities) {
          if (_isWeakerEnemy(entity, fieldEntities)) {
            killEntity = entity;
          }
        }
      }

      if(Movement.isMovePossible(right, gameField)) {
        List<Entity> fieldEntities = gameField[right.getX][right.getY].getEntities;
        for (Entity entity in fieldEntities) {
          if (_isWeakerEnemy(entity, fieldEntities)) {
            killEntity = entity;
          }
        }
      }
    } else if(viewDirection == Movement.RIGHT || viewDirection == Movement.LEFT) {
      if(Movement.isMovePossible(up, gameField)) {
        List<Entity> fieldEntities = gameField[up.getX][up.getY].getEntities;
        for (Entity entity in fieldEntities) {
          if (_isWeakerEnemy(entity, fieldEntities)) {
            killEntity = entity;
          }
        }
      }

      if(Movement.isMovePossible(down, gameField)) {
        List<Entity> fieldEntities = gameField[down.getX][down.getY].getEntities;
        for (Entity entity in fieldEntities) {
          if (_isWeakerEnemy(entity, fieldEntities)) {
            killEntity = entity;
          }
        }
      }
    }

    if(killEntity != null) {
      _target.setTarget(killEntity);
      _target.setPathToTargetFrom(this, gameField);
      return true;
    }
    return false;
  }

  bool _isWeakerEnemy(Entity entity, List<Entity> entityField) {
    if (isMovePossible(entityField)) {
      if (entity.team != this.team) {
        if (this.strength > entity.strength) {
          if (entity.type != Portal.ENTITY_TYPE) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool _proofIfObstaclesInView(List<Position> walkableViewRange, Entity mtarget, List<List< FieldNode >> gameField) {

    /* [left: target.x/y < monster.x/y, mid: target == monster, right: target.x/y > monster.x/y] */
    List<Entity> checkLinesTopFrom = [mtarget, this, this];
    List<Entity> checkLinesBottomFrom = [this, this, mtarget];
    List<Entity> checkLinesRightFrom = [mtarget, this, this];
    List<Entity> checkLinesLeftFrom = [mtarget, this, this];

    int xDistance = (mtarget.position.getX - this.position.getX).abs();
    int yDistance = (mtarget.position.getY - this.position.getY).abs();

    if(proofLineForObstacles(checkLinesTopFrom, walkableViewRange, mtarget)) {
      return true;
    }

    if(proofLineForObstacles(checkLinesBottomFrom, walkableViewRange, mtarget)) {
      return true;
    }

    if(proofLineForObstacles(checkLinesLeftFrom, walkableViewRange, mtarget)) {
      return true;
    }

    if(proofLineForObstacles(checkLinesRightFrom, walkableViewRange, mtarget)) {
      return true;
    }

    // proof field directly next to monster in viewDirection
    Position fieldNextToMonster = this.position + viewDirection;

    // proof field directly next to target against viewDirection
    Position fieldNextToTarget = mtarget.position - viewDirection;

    if(viewDirection == Movement.UP || viewDirection == Movement.DOWN) {
      if(yDistance > 1) {
        if(!walkableViewRange.contains(fieldNextToMonster)) {
          return true;
        }
        if(!walkableViewRange.contains(fieldNextToTarget)) {
          return true;
        }
      }
    } else if(viewDirection == Movement.RIGHT || viewDirection == Movement.LEFT) {
      if(xDistance > 1) {
        if(!walkableViewRange.contains(fieldNextToMonster)) {
          return true;
        }
        if(!walkableViewRange.contains(fieldNextToTarget)) {
          return true;
        }
      }
    }

    if(_isSpecialCase(walkableViewRange, mtarget)) {
      return true;
    }

    return false;
  }

  bool _isSpecialCase(List<Position> walkableViewRange, Entity mtarget) {
    Position horizontal = this.position + this.viewDirection; // left/right oder up/down
    Position down = this.position + Movement.DOWN;
    Position up = this.position + Movement.UP;
    Position left = this.position + Movement.LEFT;
    Position right = this.position + Movement.RIGHT;

    int xDistance = (mtarget.position.getX - this.position.getX);
    int yDistance = (mtarget.position.getY - this.position.getY);

    if (viewDirection == Movement.UP) {
      if (yDistance == -1) { // target is above monster
        if (xDistance == -1) { // target is at left of monster
          if (!walkableViewRange.contains(horizontal) &&
              !walkableViewRange.contains(left)) {
            return true;
          }
        }

        if (xDistance == 1) { // target is at right of monster
          if (!walkableViewRange.contains(horizontal) &&
              !walkableViewRange.contains(right)) {
            return true;
          }
        }
      }
    } else if(viewDirection == Movement.DOWN) {
      if (yDistance == 1) { // target is under monster
        if (xDistance == -1) { // target is at left of monster
          if (!walkableViewRange.contains(horizontal) &&
              !walkableViewRange.contains(left)) {
            return true;
          }
        }

        if (xDistance == 1) { // target is at right of monster
          if (!walkableViewRange.contains(horizontal) &&
              !walkableViewRange.contains(right)) {
            return true;
          }
        }
      }
    }else if (viewDirection == Movement.RIGHT) {
      if (xDistance == 1) { // monster is next to target
        if (yDistance == -1) { // target is above monster
          if (!walkableViewRange.contains(horizontal) &&
              !walkableViewRange.contains(up)) {
            return true;
          }
        }

        if (yDistance == 1) { // target is at bottom of monster
          if (!walkableViewRange.contains(horizontal) &&
              !walkableViewRange.contains(down)) {
            return true;
          }
        }
      }
    } else if (viewDirection == Movement.LEFT) {
      if (xDistance == -1) { // monster is next to target
        if (yDistance == -1) { // target is above monster
          if (!walkableViewRange.contains(horizontal) &&
              !walkableViewRange.contains(up)) {
            return true;
          }
        }

        if (yDistance == 1) { // target is at bottom of monster
          if (!walkableViewRange.contains(horizontal) &&
              !walkableViewRange.contains(down)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool proofLineForObstacles(List<Entity> checkLine, List<Position> walkableViewRange, Entity target) {
    int xDistance = (target.position.getX - this.position.getX);
    int yDistance = (target.position.getY - this.position.getY);

    var otherEntity = (checkLine == this ? target : this);

    for (int i = 0; i < checkLine.length; i++) {
      Entity lineEntity = checkLine[i];

      if (_isLineToCheck(i, xDistance, yDistance)) {
        var directionFunction;
        if (this.viewDirection == Movement.UP) {
          // target -> monster  _checkLineDownForObstacles
          // monster -> target _checkLineUpForObstacles
          directionFunction = (checkLine == this ? _checkLineUpForObstacles : _checkLineDownForObstacles);
        } else if (this.viewDirection == Movement.DOWN) {
          // monster -> target => _checkLineDownForObstacles
          // target -> monster = _checkLineUpForObstacles
          directionFunction = (checkLine == this ? _checkLineDownForObstacles : _checkLineUpForObstacles);
        } else if (this.viewDirection == Movement.RIGHT) {
          // target -> monster => _checkLineLeftForObstacles
          // monster -> target => _checkLineRightForObstacles
          directionFunction = (checkLine == this ? _checkLineRightForObstacles : _checkLineLeftForObstacles);
        } else if (this.viewDirection == Movement.LEFT) {
          // target -> monster => _checkLineRightForObstacles
          // monster -> target => _checkLineLeftForObstacles
          directionFunction = (checkLine == this ? _checkLineLeftForObstacles : _checkLineRightForObstacles);
        }

        if (directionFunction(walkableViewRange, lineEntity, otherEntity)) {
          return true;
        }
      }
    }
    return false;
  }

  /*
   * Determines if 'line' is the line to check
   */
  bool _isLineToCheck(int line, int xDistance, int yDistance) {
    var checkDistance;
    if(this.viewDirection == Movement.UP || this.viewDirection == Movement.DOWN) {
      checkDistance = xDistance;
    } else if(this.viewDirection == Movement.RIGHT || this.viewDirection == Movement.LEFT) {
      checkDistance = yDistance;
    }

    if(checkDistance == -1 && line == 0
    || checkDistance == 0 && line == 1
    || checkDistance == 1 && line == 2) {
      return true;
    }
    return false;
  }


  bool _checkLineUpForObstacles(List<Position> walkableViewRange, Entity checkWholeLine, Entity destination) {
    for (int y = checkWholeLine.position.getY - 1; y > destination.position.getY + 1; y--) {
      if (walkableViewRange.contains(new Position(checkWholeLine.position.getX, y))) {
          return true;
      }
    }
    return false;
  }

  bool _checkLineDownForObstacles(List<Position> walkableViewRange, Entity checkWholeLine, Entity destination) {
    for (int y = checkWholeLine.position.getY + 1; y < destination.position.getY - 1; y++) {
      if (walkableViewRange.contains(new Position(checkWholeLine.position.getX, y))) {
        return true;
      }
    }
    return false;
  }

  bool _checkLineLeftForObstacles(List<Position> walkableViewRange, Entity checkWholeLine, Entity destination) {
    for (int x = checkWholeLine.position.getX - 1; x > destination.position.getX + 1; x--) {
      if (walkableViewRange.contains(new Position(x, checkWholeLine.position.getY))) {
        return true;
      }
    }
    return false;
  }

  bool _checkLineRightForObstacles(List<Position> walkableViewRange, Entity checkWholeLine, Entity destination) {
    for (int x = checkWholeLine.position.getX + 1; x < destination.position.getX - 1; x++) {
      if (walkableViewRange.contains(new Position(x, checkWholeLine.position.getY))) {
          return true;
      }
    }
    return false;
  }

  bool isNotWalkable(Position pos, List<List< FieldNode >> gameField) {
      if(!Movement.isMovePossible(pos, gameField)) return true;
      return !gameField[pos.getX][pos.getY].isWalkableFor(this);
  }

  List<Position> getWalkableFieldsOfViewRange(final List<Position> viewRange, List<List< FieldNode >> gameField) {
    var toRemove = [];
    for(Position position in viewRange) {
      if(isNotWalkable(position, gameField)) {
        toRemove.add(position);
      }
    }
    viewRange.removeWhere((e) => toRemove.contains(e));
    return viewRange;
  }

  List<Position> _getFieldsOfViewRange() {
    List<Position> viewRangeFields = new List<Position>();
    Position nextField = position;

    //print(" ...S...");
    //print("START : : $position");
    for(int i=1; i <= VIEW_FIELD_RANGE; i++) {
      nextField += this.viewDirection;
      viewRangeFields.add(nextField); // add field in viewDirection

      //print("SF: $nextField");

      //print("ViewDir : ${this.viewDirection}");

      if(this.viewDirection == Movement.UP ||
          this.viewDirection == Movement.DOWN) {
        /* horizontal: add both fields next to 'nextField' */
        viewRangeFields.add(nextField + new Position(1, 0));
        //print("U ${nextField + new Position(1, 0)}");
        viewRangeFields.add(nextField + new Position(-1, 0));
        //print("D ${nextField + new Position(-1, 0)}");
      }

      if(this.viewDirection == Movement.LEFT ||
          this.viewDirection == Movement.RIGHT) {
        /* vertical: add both fields next to 'nextField' */
        viewRangeFields.add(nextField + new Position(0, 1));
        //print("R ${nextField + new Position(0, 1)}");
        viewRangeFields.add(nextField + new Position(0, -1));
        //print("L ${nextField + new Position(0, -1)}");
      }
    }

    //print(" ...E...");
    return viewRangeFields;
  }

  Position _moveRandom(List<List< FieldNode >> gameField) {
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
      if( _proofIfPositionIsValid(nextPosition, gameField)) {
        if (isMovePossible(gameField[nextPosition.getX][nextPosition.getY].getEntities)) {
          return nextPosition;
        }
      }
    }
    //updateLastMoveTime();
    return null; /* returns null to stand still on the same field */
  }

  bool _proofIfPositionIsValid(Position position, List<List< FieldNode >> gameField) {
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