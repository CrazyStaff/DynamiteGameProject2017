class Position {

  int _x, _y;

  int get getX => _x;
  int get getY => _y;

  Position(this._x, this._y);

  /*
      Subtract the the other position from this position
  */
  Position operator - (Position other) {
    return new Position(
        this.getX - other.getX,
        this.getY - other.getY);
  }

  /*
      Add the other position to this position
   */
  Position operator + (Position other) {
    return new Position(
        this.getX + other.getX,
        this.getY + other.getY);
  }

  /*
      Add the offset to to this position
   */
  void addOffset(Position offset) {
    this._x += offset.getX;
    this._y += offset.getY;
  }

  /*
      Proofs if the other position is different to this position
   */
  bool isPositionDifferentFrom(Position other) {
    return (other.getX != this.getX || other.getY != this.getY ? true : false);
  }

  Position clone() {
    if(this == null) {
      print("FATAL: You cloned a position == null! => return null");
      return null;
    }
    return new Position(this._x, this._y);
  }

  Position abs() => new Position(this._x.abs(), this._y.abs());

  /*
      Proofs if the other position and this position are the same
   */
  bool operator == (Object other) {
          return (other as Position).getX == this.getX &&
                 (other as Position).getY == this.getY;
  }
}