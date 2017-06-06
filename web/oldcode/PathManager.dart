import 'Node.dart';
import 'dart:collection';
import 'GameField.dart';
import 'dart:html' hide Node;
import 'Heap.dart';

class PathManager {
  GameField _gameField;

  PathManager(GameField gameField) {
      this._gameField = gameField;
  }


List<Node> findPath(Node startNode, Node targetNode) {
  int startTime = new DateTime.now().millisecondsSinceEpoch;
  Heap<Node> openSet = new Heap<Node>(_gameField.fieldSize); // notVisitedNodes
  HashSet<Node> closedSet = new HashSet<Node>(); // closedSet
  openSet.add(startNode);

  while(openSet.length > 0) {
      Node currentNode = openSet.removeFirst();
      //currentNode = getLowestFCostNodeFromEvaluatedList(openSet, currentNode);

      closedSet.add(currentNode);

      if(currentNode == targetNode)  {
        // Found the path

        print("Founyd path in ${new DateTime.now().millisecondsSinceEpoch-startTime} ms");
        return buildFinalPath(startNode, targetNode);
      }

      for(Node neighbour in _gameField.getNeighbours(currentNode)) {
          if(!neighbour.isWalkable || closedSet.contains(neighbour)) {
            continue;
          }

          int newMovementCostToNeighbour = currentNode.gCost + getDistance(currentNode, neighbour);
          if(newMovementCostToNeighbour < neighbour.gCost || !openSet.contains(neighbour)) {
            neighbour.gCost = newMovementCostToNeighbour;
            neighbour.hCost = getDistance(neighbour, targetNode);
            neighbour.parent = currentNode;

           /* if(neighbour == targetNode)  {
              return buildFinalPath(startNode, targetNode);
            }*/

            if(!openSet.contains(neighbour)) {
              Element ele = querySelector("#field_${currentNode.yPosition}_${currentNode.xPosition}");
              ele.style.background = "green";
              openSet.add(neighbour);
            }
          }
      }
  }
  querySelector('#output').text = "not found";
}

List<Node> buildFinalPath(Node startNode, Node endNode) {
    List<Node> path = new List<Node>();
    Node currentNode = endNode;

    while(currentNode != startNode) {
      path.add(currentNode);
      currentNode = currentNode.parent;
    }
    return path.reversed.toList();
}

int getDistance(Node fromNode, Node toNode) {
    int xDistance = (fromNode.getXPos - toNode.getXPos).abs();
    int yDistance = (fromNode.getYPos - toNode.getYPos).abs();

    return xDistance + yDistance; // TODO *10?
}

Node getLowestFCostNodeFromEvaluatedList(List<Node> openSet, Node currentNode) {

  return currentNode;
}



}
