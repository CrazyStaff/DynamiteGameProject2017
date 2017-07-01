import '../Entity.dart';
import '../Modificator.dart';
import '../Movement.dart';
import '../Position.dart';
import '../Target.dart';
import '../items/Portal.dart';
import '../pathfinding/FieldNode.dart';
import 'dart:math';

/*
    The monster is the enemy of the player
    If the monster sees an enemy of himself (f.e. the player)
    it will chase the enemy with the help of path finding
 */
class Monster extends Entity {

  // The entity type identifies the entity as monster
  static const ENTITY_TYPE = "MONSTER";

  // The front view range of the monster
  static const int VIEW_FIELD_RANGE = 4;

  // The default view direction of the monster
  final Position DEFAULT_VIEW_DIRECTION = Movement.RIGHT;

  // The current view Direction of the monster
  Position viewDirection;

  /*
     For path finding it is needed to have
     the next view direction of monster calculated
  */
  Position nextViewDirection;

  /*
     The monster can store only one target at a time
     It moves to the last seen position of the enemy which
     will be stored in target if the enemy is sighted
   */
  Target _target;

  Monster(Position position) : super(ENTITY_TYPE, position) {
    // Increase the counter of all enemies
    Entity.monsterCounter += 1;

    this._target = new Target();
    this.isWalkable = true;
    this.strength = 50;
    this.team = 2;
    this.viewDirection = DEFAULT_VIEW_DIRECTION;

    this.setWalkingSpeed(1000);

    /*
      this updates the time of the last action so that the action method
      can be called from 'DynamiteGame'
    */
    this.updateLastMoveTime();
  }

  /*
    Set also the new view direction after the monster had moved
   */
  @override
  void moveTo(List<Entity> entityField) {
      super.moveTo(entityField);
      _setViewDirection();
  }

  /*
      There is nothing to destroy after the monster died
   */
  @override
  Modificator atDestroy(List<List< FieldNode >> gameField) {
      // Decrease the counter of all monsters
      Entity.monsterCounter -= 1;
      return null;
  }

  /*
      Set the view direction to the calculated next view direction
   */
  _setViewDirection() {
      viewDirection = nextViewDirection;
  }

  /*
      Set the new view direction based on the next moving position of monster
   */
  _setNextViewDirection() {
    if(nextPosition == null) return;
    this.nextViewDirection = nextPosition - position;
  }

  /*
      Calculates the next move of the monster
      If the monster has no target it moves randomly
      and if the monster has a target it moves to the
      last seen position of the enemy target
   */
  @override
  Position getNextMove(List<List< FieldNode >> gameField) {
    _registerEnemiesInViewRange(gameField);

    if(!_target.hasPathToTarget()) {
      // Move randomly
      nextPosition = moveRandomly(gameField);
    } else {
      // Move to the position where you have seen the target at last
      nextPosition = _target.nextStepToTarget();
    }

      /*
          Determines the next view direction based on
          the next calculated position of the monster
       */
    _setNextViewDirection();
    return nextPosition;
  }

  /*
      Register weaker enemies in the monsters view range
      The view range contains all the fields in front of the monster based on
      the range of 'VIEW_FIELD_RANGE' and the directly fields to the left and to the right
      A monster could see only enemies if there are no obstacles
      between the enemy and the monster
   */
  void _registerEnemiesInViewRange(List<List< FieldNode >> gameField) {
    List<Position> fullViewRange = _getFieldsOfViewRange();
    List<Position> walkableViewRange = getWalkableFieldsOfViewRange(fullViewRange, gameField);

    /*
        If the monster don´t have a target there shouldn´t
        be a attention warning of the monster in the view
     */
    if(!_target.hasPathToTarget()) {
      this.extensionType = "";
    }

    /*
        Kill all enemies whose are weaker than the monster to the
        directly fields on the right and on the left
     */
    if(_killWeakerEnemyBesideMonster(gameField)) {
      return;
    }

    for(Position pos in fullViewRange) {
      if(_proofIfPositionIsValid(pos, gameField)) {
        List<Entity> entityField = gameField[pos.getX][pos.getY].getEntities;

        /* Select a target if it attains all conditions as a new target
              1) entityField is walkable
              2) entityField has enemy
              3) the monster is stronger than the enemy
        */
        for(Entity entity in entityField) {
          // Only find enemies whose are weaker than the monster
          if(_isWeakerEnemy(entity, entityField)) {

            /*
                Proof if there a no obstacles between the monster and the enemy
                otherwise the monster can´t see the enemy
             */
            if (!_proofIfObstaclesInView(walkableViewRange, entity, gameField)) {
              _target.setTarget(entity);
              _target.setPathToTargetFrom(this, gameField);

              // Show in the view that the monster has sighted the enemy
              this.extensionType = "ENTITY_ATTENTION";
              return;
            }
          }
        }
      }
    }
  }

