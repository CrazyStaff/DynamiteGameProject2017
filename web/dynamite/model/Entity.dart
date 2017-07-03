import 'GameState.dart';
import 'Modificator.dart';
import 'Movement.dart';
import 'Position.dart';
import 'DynamiteGame.dart';
import 'Team.dart';
import 'pathfinding/FieldNode.dart';

/*
   This is the abstract class of all entities in the game
 */
abstract class Entity {
  /*
      Global information about the specified entities
   */
  static int destroyableBlockCount = 0;
  static int monsterCounter = 0;
  static int portalCount = 0;

  // The default view direction of the entity
  final Position DEFAULT_VIEW_DIRECTION = Movement.RIGHT;

  /*
    Information about the type of the entity
    The extension types is used for extra information
    f.e. that the monster has the attention mode on
    or the view direction of the entity
   */
  String type;
  List<String> extensionTypes;

  /*
      The position and next calculated position of the entity
   */
  Position _position;
  Position nextPosition;

  // The current view Direction of the entity
  Position viewDirection;

  /*
     For path finding it is needed to have
     the next view direction of the entity
  */
  Position nextViewDirection;

  /*
      The times are used for the consistently update
      of moves and actions of the entity
   */
  int lastMoveTime;
  int lastActionTime;

  /*
      Basic information about the entity
   */
  int walkingSpeed;
  List<Team> teams;
  int strength;
  bool _alive;
  bool isWalkable;
  String dieReason;

  /*
      If defined as true the entity has view images for front, back, left and right (f.e. player)
      If defined as false the entity has only view images for left and right (f.e. monsters)
   */
  bool supportMultiViewDirection;

  bool get isAlive => this._alive;
  Position get position => _position;

  Entity(String type, Position position) {
    this.type = type;
    this._position = position;
    this._alive = true;
    this.strength = 0;
    this.teams = new List<Team>();
    this.teams.add(Team.OTHER);
    this.isWalkable = false;
    this.extensionTypes = new List<String>();
    this.dieReason = "Timeout";
    this.supportMultiViewDirection = false;
    this.viewDirection = DEFAULT_VIEW_DIRECTION;

    setViewDirection();
  }

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
      Set the view direction to the calculated next view direction
   */
  void setViewDirection() {
    if(nextViewDirection != null) {
      viewDirection = nextViewDirection;
    }
    _updateViewDirectionInExtensionTypes();

    print("currentView: $viewDirection");
    print("nextView: $nextViewDirection");

  }

  /*
      Updates the view direction in extension types
   */
  void _updateViewDirectionInExtensionTypes() {
    String up = type +  "_UP";
    String down = type +  "_DOWN";
    String right = type +  "_RIGHT";
    String left = type +  "_LEFT";

    extensionTypes.remove(up);
    extensionTypes.remove(down);

    if(supportMultiViewDirection) {
      extensionTypes.remove(left);
      extensionTypes.remove(right);
    }

    /*
        View directions up and down don´t change anything
        while only left and right images are supported
     */
    if(supportMultiViewDirection) {
      if (viewDirection == Movement.UP) {
        extensionTypes.add(up);
      } else if (viewDirection == Movement.DOWN) {
        extensionTypes.add(down);
      }
    }

    if(viewDirection == Movement.LEFT) {
      extensionTypes.remove(left);
      extensionTypes.remove(right);
      extensionTypes.add(left);
    } else if(viewDirection == Movement.RIGHT) {
      extensionTypes.remove(left);
      extensionTypes.remove(right);
      extensionTypes.add(right);
    }
  }

  /*
      Set the new view direction based on the next moving position of monster
   */
  void setNextViewDirection() {
    if(nextPosition == null) return;
    this.nextViewDirection = nextPosition - position;
  }

  /*
      Initialize new team list and add then the new team to it
   */
  void setAbsolutelyNewTeam(Team team) {
    this.teams = new List<Team>();
    addToTeam(team);
  }

  /*
      Add the team to the existing team list
   */
  void addToTeam(Team team) {
    this.teams.add(team);
  }

  /*
     Checks ONLY if it is allowed to move based on the given time
   */
  bool isAllowedToMove(int time) {
    if(lastMoveTime == null) return false;
    return lastMoveTime + walkingSpeed <= time;
  }

  /**
     Proofs if 'entityField' is walkable
   */
  bool isMovePossible(List<Entity> entityField) {
    if(!isAlive) return false;

    for(Entity otherEntity in entityField) {
      if(!otherEntity.isWalkable) {
          return false;
      }
    }
    return true;
  }

  /*
      Moves the player to another field
   */
  void moveTo(List<Entity> entityField) {
    if(this.position == this.nextPosition) {
      throw new Exception("FATAL - Entity.moveTo: nextPosition should BE 'NULL' if you dont move."
          "=> dont give the 'nextPosition' the same position like 'position'"
          "=> it causes concurrencyException!!");
    }
      // Moves to the new field
      entityField.add(this);

      setNextViewDirection();
      _position = nextPosition;
      nextPosition = null;
      setViewDirection();

    if(this.getType() == "FRIDOLIN" || this.getType() == "FASTELLE" || this.getType() == "PLAYER") {
      for (Entity otherEntities in entityField) {
        if (this.collision(otherEntities)) {
          this.setAlive(false, "Collision with " + otherEntities.getType());
        }
        if(otherEntities.collision(this)) {
          otherEntities.setAlive(false, "Collision with " + this.getType());
        }
      }
    }

    // Updates the last move time
    lastMoveTime = new DateTime.now().millisecondsSinceEpoch;
  }

  /**
   * Calculate the next position of the entity
   * Needs to be overriden by the implementation
   * @return NULL indicates that the position stays the same
   */
  Position getNextMove(List<List< FieldNode >> gameField) {
    return null;
  }

  /**
      Proofs if there is a collision with another entity
      There is a collision if the other entity
      is not in my team and is stronger than me
   */
  bool collision(Entity entity) {
      if(!proofIfEntitiesInSameTeam(entity)) {
        if(entity.strength > this.strength) {
          return true;
        }
      }
      return false;
  }

  /*
      Proofs if the other entity has one team in which this entity is too
   */
  bool proofIfEntitiesInSameTeam(Entity otherEntity) {
    bool sameTeam = false;
    for(Team team in teams) {
      if(otherEntity.teams.contains(team)) {
        return true;
      }
    }
    return false;
  }

  void setAlive(bool alive, String reason) {
    if (this.getType() == "PORTAL") {
      return;
    }
    this.dieReason = reason;
    this._alive = alive;
  }

  String getType() {
    return this.type;
  }

  String getExtensionTypes() {
    String extTypes = "";
    for(String extensionType in extensionTypes) {
      extTypes += extensionType + " ";
    }
    print("EXT " + extTypes);
    return extTypes;
  }

  /*
      This method can be used to specify what happens
      after this entity is destroyed
      Needs to be overriden by the implementation
  */
  Modificator atDestroy(List<List< FieldNode >> gameField) {
    return null;
  }

   /*
      This method can be used to specify an special
      action for the entity
      Needs to be override by the implementation
      Use 'updateLastTimeAction()' in constructor of the inherited class to use this method
   */
  Modificator action(List<List< FieldNode >> _gameField, int time) {
    return null;
  }

  /* this strategy decides what to do if the entity is not moving
     1) in this method implemented:
        -> stand still for "walkingSpeed" time => so standing still is like a real move
     2) override method empty!
        -> allow entity (f.e. player) to move directly in the game tact after there is f.e. no input of user
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