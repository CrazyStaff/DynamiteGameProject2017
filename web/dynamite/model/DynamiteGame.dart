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
import 'monster/Fastelle.dart';
import 'monster/Fridolin.dart';
import 'monster/Maya.dart';
import 'monster/Monster.dart';
import 'dart:math';
import 'pathfinding/FieldNode.dart';

class DynamiteGame {
  static int DYNAMITE_EXPLODE_TIME;
  static int FIRE_DURATION;

  /*
      Global information for all levels
   */
  int _maxLvl;
  int _currentLevel;
  int _startLevel;
  int _startLife = 3;

  /*
      Information for the current level
  */
  String _levelDescription;
  String _dieReason = "";
  GameState _gameStatus;
  Player _player;
  Score _score;
  int _life = 3;
  int _startLevelTime;
  int _maxLevelTime;
  int _dynamiteRadius;
  int _pausedGameAtTime;
  int _maxDynamites;

  /*
      Information about the game field
   */
  List<List<FieldNode>> _gameField;
  int _fieldWidth;
  int _fieldHeight;
  double _maxFieldSize;

  /*
      The list of entities and there stack order in the view
   */
  List<String> _viewStackOrder;

  /*
      Informations for data paths
  */
  String _imagesPath;

  /*
      All setters for the controller
   */
  set maxLevelTime(int maxLevelTime) => this._maxLevelTime = maxLevelTime;
  set levelDescription(String description) => this._levelDescription = description;
  set maxLvl(int maxLvl) => this._maxLvl = maxLvl;
  set startLife(int startLife) => this._startLife = startLife;
  set startLevel(int startLevel) => this._startLevel = startLevel;
  set currentLevel(int currentLevel) => this._currentLevel = currentLevel;
  set gameStatus(GameState gameState) => this._gameStatus = gameState;
  set imagesPath(String imagesPath) => this._imagesPath = imagesPath;
  set viewStackOrder(List<String> viewStackOrder) => this._viewStackOrder = viewStackOrder;
  set maxDynamite(int maxDynamites) => this._maxDynamites = maxDynamites;
  set maxFieldSize(double maxFieldSize) => this._maxFieldSize = maxFieldSize;

  /*
      All getters for the controller
   */
  get maxLevel => _maxLvl;
  get getLife => _life;
  get currentLevel => _currentLevel;
  get startLevel => _startLevel;
  get fieldWidth => _fieldWidth;
  get fieldHeight => _fieldHeight;
  get maxDynamites => _maxDynamites;
  GameState getStatus() =>  _gameStatus;
  bool isLevelTimerActive() => _maxLevelTime != -1;
  List<List<FieldNode>> get getGameField => _gameField;
  double getScorePercentage() => _score.calculateScoreInPercentage();


  DynamiteGame() {
    /*
        Initialize the default values
     */
    _currentLevel = 1;
    _maxLvl = 0;
    _maxDynamites = 0;
    _pausedGameAtTime = 0;
    _levelDescription = "";
    _dynamiteRadius = 1;
    _fieldWidth = 1;
    _fieldHeight = 1;
    _life = 0;
    _startLevel = 0;
    _gameStatus = GameState.PAUSED;

    Entity.portalCount = 0;
    Entity.monsterCounter = 0;
    Entity.destroyableBlockCount = 0;
    Entity.dynamiteCount = 0;

    _score = new Score();
    _generateEmptyGameField();
  }

  /*
      Returns the left time of the current level
      which is displayed in the view
   */
  int getLevelLeftTime() {
    if(_maxLevelTime == -1) return _maxLevelTime;
    int leftTime = _maxLevelTime - ((new DateTime.now().millisecondsSinceEpoch - _startLevelTime) / 1000).toInt();

    return (leftTime <= 0 ? 0 : leftTime);
  }

  /*
      Proofs if the level timer is already over
   */
  bool _isLevelTimeOver() {
    return isLevelTimerActive() && getLevelLeftTime() == 0;
  }

