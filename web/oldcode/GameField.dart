import 'dart:html' hide Node;
import 'Node.dart';
import 'TerrainType.dart';
import 'dart:async';
import 'Constants.dart';
import 'Keyboard.dart';
import 'PathManager.dart';

class GameField {
  int _width;
  int _height;

  List<Node> _allNodes = new List<Node>();
  Keyboard keyboard;
  PathManager _pathManager;

  int _playerPosition;
  int _newPosition = -1;
  bool _allowMovement = true;

  GameField(int width, int height) {
    _width = width;
    _height = height;

    keyboard = new Keyboard();
  }

  void addNode(Node node) {
      _allNodes.add(node);

      if(node.getTerrain == TerrainType.START_PLAYER) { // TODO auslagern startPosition suchen
        _playerPosition = node.getId;
      }
  }

  void render() {
    for(Node currentNode in _allNodes) {
        Element currentElement = querySelector("#field_${currentNode.yPosition}_${currentNode.xPosition}");

        switch(currentNode.getTerrain) {
          case TerrainType.BLOCK: currentElement.style.background = "grey"; break;
          case TerrainType.EMPTY_FIELD: currentElement.style.background = "white"; break;
          case TerrainType.DESTROYABLE_BLOCK: currentElement.style.background = "red"; break;
          case TerrainType.START_PLAYER: currentElement.style.background = "black"; break;
          case TerrainType.TARGET_PLAYER: currentElement.style.background = "orange"; break;
          default: // TODO log not exist other TerrainType
        }
    }
    _pathManager = new PathManager(this);
    drawPathFromPlayerToTarget();
  }

  void drawPathFromPlayerToTarget() {
    Node playerNode = getPlayerNode();
    Node targetNode = getTargetNode();

   List<Node> shortestPath = _pathManager.findPath(playerNode, targetNode);
    print("DID1");
    _pathManager.findPath(playerNode, new Node(targetNode.getId+1, targetNode.getXPos+1, targetNode.getYPos, targetNode.getTerrain));
    print("DID2");
    _pathManager.findPath(playerNode, new Node(targetNode.getId+1, targetNode.getXPos+1, targetNode.getYPos, targetNode.getTerrain));
    print("DID3");

  if(shortestPath != null) {
    for(Node currentNode in shortestPath) {
      Element pathElement = convertNodeToElement(currentNode);
      pathElement.style.background = "red";
    }
}
  }

  Node getPlayerNode() {
      for(Node currentNode in _allNodes) {
          if(currentNode.getTerrain == TerrainType.START_PLAYER) {
            return currentNode;
          }
      }
      return null;
  }

  Node getTargetNode() {
    for(Node currentNode in _allNodes) {
      if(currentNode.getTerrain == TerrainType.TARGET_PLAYER) {
        return currentNode;
      }
    }
    return null;
  }

  /**
   * @return if player is moved
   */
  bool movePlayer(int newIdNodePlayer, int currentIdNodePlayer) {
    if(isPositionValid(newIdNodePlayer)) {
      if(_allNodes[newIdNodePlayer].getTerrain == TerrainType.EMPTY_FIELD) {
        //querySelector('#output').text = "yes" + _newPosition.toString();

        // Im Array Spielerposition aktualisieren
        _allNodes[newIdNodePlayer].setTerrain = TerrainType.START_PLAYER;
        _allNodes[currentIdNodePlayer].setTerrain = TerrainType.EMPTY_FIELD;

        // Im Spielfeld Spielerposition aktualisieren
        Element newPlayerPosition = convertNodeToElement(_allNodes[newIdNodePlayer]);
        newPlayerPosition.style.background = "black";

        Element oldPlayerPosition = convertNodeToElement(_allNodes[currentIdNodePlayer]);
        oldPlayerPosition.style.background = "white";

        _allowMovement = false;
        new Timer(Constants.MOVEMENT_DELAY, allowMovementOfPlayer);

        _playerPosition = _newPosition;

        return true;
      } else {
        window.requestAnimationFrame(updateGame);
      }
    } else {
      window.requestAnimationFrame(updateGame);
     // querySelector('#output').text = "NOpe: " + _playerPosition.toString() + ":" + _newPosition.toString();
    }
    return false;
  }

  Element convertNodeToElement(Node node) {
      return querySelector("#field_${node.yPosition}_${node.xPosition}");
  }

  void allowMovementOfPlayer() {
    _allowMovement = true;
    window.requestAnimationFrame(updateGame);
  }

  List<Node> getNeighbours(Node node) {
      List<Node> neighbourNodes = new List<Node>();
      if(isTopWalkable(node.getId)) neighbourNodes.add(getNodeAtTop(node.getId));
      if(isRightWalkable(node.getId)) neighbourNodes.add(getNodeAtRight(node.getId));
      if(isBottomWalkable(node.getId)) neighbourNodes.add(getNodeAtBottom(node.getId));
      if(isLeftWalkable(node.getId)) neighbourNodes.add(getNodeAtLeft(node.getId));

      return neighbourNodes;
  }

  bool isTopWalkable(int fromIdPosition) { // TODO eher reachable
    return isPositionValid(fromIdPosition - _width);
  }

  Node getNodeAtTop(int fromIdPosition) {
    return _allNodes[fromIdPosition - _width];
  }

  bool isBottomWalkable(int fromIdPosition) {
    return isPositionValid(fromIdPosition + _width);
  }

  Node getNodeAtBottom(int fromIdPosition) {
    return _allNodes[fromIdPosition + _width];
  }

  bool isRightWalkable(int fromIdPosition) {
    return isPositionValid(fromIdPosition + 1);
  }

  Node getNodeAtRight(int fromIdPosition) {
    return _allNodes[fromIdPosition + 1];
  }

  bool isLeftWalkable(int fromIdPosition) {
    return isPositionValid(fromIdPosition - 1);
  }

  Node getNodeAtLeft(int fromIdPosition) {
    return _allNodes[fromIdPosition - 1];
  }

  void updateGame(e) {
    if (keyboard.isPressed(KeyCode.UP)) {
      _newPosition = _playerPosition - _width;
    } else if(keyboard.isPressed(KeyCode.RIGHT)) {
      _newPosition = _playerPosition + 1;
    } else if(keyboard.isPressed(KeyCode.DOWN)) {
      _newPosition = _playerPosition + _width;
    } else if(keyboard.isPressed(KeyCode.LEFT)) {
      _newPosition = _playerPosition - 1;
    }

    if(_allowMovement) {
      movePlayer(_newPosition, _playerPosition);
    }
  }

  bool isPositionValid(int idNode) {
      if(idNode >= 0 && idNode < _allNodes.length) {
        return true;
      }
      return false;
  }

  get fieldSize => _width*_height;
}
