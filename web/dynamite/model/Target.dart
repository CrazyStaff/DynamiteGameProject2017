import 'Entity.dart';
import 'Position.dart';

class Target {
  Position lastViewedTargetPosition;
  Entity currentTarget; // TODO: List<Targets> ? oder auf eine Entity konzentrieren

  List<Position> pathToLastViewTargetPosition;

  Target() {
      pathToLastViewTargetPosition = new List<Position>();
  }

  Position nextStepToTarget() {
      if(hasPathToTarget()) {
        return pathToLastViewTargetPosition.removeLast(); // TODO: removeLast? oder removeFirst?
      }
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
}