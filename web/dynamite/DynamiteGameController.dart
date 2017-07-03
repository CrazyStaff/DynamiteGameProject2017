import 'DynamiteView.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'model/DynamiteGame.dart';
import 'model/GameState.dart';
import 'model/Movement.dart';

const configFile = "data/config/config.json";
const configLevel = "data/level/level";

class DynamiteGameController {

  DynamiteGame game;
  final view = new DynamiteView();

  Timer _gameTrigger;
  Duration _gameSpeed;

  DynamiteGameController()  {
    game = new DynamiteGame();

   // load the files from the server
    Future.wait([
      _loadConfigs(),
      _loadLevel()
    ]).then(_initGameListeners);
  }

  /*
     Initialize all the game listeners
     needs to called only once
   */
  void _initGameListeners(List<bool> result) {
    for (bool r in result) {
      if (r == false) {
        // some resources could'nt load properly
        return;
      }
    }
    view.generateField(game);
    // New game is started by user
    view.startButton.onClick.listen((_) {
      switch (view.startButton.getAttribute("class")) {
        case "init":
          _startGame();
          break;
        case "running":
          _pauseGame();
          break;
        case "paused":
          if(!view.isOverviewShown()) {
            _continueGame();
          }
          break;
      }
      view.update(game.getHTML());
    });

    // move player
    window.onKeyDown.listen((KeyboardEvent ev) {
      switch (ev.keyCode) {
        case KeyCode.LEFT:
          left();
          break;
        case KeyCode.RIGHT:
          right();
          break;
        case KeyCode.UP:
          up();
          break;
        case KeyCode.DOWN:
          down();
          break;
        case KeyCode.SPACE:
          placeDynamite();
          break;
      }
    });

      // listen on level overviews next button
      view.overviewAccept.onClick.listen((_) => _finishedOverview());

      // listen on smartphone arrows
      view.arrowUp.onClick.listen((_) => up());
      view.arrowRight.onClick.listen((_) => right());
      view.arrowDown.onClick.listen((_) => down());
      view.arrowLeft.onClick.listen((_) => left());
      view.arrowDynamite.onClick.listen((_) => placeDynamite());
  }

  void _startGame() {
    view.startButton.setAttribute("value", "❚❚");
    view.startButton.setAttribute("class", "running");
    game.gameStatus = GameState.RUNNING;
    _gameTrigger = new Timer.periodic(_gameSpeed, (_) => _moveEntities());
  }

  void _pauseGame() {
    view.startButton.setAttribute("value", "▶");
    view.startButton.setAttribute("class", "paused");
    if(_gameTrigger != null) {
      _gameTrigger.cancel();
    }
    game.pauseGame();
  }

  void _continueGame() {
      game.continueGame();
      _gameTrigger = new Timer.periodic(_gameSpeed, (_) => _moveEntities());

      view.startButton.setAttribute("value", "❚❚");
      view.startButton.setAttribute("class", "running");
  }

  /*
      Load all game configs from server
   */
  Future<bool> _loadConfigs() async {
    HttpRequest.getString(configFile).then((json) {
      final configs = JSON.decode(json);
      game.maxLvl = configs["maxLvl"];
      _gameSpeed = new Duration(milliseconds: configs["gameSpeed"]);
      game.startLevel = configs["startLvl"];
      game.startLife = configs["startLife"];
      DynamiteGame.DYNAMITE_EXPLODE_TIME = configs["dynamiteExplosionTime"];
      DynamiteGame.FIRE_DURATION = configs["fireDuration"];
      game.setInitLife();
      return true;
    }).catchError((error) => {
      // catch the error
    });
  }

