import 'Modificator.dart';
import 'Position.dart';
import 'DynamiteGame.dart';
import 'pathfinding/FieldNode.dart';

abstract class Entity {
  static int destroyableBlockCount = 0;
  static int monsterCounter = 0;
  static int portalCount = 0;

  Position _position;
  Position nextPosition;
  String type;
  String extensionType;
  int lastMoveTime; // TODO: should be long? => no long in dart
  int lastActionTime;
  int walkingSpeed;
  int team;
  int strength;

  bool _alive;
  bool isWalkable;

  void updateLastMoveTime() {
    this.lastMoveTime = new DateTime.now().millisecondsSinceEpoch;
  }

  void updateLastActionTime() {
    this.lastActionTime = new DateTime.now().millisecondsSinceEpoch;
  }

  void setLastMoveTime(int lastMoveTime) {
    this.lastMoveTime = lastMoveTime;
  }

  void setWalkingSpeed(int walkingSpeed) {
    this.walkingSpeed = walkingSpeed;
  }

  int getWalkingSpeed() {
    return walkingSpeed;
  }

  /*
   * Checks ONLY if it is allowed to move based on the given time
   */
  bool isAllowedToMove(int time) {
    if(lastMoveTime == null) return false;
    return lastMoveTime + walkingSpeed <= time;
  }

  bool get isAlive => this._alive;

  Position get position => _position;

  Entity(String type, Position position) {
    this.type = type;
    this._position = position;
    this._alive = true;
    this.strength = 0;
    this.team = 0;
    this.isWalkable = false; // dont change - collision baut auf isWalkable auf!!
    this.extensionType = "";
  }

  /**
   * Proofs if 'entityField' is walkable
   */
  bool isMovePossible(List<Entity> entityField) {
    if(!isAlive) return false; // TODO: notwendig?

    for(Entity otherEntity in entityField) {
      if(!otherEntity.isWalkable) {
          return false;
      }
    }
    return true;
  }

  /* Should only move to a DIFFERENT field */
  void moveTo(List<Entity> entityField) {
    if(this.position == this.nextPosition) {
      throw new Exception("FATAL - Entity.moveTo: nextPosition should BE 'NULL' if you dont move."
          "=> dont give the 'nextPosition' the same position like 'position'"
          "=> it causes concurrencyException!!");
    }
      // Move to the new field
      entityField.add(this);

      _position = nextPosition;
      nextPosition = null; // nextPosition ist jetzt nicht mehr vorhanden

  if(this.getType() == "MONSTER" || this.getType() == "PLAYER") {
    for (Entity otherEntities in entityField) {
      if (this.collision(otherEntities)) {
         this.setAlive(false);
      }
      if(otherEntities.collision(this)) {
        otherEntities.setAlive(false);;
      }
    }
  }
      lastMoveTime = new DateTime.now().millisecondsSinceEpoch;
  }

  // need to be override by implementation
  /**
   * Calculate the next position
   * @return NULL indicates that the position stays the same
   */
  Position getNextMove(List<List< FieldNode >> gameField) {
    return null; // DO NOT CHANGE TO "position"
  }

  /**
   * Other entity is not in my team and is stronger than me
   */
  bool collision(Entity entity) {
      if(entity.team != this.team) {
        // Entities are enemies
        if (this.getType() == "PLAYER" && entity.getType() == "PORTAL" && Entity.monsterCounter == 0){
          DynamiteGame.gameStatus = 2;
        }
        if (this.getType() == "PORTAL" && entity.getType() == "PLAYER" && Entity.monsterCounter == 0){
          DynamiteGame.gameStatus = 2;
        }
        if(entity.strength > this.strength) {
          return true;
        }
      }
      return false;
  }

  void setAlive(bool alive) {
    if (this.getType() == "PORTAL") {
      return;
    }
    this._alive = alive;
  }

  String getType() {
    return this.type;
  }

  String getExtensionType() {
    return this.extensionType;
  }

  // need to be overriden by implementation
  Modificator atDestroy(List<List< FieldNode >> gameField) {
    return null;
  }

   // need to be override by implementation
  void action(List<List< FieldNode >> _gameField, int time) {
  }

  /* this strategy decides what to do if the entity is not moving
     1) in this method implemented:
        -> stand still for "walkingSpeed" time => so standing still is like a real move
     2) override method empty!
        -> allow entity (f.e. player) to move directly in the game tact after f.e. no input of user
   */
  void standStillStrategy() {
    this.updateLastMoveTime();
  }

  /*
      Update all the times used by entity to guarantee a pause method
   */
  void updateTimes(int offsetAddTime) {
    if(this.lastMoveTime != null) this.lastMoveTime += offsetAddTime;
    if(this.lastActionTime != null) this.lastActionTime += offsetAddTime;
  }
}