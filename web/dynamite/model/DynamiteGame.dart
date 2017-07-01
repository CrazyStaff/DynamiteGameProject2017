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
import 'items/SpeedBuff.dart';
import 'items/DynamiteRange.dart';
import 'monster/Monster.dart';
import 'pathfinding/FieldNode.dart';

class DynamiteGame {
  static int DYNAMITE_EXPLODE_TIME;
  static int FIRE_DURATION;

  GameState _gameStatus;

  String _levelDescription;
  int _dynamiteRadius;

  int _startLevel = 0;
  int _startLife = 3;
  int _life = 3;

  int _fieldWidth;
  int _fieldHeight;

  int _startLevelTime;
  int _maxLevelTime;

  int _maxLvl;
  int _currentLevel;

  List<List<FieldNode>> _gameField;
  Player _player;
  Score _score;

  int _pausedGameAtTime;

  set maxLevelTime(int maxLevelTime) => this._maxLevelTime = maxLevelTime;
  set levelDescription(String description) => this._levelDescription = description;
  set maxLvl(int value) => _maxLvl = value;
  set startLife(int startLife) => this._startLife = startLife;
  set startLevel(int startLevel) => this._startLevel = startLevel;
  get maxLevel => _maxLvl;

  set gameStatus(GameState gameState) => this._gameStatus = gameState;

  get getLife => this._life;
  get currentLevel => this._currentLevel;

  double getScorePercentage() => _score.calculateScoreInPercentage();

  int getLevelLeftTime() {
    if(_maxLevelTime == -1) return _maxLevelTime;
    int leftTime = _maxLevelTime - ((new DateTime.now().millisecondsSinceEpoch - _startLevelTime) / 1000).toInt();

    return (leftTime <= 0 ? 0 : leftTime);
  }

  bool _isLevelTimeOver() {
    return isLevelTimerActive() && getLevelLeftTime() == 0;
  }

  bool isLevelTimerActive() => _maxLevelTime != -1;

  void pauseGame() {
    _gameStatus = GameState.PAUSED;
    this._pausedGameAtTime = new DateTime.now().millisecondsSinceEpoch;
  }

  void increaseLevel() {
    this._currentLevel += 1;

    if (_currentLevel > _maxLvl){
      _gameStatus = GameState.MAX_LEVEL_REACHED;
    }
  }
  void setInitLife() {
    this._life = this._startLife;
  }

  void continueGame() {
    int currentTime = new DateTime.now().millisecondsSinceEpoch;
    int offsetAddTime = currentTime - _pausedGameAtTime;

    _startLevelTime += offsetAddTime;

    for (List<FieldNode> allPositions in _gameField) {
      for (FieldNode field in allPositions) {
        for (Entity entity in field.getEntities) {
            entity.updateTimes(offsetAddTime);
        }
      }
    }
    _gameStatus = GameState.RUNNING;
  }

  GameState getStatus(){
    return _gameStatus;
  }

  DynamiteGame() {
    _currentLevel = 1;
    _maxLvl = 0;
    _pausedGameAtTime = 0;
    _levelDescription = "";
    _dynamiteRadius = 1;
    _fieldWidth = 1;
    _fieldHeight = 1;
    _life = 0;
    _gameStatus = GameState.PAUSED;

    Entity.portalCount = 0;
    Entity.monsterCounter = 0;
    Entity.destroyableBlockCount = 0;

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

  /*
      Decrements the life of the player and switch to
      the new game state LOOSE OR LOST_LIFE
   */
  void _decrementLife() {
    if (_currentLevel >= _startLevel) {
      _life--;
      _dynamiteRadius = 1;
      if (_life < 1) {
        _gameStatus = GameState.LOOSE;
      } else {
        _gameStatus = GameState.LOST_LIFE;
      }
    } else {
      // no decrement of lifes in tutorial levels
      _gameStatus = GameState.LOST_LIFE;
    }
  }

  /*
      Reset the level to a level after the tutorial
   */
  void resetLevel() {
    this._life = _startLife;
    if (_currentLevel > _startLevel) {
      _currentLevel = _startLevel;
    }
  }

  void _resetGame() {
    this._gameStatus = GameState.PAUSED;

    Entity.portalCount = 0;
    Entity.monsterCounter = 0;
    Entity.destroyableBlockCount = 0;
  }

  List<List<FieldNode>> get getGameField => _gameField;

  void initLevel(List gameField, int fieldWidth, int fieldHeight) {
    this._fieldWidth = fieldWidth;
    this._fieldHeight = fieldHeight;

    _generateEmptyGameField();
    _resetGame();

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
        case "S": /* Portal */
          currentField.add(new SpeedBuff(currentPosition));
          break;
        case "R": /* Portal */
          currentField.add(new DynamiteRange(currentPosition));
          break;
        case "P":
        /* starting point of player */
            _player = new Player(currentPosition);
            currentField.add(_player);
          break;
      }
    }