  /*
      Load the specific level which is declared as the 'currentLevel' in DynamiteGame ('game')
   */
  Future<bool> _loadLevel() async {
    HttpRequest.getString(configLevel + game.currentLevel.toString() + ".json").then((json) {
      print("Lvl geladen. ${game.currentLevel}");
      Map parsedMap = JSON.decode(json);

      int fieldWidth = int.parse(parsedMap["level"]["field_width"]);
      int fieldHeight = int.parse(parsedMap["level"]["field_height"]);

      List blocks = parsedMap["level"]["blocks"];
      game.initLevel(blocks, fieldWidth, fieldHeight);

      game.levelDescription = parsedMap["description"];
      game.maxLevelTime = parsedMap["maxLevelTime"];

      if(!_proofIfEXPIsSetInLevelConfig(parsedMap)) {
        throw new Exception("Level ${game.currentLevel} should have an EXP section");
      }
      game.setSpawnRateSpeedBuff(parsedMap["speedBuffSpawnRate"]);
      game.setSpeedOffsetSpeedBuff(parsedMap["speedBuffAddSpeed"]);
      game.setSpawnRateDynamiteRange(parsedMap["dynamiteRangeSpawnRate"]);

      int expMonster = int.parse(parsedMap["exp_monster"]);
      int expDestroyableBlock = int.parse(parsedMap["exp_destroyable_block"]);
      game.initScore(expMonster, expDestroyableBlock);

      _updateView();
      _showLevelOverview();
    });
  }

  /*
      Proof if the exp section is set in the level config file
   */
  bool _proofIfEXPIsSetInLevelConfig(Map parsedMap) {
    if(!parsedMap.containsKey("exp_monster") &&
        !parsedMap.containsKey("exp_destroyable_block")) {
      return false;
    }
    return true;
  }

  /*
      Update the view that the game state is refreshed in the view
   */
  _updateView() {
    view.update(game.getHTML());
    view.updateScore(game.getScorePercentage());
    view.updateLevelType(game.getLevelTypeHTML());
    view.updateLevel(game.getLevelHTML());
    view.updateLife(game.getLife);
    view.updateLeftTime(game.getLevelLeftTime());
    view.setLeftTimeVisibility(game.isLevelTimerActive());
  }

  /*
      Move all entities of the game field
   */
  void _moveEntities() {
      GameState currentGameState = game.moveAllEntities(new DateTime.now().millisecondsSinceEpoch);
      switch(currentGameState) {
        case GameState.RUNNING:
          _updateView();
          break;
        case GameState.PAUSED: break;
        default:
          // Level is over
          print("Game state changed");
          _gameTrigger.cancel();
          _chooseNextLevel();
    }
  }

  void _chooseNextLevel() {
    switch(game.getStatus()) {
      case GameState.WIN:
        print("next level");
        nextLvl();
        break;
      case GameState.LOOSE:
        print("retry level");
        resetLevel();
        break;
      case GameState.LOST_LIFE:
        print("lost life");
        retry();
        break;
      case GameState.MAX_LEVEL_REACHED:
        print("max level reached");
        loadWin();
        return;
      default:
        print("FO: default");
    }
  }

  /*
      Show the overview for describing the level purpose
   */
  void _showLevelOverview() {
    _pauseGame();
    view.showLevelOverview(game.getScoreHTML());
  }

  /*
      Hide the overview that describes the level purpose
   */
  void _finishedOverview() {
    print("finished Overview");
    view.hideLevelOverview();
    _continueGame();
  }

  /*
     Set the game state to the same level to try this level again
   */
  void retry(){
    game.gameStatus = GameState.RUNNING;
    Future.wait([_loadLevel()
    ]).then((b) => view.generateField(game));
  }

  /*
      Set the game state to the beginning (first level)
   */
  void resetLevel(){
    game.gameStatus = GameState.RUNNING;
    game.resetLevel();
    Future.wait([_loadLevel()
    ]).then((b) => view.generateField(game));
  }

  /*
      Change the game state to the next level
   */
  void nextLvl() {
    game.gameStatus = GameState.RUNNING;
    game.increaseLevel();
      Future.wait([_loadLevel()
      ]).then((b) => view.generateField(game));
  }

  void loadWin() {
    game.gameStatus = GameState.RUNNING;
    game.setEinLevel();
    Future.wait([_loadLevel()
    ]).then((b) => view.generateField(game));
  }

  void up() {
    game.setNextMovePlayer(Movement.UP);
  }

  void down() {
    game.setNextMovePlayer(Movement.DOWN);
  }

  void left() {
    game.setNextMovePlayer(Movement.LEFT);
  }

  void right() {
    game.setNextMovePlayer(Movement.RIGHT);
  }

  void placeDynamite() {
    game.placeDynamite();
  }

}