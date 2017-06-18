import '../Entity.dart';
import '../Position.dart';
import 'Heap.dart';

class FieldNode extends IHeapItem<FieldNode>{
  int gCost = 0; // distance from starting FieldNode
  int hCost = 0;  // distance from targetFieldNode

  FieldNode parent; // für PathManager
  int _heapIndex = 0; // Heap optimazation

  List<Entity> _allEntities;
  Position _position;

  bool isWalkableFor(Entity entity) {
      for(Entity e in _allEntities) {
        if(!e.isWalkable) { // TODO unterscheidung für entities ob Feld begehbar oder nicht
            return false;
        }
      }
      return true;
  }

  get getEntities => _allEntities;
  get position => _position;
  get getX => _position.getX;
  get getY => _position.getY;

  bool operator == (Object other) {
    return (other as FieldNode).getX == this.getX
        && (other as FieldNode).getY == this.getY;
  }

  int get fCost => this.gCost + this.hCost;

  FieldNode(Position position) {
    this._position = position;
    this._allEntities = new List<Entity>();
  }

  @override
  int compareTo(FieldNode other) {
    int compare = fCost.compareTo(other.fCost);
    if(compare == 0) { // fCosts are equal
      compare = hCost.compareTo(other.hCost);
    }
    return -compare;
  }

  get getHeapIndex => _heapIndex;
  set heapIndex(int newHeapIndex) => this._heapIndex = newHeapIndex;
}
