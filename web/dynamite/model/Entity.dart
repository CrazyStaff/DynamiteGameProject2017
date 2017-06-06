import 'Position.dart';

abstract class Entity {

  Position _position;
  String _type;
  int lastMoveTime; // TODO: should be long? => no long in dart
  int speed;

  int _team;
  int _strength;
  bool _alive = true;
  bool isWalkable = true;

  String getHTMLClass() => "class='$_type'";


  void updateLastMoveTime() {
    this.lastMoveTime = new DateTime.now().millisecondsSinceEpoch;
  }

  void setLastMoveTime(int m) {
    this.lastMoveTime = m;
  }

  void setSpeed(int speed) {
      this.speed = speed;
  }

  bool isAllowedToMove(int time) {
    if(lastMoveTime == null) return false; // auf == null hier prüfen?
    if(!isWalkable) return false;
    return lastMoveTime + speed <= time;
  }
  bool get isAlive => this._alive;

  Position get position => _position;

  Entity(String type, Position position) {
    this._type = type;
    this._position = position;
    this._alive = true;
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


  void moveTo(List<Entity> entityField) { // long
      // Move to the new field
      entityField.add(this);
      _position = getNextMove(null).clone(); // TODO null is evil for monster?

      for(Entity otherEntities in entityField) {
          if(this.collision(otherEntities)) {
              // TODO: 1) Bewege entity das letzte mal => beim nächsten Move aus Liste entfernen
              // TODO: ODER 2) Lösche entity bei Kollision direkt => also kein 'entityField.add(this);'
              _alive = false;
          }
      }
      lastMoveTime = new DateTime.now().millisecondsSinceEpoch;
  }

  // need to be override by implementation
  Position getNextMove(List<List< List<Entity>>> gameField) {
    return _position;
  }

  // need to be override by implementation
  void action(List<List< List<Entity>>> _gameField, int time) {

  }

  // need to be override by implementation
  void atDestroy(List<List< List<Entity>>> gameField) {

  }
  /**
   * Other entity is not in my team and is stronger than me
   */
  bool collision(Entity entity) {
      if(entity._team != this._team) {
        // Entities are enemies
        if(entity._strength > entity._strength)  { // TODO: >= ? - Was passiert wenn beide gleich stark sind?
          return true;
        }
      }
      return false;
  }

  void setAlive(bool alive) {
      this._alive = alive;
  }

  void setStrength(int x) { // add oder set ?

  }

  String getType() {
    return this._type;
  }
}