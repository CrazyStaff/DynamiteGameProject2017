import 'Entity.dart';
import 'Modificator.dart';
import 'Position.dart';
import 'Team.dart';
import 'pathfinding/FieldNode.dart';

/*
    The player that is controlled by the user
 */
class Player extends Entity {

  // The entity type identifies the entity as player
  static final ENTITY_TYPE = "PLAYER";

  bool _hasWon;
  int _dynamiteRangeOffset;
  int _bonusLife;

  Player(Position position) : super(ENTITY_TYPE, position) {
      this._dynamiteRangeOffset = 0;
      this._hasWon = false;
      this.setAbsolutelyNewTeam(Team.PLAYER);
      this.strength = 42;
      this.isWalkable = true;
      this._bonusLife = 0;

      /*
          Player supports all images front, back, left and right in the view
       */
      this.supportMultiViewDirection = true;

      setWalkingSpeed(300);
      /*
          this updates the time of the last action so that the action method
          can be called from 'DynamiteGame'
      */
      updateLastMoveTime();

      this.viewDirection = DEFAULT_VIEW_DIRECTION;
      setViewDirection();
  }

  get hasWon => this._hasWon;
  get bonusLife => this._bonusLife;
  get dynamiteRangeOffset => this._dynamiteRangeOffset;
  set dynamiteRangeOffset(int offset) => this._dynamiteRangeOffset = offset;

  void resetBonusLive(){
    this._bonusLife = 0;
  }

  void setNextMove(Position moveOffset) {
      // go every time from the current position
      nextPosition = position.clone();
      nextPosition.addOffset(moveOffset);
  }

  @override
  bool collision(Entity  otherEntity) {
    if (otherEntity.getType() == "PORTAL" && Entity.monsterCounter == 0){
      _dynamiteRangeOffset = 0;
      _hasWon = true;
    }

    if (otherEntity.getType() == "DYNAMITERANGE") {
      print(otherEntity.getType() + " collect Item");
      this._dynamiteRangeOffset += 1;
    }

    if (otherEntity.getType() == "LIFE") {
      print(otherEntity.getType() + " collect Item");
      this._bonusLife ++;;
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
  Modificator action(List<List<FieldNode>> _gameField, int time) {
    _checkIfAlreadyOverPortal(_gameField);
    return null;
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