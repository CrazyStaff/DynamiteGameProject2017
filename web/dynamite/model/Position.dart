class Position {
  int _x, _y;

  int get getX => _x;
  int get getY => _y;

  Position(this._x, this._y);

  void addOffset(int offsetX, int offsetY) {
    this._x += offsetX;
    this._y += offsetY;
  }

  bool isPositionDifferentFrom(Position other) {
    (other.getX != this.getX || other.getY != this.getY ? true : false);
  }

  Position clone() {
    return new Position(this._x, this._y);
  }

  String toString() {
    return "$_x und $_y";
  }
}