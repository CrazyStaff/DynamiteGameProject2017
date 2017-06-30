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
   /*view.generateField(game);*/

   // load the files from the server
    Future.wait([
      _loadConfigs(),
      _loadLevel()
    ]).then(_initGame);
  }

  void _initGame(List<bool> result) {
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
          view.startButton.setAttribute("value", "❚❚");
          view.startButton.setAttribute("class", "running");
          game.gameStatus = GameState.RUNNING;
          _gameTrigger = new Timer.periodic(_gameSpeed, (_) => _moveEntities());
          break;
        case "running":
          view.startButton.setAttribute("value", "▶");
          view.startButton.setAttribute("class", "paused");
          _gameTrigger.cancel();
         pauseGame();
          break;
        case "paused":
          view.startButton.setAttribute("value", "❚❚");
          view.startButton.setAttribute("class", "running");
          continueGame();
          _gameTrigger = new Timer.periodic(_gameSpeed, (_) => _moveEntities());
          break;
      }

      // game.start(); // TODO?? !!!!!!!!!!!!!!!!!
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

      // listen on smartphone arrows
      view.arrowUp.onClick.listen((_) => up());
      view.arrowRight.onClick.listen((_) => right());
      view.arrowDown.onClick.listen((_) => down());
      view.arrowLeft.onClick.listen((_) => left());
      view.arrowDynamite.onClick.listen((_) => placeDynamite());
     // view.tooltip.innerHtml = "";
  }

  /*
      Load all game configs from server
   */
  Future<bool> _loadConfigs() async {
    HttpRequest.getString(configFile).then((json) {
      final configs = JSON.decode(json);
      game.maxLvl = configs["maxLvl"];
      _gameSpeed = new Duration(milliseconds: configs["gameSpeed"]);
      game.startLvl = configs["startLvl"];
      game.startLife = configs["startLeben"];
      game.setInitLife();
      return true;
    }).catchError((error) => {
      // return false; // TODO return false
    });
  }

  /*
      Load the specific level which is declared as the 'currentLevel' in DynamiteGame ('game')
   */
  Future<bool> _loadLevel() async {
    HttpRequest.getString(configLevel + game.currentLevel.toString() + ".json").then((json) {
      Map parsedMap = JSON.decode(json);

      int fieldWidth = int.parse(parsedMap["level"]["field_width"]);
      int fieldHeight = int.parse(parsedMap["level"]["field_height"]);
      List blocks = parsedMap["level"]["blocks"];
      game.levelDescription = parsedMap["description"];

      print("Lvl geladen. ${game.currentLevel}");
      game.initLevel(blocks, fieldWidth, fieldHeight);

      view.update(game.getHTML());

      if(!_proofIfEXPIsSetInLevelConfig(parsedMap)) {
        throw new Exception("Level ${game.currentLevel} should have an EXP section");
      }
      game.setSpawnRateSpeedBuff(parsedMap["speedBuffSpawnRate"]);
      game.setSpeedOffsetSpeedBuff(parsedMap["speedBuffAddSpeed"]);
      game.setSpawnRateDynamiteRange(parsedMap["dynamiteRangeSpawnRate"]);
      int expMonster = int.parse(parsedMap["exp_monster"]);
      int expDestroyableBlock = int.parse(parsedMap["exp_destroyable_block"]);

      game.initScore(expMonster, expDestroyableBlock);
      view.updateScore(game.getScorePercentage());
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
      Move all entities of the game field
   */
  void _moveEntities() {
      GameState currentGameState = game.moveAllEntites(new DateTime.now().millisecondsSinceEpoch);
      switch(currentGameState) {
        case GameState.RUNNING:
          view.update(game.getHTML());
          view.updateScore(game.getScorePercentage());
          break;
        case GameState.PAUSED: break;
        default:
          _showLevelOverview();
    }
  }

  /*
    Show the overview for describing the level purpose
   */
  void _showLevelOverview() {
    _gameTrigger.cancel();
    view.showLevelOverview(game.getScoreHTML());
    view.overviewAccept.onClick.listen((_) => _finishedOverview()); // listen on nextButton
  }

  /*
    Hide the overview that describes the level purpose
   */
  void _finishedOverview() {
    view.hideLevelOverview();

    switch(game.getStatus()) {
      case GameState.WIN:
        nextLvl();
        break;
      case GameState.LOOSE:
        retry();
        break;
      case GameState.LOST_LIFE:
        retry();
        break;
      case GameState.MAX_LEVEL_REACHED:
        retry();
        break;
      default:
    }
    _gameTrigger = new Timer.periodic(_gameSpeed, (_) => _moveEntities());
  }

  /*
     Set the game state to the beginning (first level)
   */
  void retry(){
    game.gameStatus = GameState.RUNNING;
    Future.wait([_loadLevel()
    ]).then(_initGame);
  }

  /*
      Change the game state to the next level
   */
  void nextLvl() {
    game.gameStatus = GameState.RUNNING;
    game.increaseLevel();
      Future.wait([_loadLevel()
      ]).then(_initGame);
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

  void pauseGame() {
    game.pauseGame();
  }

  void continueGame() {
    game.continueGame();
  }

  void placeDynamite() {
    game.placeDynamite();
  }
}