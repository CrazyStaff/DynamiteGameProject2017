import 'Entity.dart';
import 'Modificator.dart';
import 'Player.dart';
import 'Position.dart';
import './blocks/UndestroyableBlock.dart';
import 'blocks/DestroyableBlock.dart';
import 'blocks/Dynamite.dart';
import 'items/Portal.dart';
import 'monster/Monster.dart';

class DynamiteGame {

  static final int DYNAMITE_EXPLODE_TIME = 4000;
  static final int FIRE_DURATION = 1000;
  static final int DYNAMITE_RADIUS = 2;

  int _fieldWidth;
  int _fieldHeight;
  int _level;

  List<List<List<Entity>>> _gameField;
  Player _player;

  bool _isStopped;

  bool get isGameStopped => _isStopped;

  void pauseGame() {
    _isStopped = true;
  }


  DynamiteGame(this._fieldWidth, this._fieldHeight) {
    _generateEmptyGameField();
  }

  /* Init empty List */
  void _generateEmptyGameField() {
    _gameField = new Iterable.generate(_fieldWidth, (row) {
      return new Iterable.generate(_fieldHeight, (col) => new List<Entity>())
          .toList();
    }).toList();
  }

  List<List<List<Entity>>> get getGameField => _gameField;

  // TODO make own class of level -> auslagern des Codes
  void initLevel(List gameField, int fieldWidth, int fieldHeight) {
    this._fieldWidth = fieldWidth;
    this._fieldHeight = fieldHeight;

    int fieldSize = fieldWidth * fieldHeight;

    for (int idElement = 0; idElement < fieldSize; idElement++) {
      // calculate the position of each block in 'gameField'
      int xPos = idElement % fieldWidth;
      int yPos = (idElement / fieldWidth).toInt();
      Position currentPosition = new Position(xPos, yPos);

      List<Entity> currentField = _gameField[xPos][yPos];

      print("$xPos and $yPos");

      // clear old field state
      currentField.clear();

      // generate level
      switch (gameField[idElement]) {
        case "E":
        /* emptyField */
        // not needed
          break;
        case "M":
        /* monster */
          currentField.add(new Monster(currentPosition));
          break;
        case "B":
        /* block */
          currentField.add(new UndestroyableBlock(currentPosition));
          break;
        case "D":
          currentField.add(new DestroyableBlock(currentPosition));
          break;
        case "Z": /* Portal */
          currentField.add(new Portal(currentPosition));
          break;
        case "P":
        /* starting point of player */
          if (_player == null) { // TODO only one player currently?
            _player = new Player(currentPosition);
            currentField.add(_player);
          }
          break;
      }
    }
  }

  void moveAllEntites(int time) {
    for (List<List<Entity>> allPositions in _gameField) {
      for (List<Entity> allFieldEntities in allPositions) {
        var toRemove = [];
        List<Modificator> toModificate = new List<Modificator>();

        for (Entity entity in allFieldEntities) { // TODO iterator statt for each =>  removen und adden nur mit iterator aufrufbar
          if (!entity.isAlive) { // Wenn nicht lebend => löschen
            Modificator mod = entity.atDestroy(_gameField);
            if (mod != null) {
              toModificate.add(mod);
            }
            toRemove.add(entity); // Lösche entity hier
            continue;
          }

          if (entity.isAllowedToMove(time)) { // Wenn entity sich bewegen kann => bewege auf nächstes Feld
            Position nextMove = entity.getNextMove(_gameField);

            if(nextMove == null) { // if there is not a next move
                entity.standStillStrategy();
            } else { // if there is a move to another field
              if(_proofIfNextPositionIsValid(nextMove)) {
                List<Entity> nextField = _gameField[nextMove.getX][nextMove
                    .getY];

                if (entity.isMovePossible(nextField)) {
                  // First of all remove entity from currentField
                  toRemove.add(entity);
                  entity.moveTo(nextField);
                } else {
                  // TODO: nextField move not possible
                }
              }
            }
          }
          // auch während des Bewegens darf die Action ausgeführt werden?! =>  sonst else
          entity.action(_gameField, time);
        }

        // Modify entity list only after iteration
        for (Modificator mod in toModificate) {
          if (mod != null) {
            mod.executeChangesTo(_gameField);
          }
        }
        toModificate.clear();

        // Modify entity list only after iteration
        allFieldEntities.removeWhere((e) => toRemove.contains(e));
      }
    }
  }

  bool _proofIfNextPositionIsValid(Position position) {
    if(position == null) return false;

    int fieldWidth = _gameField.length;
    int fieldHeight = _gameField[0].length;
    if(position.getX >= 0 && position.getX < fieldWidth && position.getY >= 0 && position.getY < fieldHeight) {
      return true;
    }
    return false;
  }

  void setNextMovePlayer(int offsetX, int offsetY) {
    _player.setNextMove(offsetX, offsetY);
  }

  String getHTML() {
    String html = "<table>";
    for (int height = 0; height < _fieldHeight; height++) {
      html += "<tr>";
      for (int width = 0; width < _fieldWidth; width++) {
        List<Entity> currentField = _gameField[width][height];

        //final assignment = field[row][col];
        final pos = "field_${width}_${height}";
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
    for (Entity entity in allEntities) {
      htmlEntities += " ${entity.getHTMLClass()}";
    }
    return htmlEntities;
  }

  void placeDynamite() {
    Position pos = _player.position;
    List<Entity> gameField = _gameField[pos.getX][pos.getY];
    gameField.add(new Dynamite(pos));
  }
}