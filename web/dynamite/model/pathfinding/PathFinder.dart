
import '../Entity.dart';
import '../Movement.dart';
import '../Position.dart';
import 'FieldNode.dart';
import 'dart:collection';
import 'Heap.dart';

/*
    The path finder finds the fastest way from
    an origin position to a target position
 */
class PathFinder {

  /*
      Finds the path from the origin entity with the position 'startFieldNode'
      to the target entity with the position 'targetFieldNode'
   */
  static List<Position> findPath(List<List< FieldNode >> gameField, Entity originEntity, FieldNode startFieldNode, FieldNode targetFieldNode) {
    int startTime = new DateTime.now().millisecondsSinceEpoch;

    // Stores the not visited field nodes
    Heap<FieldNode> openSet = new Heap<FieldNode>(1000);
    HashSet<FieldNode> closedSet = new HashSet<FieldNode>();
    openSet.add(startFieldNode);

    while(openSet.length > 0) {
      FieldNode currentFieldNode = openSet.removeFirst();
      closedSet.add(currentFieldNode);

      if(currentFieldNode == targetFieldNode)  {
        // Found the path to the target
        return _buildFinalPath(startFieldNode, targetFieldNode);
      }

      for(FieldNode neighbour in _getNeighbours(currentFieldNode, gameField)) {
        if(!neighbour.isWalkableFor(originEntity) || closedSet.contains(neighbour)) {
          continue;
        }

        int newMovementCostToNeighbour = currentFieldNode.gCost + _getDistance(currentFieldNode, neighbour);
        if(newMovementCostToNeighbour < neighbour.gCost || !openSet.contains(neighbour)) {
          neighbour.gCost = newMovementCostToNeighbour;
          neighbour.hCost = _getDistance(neighbour, targetFieldNode);
          neighbour.parent = currentFieldNode;

          if(!openSet.contains(neighbour)) {
            openSet.add(neighbour);
          }
        }
      }
    }
    // couldn´t find a path to the target
    return null;
  }

  /*
      Build the final path as a list of positions from a start field to the end field
   */
  static List<Position> _buildFinalPath(FieldNode startFieldNode, FieldNode endFieldNode) {
    List<Position> path = new List<Position>();
    FieldNode currentFieldNode = endFieldNode;

    while(currentFieldNode != startFieldNode) {
      path.add(currentFieldNode.position);
      currentFieldNode = currentFieldNode.parent;
    }
    return path.reversed.toList();
  }

  /*
      Calculate the distance between the start field and the end field
   */
  static int _getDistance(FieldNode fromFieldNode, FieldNode toFieldNode) {
    int xDistance = (fromFieldNode.getX - toFieldNode.getX).abs();
    int yDistance = (fromFieldNode.getY - toFieldNode.getY).abs();

    return xDistance + yDistance;
  }

  /*
      Get all the direct vertical and horizontal neighbours of the field node 'originFieldNode'
   */
  static List<FieldNode> _getNeighbours(FieldNode originFieldNode, List<List< FieldNode >> gameField) {
    Position origin = originFieldNode.position;

    List< FieldNode > allNeighbours = new List<FieldNode>();
    /*
       Only proof the horizontal and vertical neighbours
       Use Movement.CORNERS_INCLUDED to accept also diagonal fields for movement
    */
    for(Position pos in Movement.CORNERS_EXCLUDED) {
        Position neighbourPos = origin + pos;
        if(Movement.isMovePossible(neighbourPos, gameField)) {
          FieldNode fieldNode = gameField[neighbourPos.getX][neighbourPos.getY];
          allNeighbours.add(fieldNode);
        }
    }
    return allNeighbours;
  }
}