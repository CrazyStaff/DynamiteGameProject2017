import '../Modificator.dart';
import '../Position.dart';
import '../pathfinding/FieldNode.dart';
import 'Monster.dart';

/*
   This type of monster goes in a rage mode when it detects an enemy
   During the rage mode the enemy is moving significantly faster
 */
class Fastelle extends Monster {

  // The entity type identifies the monster as fastelle
  static const ENTITY_TYPE = "FASTELLE";

  /*
      Increased movement speed during rage mode
   */
  int rageMovementSpeed = 700;

  /*
      Controls if the monster is currently in the rage mode
   */
  bool isInRageMode;

  Fastelle(Position position) : super(ENTITY_TYPE, position) {
    isInRageMode = false;

    /*
      this updates the time of the last action so that the action method
      can be called from 'DynamiteGame'
    */
    updateLastActionTime();
  }

  /*
      Set extra speed during the rage mode when the monster
      detects an enemy in his view range
   */
  @override
  Modificator action(List<List<FieldNode>> _gameField, int time) {
    if(!target.hasPathToTarget() && isInRageMode) {
      isInRageMode = false;
      setWalkingSpeed(getWalkingSpeed() + rageMovementSpeed);
    } else if(target.hasPathToTarget() && !isInRageMode) {
      isInRageMode = true;
      setWalkingSpeed(getWalkingSpeed() - rageMovementSpeed);
    }
    return null;
  }

  @override
  int getViewOrder() {
    return 50;
  }
}