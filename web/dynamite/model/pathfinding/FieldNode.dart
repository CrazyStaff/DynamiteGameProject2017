import '../Entity.dart';
import '../Position.dart';
import 'Heap.dart';

/*
    The FieldNode is needed for the path finding
    and also contains all the entities which are
    located on this field
 */
class FieldNode extends IHeapItem<FieldNode>{
  // The distance from the starting FieldNode
  int gCost = 0;
  // The distance from the target FieldNode
  int hCost = 0;

  // The next field used for the path to the target
  FieldNode parent;

  // It is used for heap optimization
  int _heapIndex = 0;

  List<Entity> _allEntities;
  Position _position;

  /*
      Proof if the the field is walkable for this 'entity'
   */
  bool isWalkableFor(Entity entity) {
      for(Entity e in _allEntities) {
        if(!e.isWalkable) {
            return false;
        }
      }
      return true;
  }

  get getEntities => _allEntities;
  get position => _position;
  get getX => _position.getX;
  get getY => _position.getY;

  /*
      Allow compare by positions
   */
  bool operator == (Object other) {
    return (other as FieldNode).getX == this.getX
        && (other as FieldNode).getY == this.getY;
  }

  // Used for algorithm
  int get fCost => this.gCost + this.hCost;

  FieldNode(Position position) {
    this._position = position;
    this._allEntities = new List<Entity>();
  }

  /*
      Compare to the other field node based firstly
      on the fCost then on the hCost
   */
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
