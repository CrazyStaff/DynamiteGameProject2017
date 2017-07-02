import 'Entity.dart';
import 'Position.dart';
import 'pathfinding/FieldNode.dart';

/*
    The player that is controlled by the user
 */
class Player extends Entity {

  // The entity type identifies the entity as player
  static final ENTITY_TYPE = "PLAYER";

  bool _hasWon;
  int _dynamiteRangeOffset;

  Player(Position position) : super(ENTITY_TYPE, position) {
      this._dynamiteRangeOffset = 0;
      this._hasWon = false;
      this.team = 1;
      this.strength = 42;
      this.isWalkable = true;

      setWalkingSpeed(300);
      /*
          this updates the time of the last action so that the action method
          can be called from 'DynamiteGame'
      */
      updateLastMoveTime();
  }

  get hasWon => this._hasWon;
  get dynamiteRangeOffset => this._dynamiteRangeOffset;
  set dynamiteRangeOffset(int offset) => this._dynamiteRangeOffset = offset;

  void setNextMove(Position moveOffset) {
      // go every time from the current position
      nextPosition = position.clone();
      nextPosition.addOffset(moveOffset);
  }

  @override
  bool collision(Entity  otherEntity) {
    if (otherEntity.getType() == "PORTAL" && Entity.monsterCounter == 0){
      _hasWon = true;
    }

    if (otherEntity.getType() == "DYNAMITERANGE") {
      print(otherEntity.getType() + " collect Item");
      _dynamiteRangeOffset++;
    }

    return super.collision(otherEntity);
  }

  @override
  Position getNextMove(List<List< FieldNode >> gameField) {
    return nextPosition;
  }

  @override
  void standStillStrategy() {
    // needs to be empty implemented!
    // -> allow player to move directly in the game tact after no input of user
  }

  @override
  void action(List<List<FieldNode>> _gameField, int time) {
    _checkIfAlreadyOverPortal(_gameField);
  }

  /*
      Proof if the player is already over the portal than make sure he has won
   */
  void _checkIfAlreadyOverPortal(List<List<FieldNode>> _gameField) {
    FieldNode myPosition = _gameField[position.getX][position.getY];

    for(Entity entity in myPosition.getEntities) {
      if (entity.getType() == "PORTAL" && Entity.monsterCounter == 0){
        _hasWon = true;
      }
    }
  }
}