import 'Entity.dart';
import 'GameState.dart';
import 'Modificator.dart';
import 'Player.dart';
import 'Position.dart';
import './blocks/UndestroyableBlock.dart';
import 'Score.dart';
import 'blocks/DestroyableBlock.dart';
import 'blocks/Dynamite.dart';
import 'items/Portal.dart';
import 'monster/Monster.dart';
import 'pathfinding/FieldNode.dart';

class DynamiteGame {

  static final int DYNAMITE_EXPLODE_TIME = 4000;
  static final int FIRE_DURATION = 1000;
  static int DYNAMITE_RADIUS = 1;
  static GameState gameStatus; //0 Verloren, 1 Läuft, 2 Gewonnen
  static int leben = 3;

  int _fieldWidth;
  int _fieldHeight;

  List<List<FieldNode>> _gameField; // List<Entity>
  Player _player;
  Score _score;

  bool _isStopped;
  int pausedGameAtTime;

  bool get isGameStopped => _isStopped;
  double getScorePercentage() => _score.calculateScoreInPercentage();

  void pauseGame() {
    _isStopped = true;
    this.pausedGameAtTime = new DateTime.now().millisecondsSinceEpoch;
  }

  void continueGame() {
    int currentTime = new DateTime.now().millisecondsSinceEpoch;
    int offsetAddTime = currentTime - pausedGameAtTime;

    for (List<FieldNode> allPositions in _gameField) {
      for (FieldNode field in allPositions) {
        for (Entity entity in field.getEntities) {
            entity.updateTimes(offsetAddTime);
        }
      }
    }
    _isStopped = false;
  }

  static GameState getStatus(){
    return gameStatus;
  }


  DynamiteGame(this._fieldWidth, this._fieldHeight) {
    Entity.monsterCounter = 0;
    Entity.destroyableBlockCount = 0;
    gameStatus = GameState.RUNNING;

    _score = new Score();
    _generateEmptyGameField();
  }

  /* Init empty List */
  void _generateEmptyGameField() {
    _gameField = new Iterable.generate(_fieldWidth, (row) {
      return new Iterable.generate(_fieldHeight, (col) => new FieldNode(new Position(row, col))) // TODO richtig rum?
          .toList();
    }).toList();
  }

  List<List<FieldNode>> get getGameField => _gameField;

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

      List<Entity> currentField = _gameField[xPos][yPos].getEntities;

      // clear old field state
      currentField.clear();

      // generate level
      switch (gameField[idElement]) {
        case "E": /* emptyField */
        // not needed
          break;
        case "M": /* monster */
          currentField.add(new Monster(currentPosition));
          break;
        case "B": /* block */
          currentField.add(new UndestroyableBlock(currentPosition));
          break;
        case "D": /* destroyable block */
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
    if(_isStopped) return;

    if (!_player.isAlive){
      gameStatus = GameState.LOOSE;
    }
    for (List<FieldNode> allPositions in _gameField) {
      for (FieldNode field in allPositions) {
        var toRemove = [];
        List<Modificator> toModificate = new List<Modificator>();

        for (Entity entity in field.getEntities) { // TODO iterator statt for each =>  removen und adden nur mit iterator aufrufbar
          if (!entity.isAlive) { // if is not alive remove entity
            Modificator mod = entity.atDestroy(_gameField);
            _score.updateScore(entity);
            if (mod != null) {
              toModificate.add(mod);
            }
            toRemove.add(entity);
            continue;
          }

          if (entity.isAllowedToMove(time)) { // Wenn entity sich bewegen kann => bewege auf nächstes Feld
            Position nextMove = entity.getNextMove(_gameField);

            if(nextMove == null) { // if there is not a next move
                entity.standStillStrategy();
            } else { // if there is a move to another field
              if(_proofIfNextPositionIsValid(nextMove)) {
                List<Entity> nextField = _gameField[nextMove.getX][nextMove.getY].getEntities;

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
        field.getEntities.removeWhere((e) => toRemove.contains(e));
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
        List<Entity> currentField = _gameField[width][height].getEntities;

        //final assignment = field[row][col];
        final pos = "field_${width}_${height}";
        var entityClasses = _getHTMLEntities(currentField);
        html += "<td id='$pos'$entityClasses></td>"; //  class='$assignment'
      }
      html += "</tr>";
    }
    print("------  html ----------");
    html += "</table>";
    return html;
  }

  /*
      Return all Entity classes
   */
  String _getHTMLEntities(List<Entity> allEntities) {
    String htmlEntities = " class='";
    for (Entity entity in allEntities) {
      htmlEntities += "${entity.getType()} ${entity.getExtensionType()} ";
    }
    htmlEntities += "'";
    return htmlEntities;
  }

  String getScoreHTML() {
    String html;
  }

  void placeDynamite() {
    Position pos = _player.position;
    List<Entity> gameField = _gameField[pos.getX][pos.getY].getEntities;
    gameField.add(new Dynamite(pos));
  }

  void initScore(int expMonster, int expDestroyableBlock) {
    _score.initScore(Monster.ENTITY_TYPE, expMonster);
    _score.initScore(DestroyableBlock.ENTITY_TYPE, expDestroyableBlock);

   _score.calculateMaxScore(_gameField);
  }
}