  /*
      Pauses the current level
   */
  void pauseGame() {
    _gameStatus = GameState.PAUSED;
    this._pausedGameAtTime = new DateTime.now().millisecondsSinceEpoch;
  }

  /*
      Increase the level if the max level is not already reached
   */
  void increaseLevel() {
    this._currentLevel += 1;

    if (_currentLevel >= _maxLvl){
      _gameStatus = GameState.MAX_LEVEL_REACHED;
    }
    _dieReason = "";
  }

  /*
      Sets the init life of the current level
   */
  void setInitLife() {
    this._life = this._startLife;
  }

  /*
      Continues the current level
   */
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

  /*
      Initialize the empty game field
  */
  void _generateEmptyGameField() {
    _gameField = new Iterable.generate(_fieldWidth, (row) {
      return new Iterable.generate(_fieldHeight, (col) => new FieldNode(new Position(row, col)))
          .toList();
    }).toList();
  }

  /*
      Decrements the life of the player and switch to
      the new game state 'LOOSE' or 'LOST_LIFE'
   */
  void _decrementLife() {
    _player.dynamiteRangeOffset = 0;
    if (_currentLevel >= _startLevel) {
      _life--;
      if (_life < 1) {
        _gameStatus = GameState.LOOSE;
      } else {
        _gameStatus = GameState.LOST_LIFE;
      }
    } else {
      // There should be no decrement of lifes in the tutorial levels
      _gameStatus = GameState.LOST_LIFE;
    }
    print("Die: " + _dieReason);
    _dieReason = _player.dieReason;
  }

  /*
    Returns the number of remaining dynamites the player can place.
   */
  int dynamitesRemaining() {
    int rem =  maxDynamites - Entity.dynamiteCount;
    return ( rem < 0 ) ? 0 : rem;
  }

  /*
      Reset the level to the level after the tutorial
      so that the player begins at the first real level
   */
  void resetLevel() {
    this._life = _startLife;
    if (_currentLevel > _startLevel) {
      _currentLevel = _startLevel;
    }
  }

  /*
      Reset the game status for the current level
   */
  void _resetGame() {
    this._gameStatus = GameState.PAUSED;
    _dynamiteRadius = 1;
    Entity.portalCount = 0;
    Entity.monsterCounter = 0;
    Entity.destroyableBlockCount = 0;
    Entity.dynamiteCount = 0;
  }

  /*
      Initialize the level and the game field
   */
  void initLevel(List gameField, int fieldWidth, int fieldHeight) {
    this._fieldWidth = fieldWidth;
    this._fieldHeight = fieldHeight;

    _generateEmptyGameField();
    _resetGame();

    int fieldSize = fieldWidth * fieldHeight;

    for (int idElement = 0; idElement < fieldSize; idElement++) {
      // Calculate the position of each block in the game field
      int xPos = idElement % fieldWidth;
      int yPos = (idElement / fieldWidth).toInt();
      Position currentPosition = new Position(xPos, yPos);

      List<Entity> currentField = _gameField[xPos][yPos].getEntities;

      // Clear the old entities of the game field from the last level
      currentField.clear();

      /*
          Generate the level by the given structure of the level config file
       */
      switch (gameField[idElement]) {
        case "E": /* EmptyField */
          // The empty field is not needed by implementation
          break;
        case "M": /* Monster */
          currentField.add(new Fridolin(currentPosition));
          break;
        case "F": /* Monster with rage mode */
          currentField.add(new Fastelle(currentPosition));
          break;
        case "N": /* Monster which drops dynamite */
          currentField.add(new Maya(currentPosition));
          break;
        case "B": /* Block */
          currentField.add(new UndestroyableBlock(currentPosition));
          break;
        case "D": /* DestroyableBlock */
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
        case "P": /* Player */
          _player = new Player(currentPosition);
          currentField.add(_player);
          break;
      }
    }

    /*
        Set the start level time and pause time because the game
        is directly paused after initialization
     */
    _startLevelTime = new DateTime.now().millisecondsSinceEpoch;
    _pausedGameAtTime = new DateTime.now().millisecondsSinceEpoch;
  }

