class Heap <T extends IHeapItem<T>> {

  List<T> items;
  int _countItems = 0;

  Heap(int maxHeapSize) {
    items = new List<T>(maxHeapSize);
  }

  get length => _countItems;

  void add(T item) {
    item.heapIndex = _countItems;
    items[_countItems] = item;
    sortUp(item);
    _countItems++;
  }

  T removeFirst() { // TODO 0 vorhanden?
    T firstItem = items[0];
    _countItems--;
    items[0] = items[_countItems];
    items[0].heapIndex = 0;
    sortDown(items[0]);
    return firstItem;
  }

  void updateItem(T item) {
      sortUp(item);
  }

  int get countElements => _countItems;


  bool contains(T item) { // TODO equals statt == ????
    return items[item.getHeapIndex] == item;
  }

  void sortDown(T item) {
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

  void sortUp(T item) {
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

  @override
  int compareTo(T other) {

  }
}

abstract class IHeapItem<T> extends Comparable<T> {
  int _heapIndex = 0;

  int get getHeapIndex => _heapIndex;
  set heapIndex(int index) => _heapIndex = index;
}

