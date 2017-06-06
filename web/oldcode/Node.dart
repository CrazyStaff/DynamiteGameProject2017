import 'TerrainType.dart';
import 'Heap.dart';

class Node extends IHeapItem<Node>{

  int _id;
  int _posX;
  int _posY;
  TerrainType _terrainType;

  int gCost = 0; // distance from starting node
  int hCost = 0;  // distance from targetNode

  Node parent; // für PathManager
  int _heapIndex = 0; // Heap optimazation

  Node(int id, int posX, int posY, TerrainType terrainType) {
    this._id = id;
    this._posX = posX;
    this._posY = posY;
    this._terrainType = terrainType;
  }

  bool operator == (Object other) {
    return (other as Node)._posX == this._posX
        && (other as Node)._posY == this._posY;
  }

  int get fCost => this.gCost + this.hCost;

  bool get isWalkable => this._terrainType == TerrainType.EMPTY_FIELD || this._terrainType == TerrainType.TARGET_PLAYER;

  int get xPosition => _posX;
  int get yPosition => _posY;

  TerrainType get getTerrain => _terrainType;
  set setTerrain(TerrainType terrainType) => _terrainType = terrainType;

  get getId => _id;

  get getXPos => _posX;
  get getYPos => _posY;
  @override
  int compareTo(Node other) {
    int compare = fCost.compareTo(other.fCost);
    if(compare == 0) { // fCosts are equal
        compare = hCost.compareTo(other.hCost);
    }
    return -compare;
  }

  get getHeapIndex => _heapIndex;
  set heapIndex(int newHeapIndex) => this._heapIndex = newHeapIndex;
}