  /*
      Move all the entities if they are
      allowed to move by the given time
   */
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
            /*
                If an enemy isn´t alive anymore
                remove him from the game field
             */
            if (!entity.isAlive) {
              Modificator mod = entity.atDestroy(_gameField);
              _score.updateScore(entity);
              if (mod != null) {
                toModificate.add(mod);
              }
              toRemove.add(entity);
              continue;
            }

            if (entity.isAllowedToMove(time)) {
              Position nextMove = entity.getNextMove(_gameField);

              // If there is not a next move
              if (nextMove == null) {
                entity.standStillStrategy();
              } else {
                // If there is a move to another field

                if (_proofIfNextPositionIsValid(nextMove)) {
                  List<Entity> nextField = _gameField[nextMove.getX][nextMove.getY].getEntities;

                  if (entity.isMovePossible(nextField)) {
                    // First of all remove the entity after moving to the next field
                    toRemove.add(entity);
                    entity.moveTo(nextField);
                  }
                }
              }
            }
            // Call the entity action for special innovations by entity
            Modificator mod = entity.action(_gameField, time);
            if (mod != null) {
              toModificate.add(mod);
            }
          }

          /*
            Modify the game field because it is only allowed
            to change the game field after the for loop iteration
          */
          for (Modificator mod in toModificate) {
            if (mod != null) {
              mod.executeChangesTo(_gameField);
            }
          }
          // Clear the list of all modified field for next loops
          toModificate.clear();

          // Modify the entity list only after the for loop iteration
          field.getEntities.removeWhere((e) => toRemove.contains(e));
        }
      }

      if (!_player.isAlive || _isLevelTimeOver()) {
        _decrementLife();
      }
    }
    return _gameStatus;
  }

  /*
      Proofs if the 'position' is valid on the game field
   */
  bool _proofIfNextPositionIsValid(Position position) {
    if(position == null) return false;

    int fieldWidth = _gameField.length;
    int fieldHeight = _gameField[0].length;
    if(position.getX >= 0 && position.getX < fieldWidth && position.getY >= 0 && position.getY < fieldHeight) {
      return true;
    }
    return false;
  }

  /*
    Store the next move of the player
   */
  void setNextMovePlayer(Position offset) {
    if(_gameStatus == GameState.RUNNING) {
      _player.setNextMove(offset);
    }
  }

  /*
      Get the html table structure of the game field
   */
  String getHTML() {
    String html = "<table>";
    for (int height = 0; height < _fieldHeight; height++) {
      html += "<tr>";
      for (int width = 0; width < _fieldWidth; width++) {
        List<Entity> currentField = _gameField[width][height].getEntities;

        final pos = "field_${width}_${height}";
        var entityAttributes = _getHTMLEntities(currentField);
        html += "<td id='$pos' $entityAttributes></td>";
      }
      html += "</tr>";
    }
    html += "</table>";
    return html;
  }

  /*
      Get all the attributes for each entity
      It is used for showing the pictures
      of enemies in the view
   */
  String _getHTMLEntities(List<Entity> allEntities) {
    var fieldSize = "width:${(_maxFieldSize).toInt()}px; height:${(_maxFieldSize).toInt()}px;";

    String htmlEntities = "style=\"${fieldSize}; background-image: ";

    /* <Entity.type, urls> */
    Map<String, String> attributesForEntity = new Map<String, String>();

    bool addedAttribute = false;
    for (int j=0; j < allEntities.length; j++) {
      Entity entity = allEntities[j];
      List<String> allAttributes = entity.getAllAttributes();

      /*
          Choose image quality
       */
      String imageQuality = "small/";
      if(_maxFieldSize >= 50 )  {
        imageQuality = "middle/";
      }

      /*
          Concats for the entity the resources paths
       */
      String entityAttributes = "";
      for(int i=0; i < allAttributes.length; i++) {
        String attribute = allAttributes[i];
        entityAttributes += "url('$_imagesPath$imageQuality$attribute.png'),";
        addedAttribute = true;
      }
      // Delete last ',' delimiter
      if(entityAttributes.length > 0) {
        entityAttributes = entityAttributes.substring(0, entityAttributes.length - 1);
      }
      attributesForEntity.putIfAbsent(entity.getType(), () => entityAttributes);
    }

    /*
        If there are no attributs for the whole game field
        than nothing have to be added to the html
     */
    if(!addedAttribute || _viewStackOrder == null) {
        var fieldSize = "width:${(_maxFieldSize).toInt()}px; height:${(_maxFieldSize).toInt()}px;";
        return "style=\"${fieldSize};\"";
    }


    Map<String, String> sortedMap = new Map<String, String>();
    for(String entityOrdered in _viewStackOrder) {
      String attributesOfEntity = attributesForEntity[entityOrdered];
      sortedMap.putIfAbsent(entityOrdered, () => attributesOfEntity);
    }

    for(String entityType in sortedMap.keys) {
      String value = sortedMap[entityType];
      if(value != null) {
        htmlEntities += value + ",";
      }
    }

    htmlEntities = htmlEntities.substring(0, htmlEntities.length-1);
    htmlEntities += "\"";
    return htmlEntities;
  }

  String getLevelTypeHTML() {
    return (_currentLevel < _startLevel ? "Tutorial" : "Level");
  }

  String getLevelHTML() {
    return (_currentLevel < _startLevel ? "${_currentLevel}" : "${_currentLevel - _startLevel  + 1}");
  }

  Map<String, String> getScoreHTML() {
    Map<String, String> htmlElements = new Map<String, String>();

    switch(_gameStatus) {
      case GameState.PAUSED:
        if(currentLevel == 1) {
          htmlElements["level_accept"] = "Start Tutorial";
        } else {
          htmlElements["level_accept"] = "Next Level";
        }

         if(_currentLevel < _startLevel) {
          htmlElements["level_header"] = "Welcome to the Tutorial";
        } else {
          htmlElements["level_header"] = "Welcome";
        }

        htmlElements["level_announcement"] = "";
        if (_dieReason == "") {
          htmlElements["level_result"] = _levelDescription;
        }else{
          htmlElements["level_result"] = "Cause of death: " + _dieReason + "<br><br>" + _levelDescription;
          htmlElements["level_accept"] = "Restart Tutorial";
        }
        break;
      case GameState.MAX_LEVEL_REACHED:
        htmlElements["level_header"] = "Game completed";
        htmlElements["level_announcement"] = "Congratulations!<br>You are a hero!";
        htmlElements["level_result"] = "";
        htmlElements["level_accept"] = "Start again";
        break;
      default:
    }

    return htmlElements;
  }

  /*
      Set the spawn rate of the item 'SpeedBuff'
   */
  void setSpawnRateSpeedBuff(int spawnRate) {
    SpeedBuff.setSpawnRate(spawnRate);
  }

  /*
      Set the movement speed of the 'SpeedBuff' item
   */
  void setSpeedOffsetSpeedBuff(int spawnRate) {
    SpeedBuff.setSpeedOffset(spawnRate);
  }

  /*
      Set the spawn rate of the item 'DynamiteRange'
   */
  void setSpawnRateDynamiteRange(int spawnRate) {
    DynamiteRange.setSpawnRate(spawnRate);
  }

  /*
      Place dynamite above the position of the player
   */
  void placeDynamite() {
    if((_gameStatus == GameState.RUNNING) && (dynamitesRemaining() > 0)) {
      Position pos = _player.position;
      List<Entity> gameField = _gameField[pos.getX][pos.getY].getEntities;
      gameField.add(new Dynamite(pos, _dynamiteRadius + _player.dynamiteRangeOffset));
    }
  }

  /*
      Initialize the score for the current level
   */
  void initScore(int expMonster, int expDestroyableBlock) {
    _score.resetScore();
    _score.initScore(Fastelle.ENTITY_TYPE, expMonster);
    _score.initScore(Fridolin.ENTITY_TYPE, expMonster);
    _score.initScore(DestroyableBlock.ENTITY_TYPE, expDestroyableBlock);

   _score.calculateMaxScore(_gameField);
  }
}