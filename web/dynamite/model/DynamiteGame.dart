import 'Entity.dart';
import 'Player.dart';
import 'Position.dart';
import './blocks/UndestroyableBlock.dart';

class DynamiteGame {

  int _fieldWidth;
  int _fieldHeight;
  int _level;

  List<List< List<Entity>>> _gameField;
  Player _player;

  bool _isStopped;

  bool get isGameStopped => _isStopped;

  void pauseGame() { _isStopped = true; }


  DynamiteGame(this._fieldWidth, this._fieldHeight) {
    _generateEmptyGameField();
  }

  /* Init empty List */
  void _generateEmptyGameField() {
    _gameField = new Iterable.generate(_fieldWidth, (row) {
      return new Iterable.generate(_fieldHeight, (col) => new List<Entity>()).toList();
    }).toList();
  }

  List<List< List<Entity>>> get getGameField => _gameField;

  // TODO make own class of level -> auslagern des Codes
  void initLevel(List gameField, int fieldWidth, int fieldHeight) {
    this._fieldWidth = fieldWidth;
    this._fieldHeight = fieldHeight;

    int fieldSize = fieldWidth*fieldHeight;

    for (int idElement = 0; idElement < fieldSize; idElement++) {
      // calculate the position of each block in 'gameField'
      int xPos = idElement % fieldWidth;
      int yPos = (idElement / fieldHeight).toInt();
      Position currentPostion = new Position(xPos, yPos);

      List<Entity> currentField = _gameField[yPos][xPos];

      // clear old field state
      currentField.clear();

      // generate level
      switch(gameField[idElement]) {
        case "E": /* emptyField */
          // not needed
          break;
        case "B": /* block */
          currentField.add(new UndestroyableBlock(currentPostion));
          break;
        case "P": /* starting point of player */
          if(_player == null) { // TODO only one player currently?
            _player = new Player(currentPostion);
            currentField.add(_player);
          }
          break;
      }
    }
  }

  void moveAllEntites(int time) {
      for(List<List<Entity>> allPositions in _gameField) {
        for(List<Entity> allFieldEntities in allPositions) {
          var toRemove = [];

          for(Entity entity in allFieldEntities) { // TODO iterator statt for each =>  removen und adden nur mit iterator aufrufbar

              if(!entity.isAlive) { // Wenn nicht lebend => löschen
                toRemove.add(entity);
              } else if(entity.isAllowedToMove(time)) { // Wenn entity sich bewegen kann => bewege auf nächstes Feld
                Position nextMove = entity.getNextMove(_gameField);
                List<Entity> nextField = _gameField[nextMove.getY][nextMove.getX];

                print("isAllowedToMove entity");
                if (entity.isMovePossible(nextField)) {
                  print("move entity");
                  // First of all remove entity from currentField
                  toRemove.add(entity);
                  entity.moveTo(nextField);
                } else {
                  // TODO: nextField move not possible
                }
              }
            }
          // Modify entity list only after iteration
          allFieldEntities.removeWhere((e) => toRemove.contains(e));
        }
      }
  }

  void setNextMovePlayer(int offsetX, int offsetY) {
    _player.setNextMove(offsetX, offsetY);
  }

  String getHTML() {
    String html = "<table>";
    for (int row = 0; row < _gameField.length; row++) {
      html += "<tr>";
      for (int col = 0; col < _gameField[row].length; col++) {
        List<Entity> currentField = _gameField[row][col];

        //final assignment = field[row][col];
        final pos = "field_${row}_${col}";
        final entityClasses = _getHTMLEntities(currentField);
        html += "<td id='$pos'$entityClasses></td>"; //  class='$assignment'
      }
      html += "</tr>";
    }
    print("html");
    html += "</table>";
    return html;
  }

  /*
      Return all Entity classes
   */
  String _getHTMLEntities(List<Entity> allEntities) {
      String htmlEntities = "";
      for(Entity entity in allEntities) {
        htmlEntities += " ${entity.getHTMLClass()}";
      }
      return htmlEntities;
  }
}