  /*
     Kill all enemies whose are weaker than the monster to the
     directly fields on the right and on the left
     Returns true if a weaker enemy was found directly
     next to the monsters position
  */
  bool _killWeakerEnemyBesideMonster(List<List< FieldNode >> gameField) {
    Position down = this.position + Movement.DOWN;
    Position up = this.position + Movement.UP;
    Position left = this.position + Movement.LEFT;
    Position right = this.position + Movement.RIGHT;

    Entity killEntity;
    // Proof the fields beside the monster if the view direction is vertical
    if(viewDirection == Movement.UP || viewDirection == Movement.DOWN) {
      if(Movement.isMovePossible(left, gameField)) {
        List<Entity> fieldEntities = gameField[left.getX][left.getY].getEntities;
        for (Entity entity in fieldEntities) {
          if (_isWeakerEnemy(entity, fieldEntities)) {
            // Monster found an enemy on the left side of him
            killEntity = entity;
          }
        }
      }

      if(Movement.isMovePossible(right, gameField)) {
        List<Entity> fieldEntities = gameField[right.getX][right.getY].getEntities;
        for (Entity entity in fieldEntities) {
          if (_isWeakerEnemy(entity, fieldEntities)) {
            // Monster found an enemy on the right side of him
            killEntity = entity;
          }
        }
      }
      // Proof the fields beside the monster if the view direction is horizontal
    } else if(viewDirection == Movement.RIGHT || viewDirection == Movement.LEFT) {
      if(Movement.isMovePossible(up, gameField)) {
        List<Entity> fieldEntities = gameField[up.getX][up.getY].getEntities;
        for (Entity entity in fieldEntities) {
          if (_isWeakerEnemy(entity, fieldEntities)) {
            // Monster found an enemy above him
            killEntity = entity;
          }
        }
      }

      if(Movement.isMovePossible(down, gameField)) {
        List<Entity> fieldEntities = gameField[down.getX][down.getY].getEntities;
        for (Entity entity in fieldEntities) {
          if (_isWeakerEnemy(entity, fieldEntities)) {
            // Monster found an enemy under him
            killEntity = entity;
          }
        }
      }
    }

    /*
        If the monster found an enemy set the
        move path of the monster to the enemy
     */
    if(killEntity != null) {
      _target.setTarget(killEntity);
      _target.setPathToTargetFrom(this, gameField);
      return true;
    }
    return false;
  }

  /*
      Proofs if the entity is weaker than the monster
   */
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

  /*
     Proof if there are obstacles between the monster and the enemy
     The implementation is based on the documentation
   */
  bool _proofIfObstaclesInView(List<Position> walkableViewRange, Entity mtarget, List<List< FieldNode >> gameField) {
    /*
        The lines which are checked from the viewpoint of the monster to the enemy
        These lines are specified for a realistic view field of the monster because
        sometimes the monster cannot see the enemy since the eyes are in top position of the field
        [left line of monster to enemy, mid line of monster to enemy, right line of monster to enemy]
     */
    List<Entity> checkLinesTopFrom = [mtarget, this, this];
    List<Entity> checkLinesBottomFrom = [this, this, mtarget];
    List<Entity> checkLinesRightFrom = [mtarget, this, this];
    List<Entity> checkLinesLeftFrom = [mtarget, this, this];

    /*
        The distance between the monster and the target
     */
    int xDistance = (mtarget.position.getX - this.position.getX).abs();
    int yDistance = (mtarget.position.getY - this.position.getY).abs();

    /*
        Proof all the lines for obstacles from the monster to the enemy
    */
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

    // Proof field directly next to the monster in viewDirection
    Position fieldNextToMonster = this.position + viewDirection;

    // Proof field directly next to target against viewDirection
    Position fieldNextToTarget = mtarget.position - viewDirection;

    // Proof the vertical line for obstacles
    if(viewDirection == Movement.UP || viewDirection == Movement.DOWN) {
      if(yDistance > 1) {
        if(!walkableViewRange.contains(fieldNextToMonster)) {
          return true;
        }
        if(!walkableViewRange.contains(fieldNextToTarget)) {
          return true;
        }
      }
    } // Proof the horizontal line for obstacles
    else if(viewDirection == Movement.RIGHT || viewDirection == Movement.LEFT) {
      if(xDistance > 1) {
        if(!walkableViewRange.contains(fieldNextToMonster)) {
          return true;
        }
        if(!walkableViewRange.contains(fieldNextToTarget)) {
          return true;
        }
      }
    }

    // Proof the special case mentioned in the documentation
    if(_isSpecialCase(walkableViewRange, mtarget)) {
      return true;
    }

    // There are no obstacles between the enemy and the monster
    return false;
  }

