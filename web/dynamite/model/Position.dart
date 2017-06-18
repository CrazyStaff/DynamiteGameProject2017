class Position {

  int _x, _y;

  int get getX => _x;
  int get getY => _y;

  Position(this._x, this._y);

  /* Returns the position of one position minus another position */
  Position operator - (Position other) {
    return new Position(
        this.getX - other.getX,
        this.getY - other.getY);
  }

  Position operator + (Position other) {
    return new Position(
        this.getX + other.getX,
        this.getY + other.getY);
  }

  void addOffset(int offsetX, int offsetY) {
    this._x += offsetX;
    this._y += offsetY;
  }

  bool isPositionDifferentFrom(Position other) {
    (other.getX != this.getX || other.getY != this.getY ? true : false);
  }

  Position clone() {
    if(this == null) {
      print("FATAL: You cloned a position == null! => return null");
      return null;
    }
    return new Position(this._x, this._y);
  }

  String toString() {
    return "$_x und $_y";
  }

  Position abs() => new Position(this._x.abs(), this._y.abs());

  bool operator == (Object other) {
          return (other as Position).getX == this.getX &&
                 (other as Position).getY == this.getY;
  }

}