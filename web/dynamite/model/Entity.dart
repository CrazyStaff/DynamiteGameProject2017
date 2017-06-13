import 'Modificator.dart';
import 'Position.dart';

abstract class Entity {
  static int MonsterCounter = 0;
  static int KistenCount = 0;

  Position _position;
  String _type;
  int lastMoveTime; // TODO: should be long? => no long in dart
  int lastActionTime;
  int walkingSpeed;
  int team;
  int strength;

  bool _alive;
  bool isWalkable = false; // dont change - collision baut auf isWalkable auf!!

  String getHTMLClass() => "class='$_type'";

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
    this._type = type;
    this._position = position;
    this._alive = true;
    this.strength = 0;
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


  // sollte immer nur zu einem neuen Feld bewegen!! -> wenn entity Field gleich bleibt kommt es zur concurrency Exception
  void moveTo(List<Entity> entityField) {
      // Move to the new field
      entityField.add(this);
      _position = getNextMove(null).clone(); // TODO null is evil for monster?

      for(Entity otherEntities in entityField) {
          this.collision(otherEntities);
      }
      lastMoveTime = new DateTime.now().millisecondsSinceEpoch;
  }

  // need to be override by implementation
  /**
   * Calculate the next position
   * @return NULL indicates that the position stays the same
   */
  Position getNextMove(List<List< List<Entity>>> gameField) {
    return null; // DO NOT CHANGE TO "position"
  }

  /**
   * Other entity is not in my team and is stronger than me
   */
  bool collision(Entity entity) {
    switch(entity.getType()) {
      case "MONSTER":
        if (entity.team != this.team) {
          if (entity.strength > this.strength) {
            this.setAlive(false);
            return false;
          } else
            entity.setAlive(false);
          return true;
        }
        break;
      case "FIRE":
            setAlive(false);
            break;
      case "PORTAL":
        if (getType() == "PLAYER") {
          if (Entity.MonsterCounter == 0) {
            setAlive(false);
          }
        }
        break;
    }
  }

  void setAlive(bool alive) {
      this._alive = alive;
  }

  String getType() {
    return this._type;
  }

  // need to be overriden by implementation
  Modificator atDestroy(List<List<List<Entity>>> gameField) {
    return null;
  }

   // need to be override by implementation
  void action(List<List< List<Entity>>> _gameField, int time) {
  }
}