  /*
      Proof for the special case that the monster is next to the enemy
      but there are still obstacles in the view point (in example the obstacles
      are all the blocks of 'B')

      For example: E=Enemy, M=Monster, B=Block
                    B E     or    M B
                    M B           B E
      This special case is only implemented for a realistic view of monster
   */
  bool _isSpecialCase(List<Position> walkableViewRange, Entity mtarget) {
    Position horizontal = this.position + this.viewDirection;
    Position down = this.position + Movement.DOWN;
    Position up = this.position + Movement.UP;
    Position left = this.position + Movement.LEFT;
    Position right = this.position + Movement.RIGHT;

    /*
        The distance between the monster and the target
     */
    int xDistance = (mtarget.position.getX - this.position.getX);
    int yDistance = (mtarget.position.getY - this.position.getY);

    // Proof if the the special case emerges in the view direction 'up'
    if (viewDirection == Movement.UP) {
      if (yDistance == -1) { // The target is above the monster
        if (xDistance == -1) { // The Target is on the left of the monster
          if (!walkableViewRange.contains(horizontal) &&
              !walkableViewRange.contains(left)) {
            return true;
          }
        }

        if (xDistance == 1) { // The target is on the right of the monster
          if (!walkableViewRange.contains(horizontal) &&
              !walkableViewRange.contains(right)) {
            return true;
          }
        }
      }
    }// Proof if the the special case emerges in the view direction 'down'
    else if(viewDirection == Movement.DOWN) {
      if (yDistance == 1) { // The target is under the monster
        if (xDistance == -1) { // The target is on the left of the monster
          if (!walkableViewRange.contains(horizontal) &&
              !walkableViewRange.contains(left)) {
            return true;
          }
        }

        if (xDistance == 1) { // The target is on the right of the monster
          if (!walkableViewRange.contains(horizontal) &&
              !walkableViewRange.contains(right)) {
            return true;
          }
        }
      }
    }// Proof if the the special case emerges in the view direction 'right'
    else if (viewDirection == Movement.RIGHT) {
      if (xDistance == 1) { // The monster is next to the target
        if (yDistance == -1) { // The target is above the monster
          if (!walkableViewRange.contains(horizontal) &&
              !walkableViewRange.contains(up)) {
            return true;
          }
        }

        if (yDistance == 1) { // The target is at the bottom of the monster
          if (!walkableViewRange.contains(horizontal) &&
              !walkableViewRange.contains(down)) {
            return true;
          }
        }
      }
    }// Proof if the the special case emerges in the view direction 'left'
    else if (viewDirection == Movement.LEFT) {
      if (xDistance == -1) { // The monster is next to the target
        if (yDistance == -1) { // The target is above monster
          if (!walkableViewRange.contains(horizontal) &&
              !walkableViewRange.contains(up)) {
            return true;
          }
        }

        if (yDistance == 1) { // The target is at the bottom of the monster
          if (!walkableViewRange.contains(horizontal) &&
              !walkableViewRange.contains(down)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  /*
      Proof the whole given line "checkLine" from the monster to the target for obstacles
   */
  bool proofLineForObstacles(List<Entity> checkLine, List<Position> walkableViewRange, Entity target) {
    /*
        The distance between the monster and the target
     */
    int xDistance = (target.position.getX - this.position.getX);
    int yDistance = (target.position.getY - this.position.getY);

    // Determines the other entity where the line is going to
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
      Determines if the 'line' is needed to be checked so
      that the line is in the view field of the monster
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

  /*
      Proof if the line to the top from the enemy to the target has obstacles
   */
  bool _checkLineUpForObstacles(List<Position> walkableViewRange, Entity checkWholeLine, Entity destination) {
    for (int y = checkWholeLine.position.getY - 1; y > destination.position.getY + 1; y--) {
      if (walkableViewRange.contains(new Position(checkWholeLine.position.getX, y))) {
          return true;
      }
    }
    return false;
  }

  /*
      Proof if the line to the bottom from the enemy to the target has obstacles
   */
  bool _checkLineDownForObstacles(List<Position> walkableViewRange, Entity checkWholeLine, Entity destination) {
    for (int y = checkWholeLine.position.getY + 1; y < destination.position.getY - 1; y++) {
      if (walkableViewRange.contains(new Position(checkWholeLine.position.getX, y))) {
        return true;
      }
    }
    return false;
  }

  /*
      Proof if the left line from the enemy to the target has obstacles
   */
  bool _checkLineLeftForObstacles(List<Position> walkableViewRange, Entity checkWholeLine, Entity destination) {
    for (int x = checkWholeLine.position.getX - 1; x > destination.position.getX + 1; x--) {
      if (walkableViewRange.contains(new Position(x, checkWholeLine.position.getY))) {
        return true;
      }
    }
    return false;
  }

  /*
      Proof if the right line from the enemy to the target has obstacles
   */
  bool _checkLineRightForObstacles(List<Position> walkableViewRange, Entity checkWholeLine, Entity destination) {
    for (int x = checkWholeLine.position.getX + 1; x < destination.position.getX - 1; x++) {
      if (walkableViewRange.contains(new Position(x, checkWholeLine.position.getY))) {
          return true;
      }
    }
    return false;
  }

  /*
      Proof if the 'gameField' is not walkable based on the given position
   */
  bool isNotWalkable(Position pos, List<List< FieldNode >> gameField) {
      if(!Movement.isMovePossible(pos, gameField)) return true;
      return !gameField[pos.getX][pos.getY].isWalkableFor(this);
  }

  /*
      Get all the walkable fields of the view range of the monster
   */
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

  /*
      Determines the view field of the monster based on the view
      range of the monster
   */
  List<Position> _getFieldsOfViewRange() {
    List<Position> viewRangeFields = new List<Position>();
    Position nextField = position;

    for(int i=1; i <= VIEW_FIELD_RANGE; i++) {
      nextField += this.viewDirection;
      viewRangeFields.add(nextField);

      // If the view direction is is vertical
      if(this.viewDirection == Movement.UP ||
          this.viewDirection == Movement.DOWN) {
        viewRangeFields.add(nextField + new Position(1, 0));
        viewRangeFields.add(nextField + new Position(-1, 0));
      }

      // If the view direction is horizontal
      if(this.viewDirection == Movement.LEFT ||
          this.viewDirection == Movement.RIGHT) {
        viewRangeFields.add(nextField + new Position(0, 1));
        viewRangeFields.add(nextField + new Position(0, -1));
      }
    }
    return viewRangeFields;
  }

  /*
      Moves the monster randomly to one horizontal or vertical field
      next to the monster or it is also possible that the monster stands still
   */
  Position moveRandomly(List<List< FieldNode >> gameField) {
    Random random = new Random();
    /*
        If we want to move randomly we should check if the player
        can move to one horizontal or vertical direction
        After 4 attempts the monster should stay on the same field
     */
    for (int attempt = 0; attempt < 4; attempt++) {
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
    // returns null to stand still on the same field
    return null;
  }

  /*
      Proof if the 'position' is valid on the game field
   */
  bool _proofIfPositionIsValid(Position position, List<List< FieldNode >> gameField) {
    if(position == null) return false;

    int fieldWidth = gameField.length;
    int fieldHeight = gameField[0].length;
    if(position.getX >= 0 && position.getX < fieldWidth && position.getY >= 0 && position.getY < fieldHeight) {
      return true;
    }
    return false;
  }
}