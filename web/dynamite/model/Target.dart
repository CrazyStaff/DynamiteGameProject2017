import 'Entity.dart';
import 'Position.dart';
import 'pathfinding/FieldNode.dart';
import 'pathfinding/PathFinder.dart';

class Target {
  Position lastViewedTargetPosition;
  Entity currentTarget; // TODO: List<Targets> ? oder auf eine Entity konzentrieren

  List<Position> pathToLastViewTargetPosition;

  Target() {
      pathToLastViewTargetPosition = new List<Position>();
  }

  void setTarget(Entity target) {
    if(target == null) return;

    currentTarget = target;
    lastViewedTargetPosition = currentTarget.position;
  }

  Position nextStepToTarget() {
      if(hasPathToTarget()) {
        return pathToLastViewTargetPosition.removeAt(0);
      }
      resetTarget();
      return null;
  }

  bool hasPathToTarget() {
    if(pathToLastViewTargetPosition.isEmpty) {
      return false;
    }
    return true;
  }

  bool hasTarget() {
    return currentTarget != null;
  }

  void resetTarget() {
    currentTarget = null;
    lastViewedTargetPosition = null;
    pathToLastViewTargetPosition.clear();
  }

  void setPathToTargetFrom(Entity originEntity, List<List< FieldNode >> gameField) {
      if(!hasTarget()) {
        print("Target:setPathToTarget - You need a target!");
        return;
      }

      FieldNode originFieldNode = gameField[originEntity.position.getX][originEntity.position.getY];
      FieldNode destinationFieldNode = gameField[lastViewedTargetPosition.getX][lastViewedTargetPosition.getY];
      List<Position> pathToTarget = PathFinder.findPath(gameField, originEntity, originFieldNode, destinationFieldNode);

      if(pathToTarget != null) {
        this.pathToLastViewTargetPosition = pathToTarget;
      }
    }
}