    // set start level time and directly pause the game
    _startLevelTime = new DateTime.now().millisecondsSinceEpoch;
    _pausedGameAtTime = new DateTime.now().millisecondsSinceEpoch;
  }

  GameState moveAllEntities(int time) {
    if (_gameStatus == GameState.RUNNING) {
      if (_player.hasWon) {
        _gameStatus = GameState.WIN;
      }

      for (List<FieldNode> allPositions in _gameField) {
        for (FieldNode field in allPositions) {
          var toRemove = [];
          List<Modificator> toModificate = new List<Modificator>();

          for (Entity entity in field.getEntities) {
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

              if (nextMove == null) { // if there is not a next move
                entity.standStillStrategy();
              } else { // if there is a move to another field
                if (_proofIfNextPositionIsValid(nextMove)) {
                  List<Entity> nextField = _gameField[nextMove.getX][nextMove
                      .getY].getEntities;

                  if (entity.isMovePossible(nextField)) {
                    // First of all remove entity from currentField
                    toRemove.add(entity);
                    entity.moveTo(nextField);
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
      if (!_player.isAlive || _isLevelTimeOver()) {
        _decrementLife();
      }
    }
    return _gameStatus;
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

  void setNextMovePlayer(Position offset) {
    if(_gameStatus == GameState.RUNNING) {
      _player.setNextMove(offset);
    }
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

  Map<String, String> getScoreHTML() {
    Map<String, String> htmlElements = new Map<String, String>();

    switch(_gameStatus) {
      case GameState.PAUSED:
        htmlElements["level_header"] = "Welcome to the tutorial";
        htmlElements["level_announcement"] = "";
        htmlElements["level_result"] = _levelDescription;
        htmlElements["level_accept"] = "Start Tutorial";
        break;
      case GameState.LOOSE:
        htmlElements["level_header"] = "You failed";
        htmlElements["level_announcement"] = "Next Level";
        htmlElements["level_result"] = "1";
        htmlElements["level_accept"] = "Try again";
        break;
      case GameState.MAX_LEVEL_REACHED:
        htmlElements["level_header"] = "Game completed";
        htmlElements["level_announcement"] = "Congratulations! You are a hero!";
        htmlElements["level_result"] = "";
        htmlElements["level_accept"] = "Start again";
        break;
      default:
    }

    return htmlElements;

    /*
        <div id="level"> <!-- shows level success -->
            <div id="level_header">Level completed</div>
            <div id="level_announcement">Good job!</div>
            <div id="level_result">2</div>
            <input id="level_accept" type="submit" value="Next level">
        </div>
     */
   // return htmlElements;
  }

  void setSpawnRateSpeedBuff(int i) {
    SpeedBuff.setSpawnRate(i);
  }

  void setSpeedOffsetSpeedBuff(int i) {
    SpeedBuff.setSpeedOffset(i);
  }

  void setSpawnRateDynamiteRange(int i) {
    DynamiteRange.setSpawnRate(i);
  }

  void placeDynamite() {
    if(_gameStatus == GameState.RUNNING) {
      Position pos = _player.position;
      List<Entity> gameField = _gameField[pos.getX][pos.getY].getEntities;
      gameField.add(new Dynamite(pos, _dynamiteRadius + _player.dynamiteRangeOffset));
    }
  }

  void initScore(int expMonster, int expDestroyableBlock) {
    _score.resetScore();
    _score.initScore(Monster.ENTITY_TYPE, expMonster);
    _score.initScore(DestroyableBlock.ENTITY_TYPE, expDestroyableBlock);

   _score.calculateMaxScore(_gameField);
  }
}