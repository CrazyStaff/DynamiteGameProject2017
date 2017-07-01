/*
    The heap is needed for the path finding optimization
 */
class Heap <T extends IHeapItem<T>> {

  List<T> items;
  int _countItems = 0;

  Heap(int maxHeapSize) {
    items = new List<T>(maxHeapSize);
  }

  get length => _countItems;

  /*
     Add a new item to the heap tree
     and resort the heap tree
   */
  void add(T item) {
    item.heapIndex = _countItems;
    items[_countItems] = item;
    _sortUp(item);
    _countItems++;
  }

  /*
      Remove the first item of the heap tree
      and resort the heap tree
   */
  T removeFirst() {
    T firstItem = items[0];
    _countItems--;
    items[0] = items[_countItems];
    items[0].heapIndex = 0;
    _sortDown(items[0]);
    return firstItem;
  }

  /*
     Updates the position of the item in the heap tree
   */
  void updateItem(T item) {
      _sortUp(item);
  }

  int get countElements => _countItems;

  /*
    Proof if the item is contained in the heap tree
   */
  bool contains(T item) {
    return items[item.getHeapIndex] == item;
  }

  /*
      Sorts the heap tree in the direction of the childs
   */
  void _sortDown(T item) {
    while(true) {
      int childIndexLeft = item.getHeapIndex * 2 + 1;
      int childIndexRight = item.getHeapIndex * 2 + 2;
      int swapIndex = 0;

      if(childIndexLeft < _countItems) {
        swapIndex = childIndexLeft;

        if(childIndexRight < _countItems) {
          if(items[childIndexLeft].compareTo(items[childIndexRight]) < 0 ) {
            swapIndex = childIndexRight;
          }
        }

        if(item.compareTo(items[swapIndex]) < 0) {
          swap(item, items[swapIndex]);
        } else {
          return;
        }
      } else {
        return;
      }
    }
  }

  /*
      Sorts the heap tree in the direction to the parent
   */
  void _sortUp(T item) {
      int parentIndex = ((item.getHeapIndex-1)/2).toInt();

      while(true) {
        T parentItem = items[parentIndex];
        if(item.compareTo(parentItem) > 0) {
            swap(item, parentItem);
        } else {
          break;
        }

        parentIndex = ((item.getHeapIndex-1)/2).toInt();
      }
  }

  void swap(T itemA, T itemB) {
    items[itemA.getHeapIndex] = itemB;
    items[itemB.getHeapIndex] = itemA;
    int itemAIndex = itemA.getHeapIndex;
    itemA.heapIndex = itemB.getHeapIndex;
    itemB.heapIndex = itemAIndex;
  }
}

/*
    This interface is need for the class FieldNode
 */
abstract class IHeapItem<T> extends Comparable<T> {
  int _heapIndex = 0;

  int get getHeapIndex => _heapIndex;
  set heapIndex(int index) => _heapIndex = index;
}

