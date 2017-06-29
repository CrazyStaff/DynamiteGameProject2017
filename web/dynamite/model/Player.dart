import 'Entity.dart';
import 'Position.dart';
import 'pathfinding/FieldNode.dart';

class Player extends Entity {
  static final ENTITY_TYPE = "PLAYER";

  bool _hasWon;
  int _dynamiteRangeOffset;

  Player(Position position) : super(ENTITY_TYPE, position) {
      this._dynamiteRangeOffset = 0;
      this._hasWon = false;
      this.team = 1;
      this.strength = 42;
      this.isWalkable = true;

      updateLastMoveTime();
      setWalkingSpeed(300);
  }

  get hasWon => this._hasWon;
  get dynamiteRangeOffset => this._dynamiteRangeOffset;

  void setNextMove(Position moveOffset) {
      nextPosition = position.clone(); // immer von aktueller Position ausgehen!
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
    // TODO: 'gameField' not neccessary?!!
    return nextPosition;
  }

  @override
  void standStillStrategy() {
    // needs to be empty implemented!
    // -> allow player to move directly in the game tact after no input of user
  }
}