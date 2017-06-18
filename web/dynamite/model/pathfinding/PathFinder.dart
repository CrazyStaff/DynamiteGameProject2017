
import '../Entity.dart';
import '../Movement.dart';
import '../Position.dart';
import 'FieldNode.dart';
import 'dart:collection';
import 'Heap.dart';

class PathFinder {

  static List<Position> findPath(List<List< FieldNode >> gameField, Entity originEntity, FieldNode startFieldNode, FieldNode targetFieldNode) {
    int startTime = new DateTime.now().millisecondsSinceEpoch;
    Heap<FieldNode> openSet = new Heap<FieldNode>(1000); // notVisitedFieldNodes
    HashSet<FieldNode> closedSet = new HashSet<FieldNode>(); // closedSet
    openSet.add(startFieldNode);

    while(openSet.length > 0) {
      FieldNode currentFieldNode = openSet.removeFirst();
      //currentFieldNode = getLowestFCostFieldNodeFromEvaluatedList(openSet, currentFieldNode);

      closedSet.add(currentFieldNode);

      if(currentFieldNode == targetFieldNode)  {
        // Found the path
        print("Found path in ${new DateTime.now().millisecondsSinceEpoch-startTime} ms");
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

          /* if(neighbour == targetFieldNode)  {
              return buildFinalPath(startFieldNode, targetFieldNode);
            }*/

          if(!openSet.contains(neighbour)) {
            //Element ele = querySelector("#field_${currentFieldNode.getY}_${currentFieldNode.getX}");
            //ele.style.background = "green";
            openSet.add(neighbour);
          }
        }
      }
    }
    // PATH NOT FOUND
  }

  static List<Position> _buildFinalPath(FieldNode startFieldNode, FieldNode endFieldNode) {
    List<Position> path = new List<Position>();
    FieldNode currentFieldNode = endFieldNode;

    while(currentFieldNode != startFieldNode) {
      path.add(currentFieldNode.position);
      currentFieldNode = currentFieldNode.parent;
    }
    return path.reversed.toList();
  }

  static int _getDistance(FieldNode fromFieldNode, FieldNode toFieldNode) {
    int xDistance = (fromFieldNode.getX - toFieldNode.getX).abs();
    int yDistance = (fromFieldNode.getY - toFieldNode.getY).abs();

    return xDistance + yDistance; // TODO *10?
  }

  static List<FieldNode> _getNeighbours(FieldNode originFieldNode, List<List< FieldNode >> gameField) {
    Position origin = originFieldNode.position;

    List< FieldNode > allNeighbours = new List<FieldNode>();
    for(Position pos in Movement.CORNERS_EXCLUDED) {
        Position neighbourPos = origin + pos;
        if(Movement.isMovePossible(neighbourPos, gameField)) {
          FieldNode fieldNode = gameField[neighbourPos.getX][neighbourPos.getY];
          allNeighbours.add(fieldNode);
        }
    }
    return allNeighbours;
  }

  static FieldNode _getLowestFCostFieldNodeFromEvaluatedList(List<FieldNode> openSet, FieldNode currentFieldNode) {
    return currentFieldNode;
  }
}